// Copyright 2016 Christopher Sexton
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Created by Christopher Sexton, http://www.codeography.com
// GitHub: https://github.com/csexton

import Foundation
import CryptoSwift
import Alamofire
import SwiftyJSON

/**
Signs HTTP requests using the AWS V4 algorithm
*/
public class Signer {
	let regionName: String
	let serviceName: String
	
	let JSON_TYPE = "application/json"
	
	public required init() {
		self.regionName = "us-east-1"
		self.serviceName = "para"
	}
	
	func signedHeaders(accessKey: String, secretKey: String, url: NSURL, bodyDigest: String,
	                   httpMethod: String = "GET", date: NSDate = NSDate()) -> [String: String] {
		let datetime = timestamp(date)
		let port = (url.port != nil) ? ":" + String(url.port!) : ""
		var headers = ["x-amz-date": datetime, "Host": url.host! + port]		
		headers["Authorization"] = authorization(accessKey, secretKey: secretKey, url: url, headers: headers,
		                                         datetime: datetime, httpMethod: httpMethod, bodyDigest: bodyDigest)
		
		return headers
	}
	
	// MARK: Utilities
	
	private func pathForURL(url: NSURL) -> String {
		var path = url.path
		if (path ?? "").isEmpty {
			path = "/"
		} else {
			// do this to preserve encoded path fragments, like those containing encoded '/' (%2F)
			// NSURL.path  decodes them and they are lost
			var encodedPartsArray = [String]()
			// get rid of 'http(s)://'
			let fullURL = url.absoluteString.substringFromIndex(url.absoluteString.startIndex.advancedBy(8))
			var rawPath = fullURL.substringFromIndex(fullURL.rangeOfString("/")!.startIndex)
			if rawPath.characters.contains("?") {
				rawPath = rawPath.substringToIndex(rawPath.rangeOfString("?")!.startIndex)
			}
			for part in rawPath.componentsSeparatedByString("/") {
				if !part.isEmpty {
					encodedPartsArray.append(Signer.encodeURIComponent(part))
				}
			}
			path = "/" + encodedPartsArray.joinWithSeparator("/")
		}
		return path! //Signer.encodeURIComponent(path!).stringByReplacingOccurrencesOfString("%2F", withString: "/")
	}
	
	func sha256(str: String) -> String {
		let data = str.dataUsingEncoding(NSUTF8StringEncoding)!
		return data.sha256()!.toHexString()
	}
	
	private func hmac(string: NSString, key: NSData) -> NSData {
		let msg = string.dataUsingEncoding(NSUTF8StringEncoding)!.arrayOfBytes()
		let hmac:[UInt8] = try! Authenticator.HMAC(key: key.arrayOfBytes(), variant: .sha256).authenticate(msg)
		return NSData(bytes: hmac)
	}
	
	private func timestamp(date: NSDate) -> String {
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
		formatter.timeZone = NSTimeZone(name: "UTC")
		formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		return formatter.stringFromDate(date)
	}
	
	// MARK: Methods Ported from AWS SDK
	
	private func authorization(accessKey: String, secretKey: String, url: NSURL, headers: Dictionary<String, String>,
	                           datetime: String, httpMethod: String, bodyDigest: String) -> String {
		let cred = credential(accessKey, datetime: datetime)
		let shead = signedHeaders(headers)
		let sig = signature(secretKey, url: url, headers: headers, datetime: datetime,
		                    httpMethod: httpMethod, bodyDigest: bodyDigest)
		
		return [
			"AWS4-HMAC-SHA256 Credential=\(cred)",
			"SignedHeaders=\(shead)",
			"Signature=\(sig)",
			].joinWithSeparator(", ")
	}
	
	private func credential(accessKey: String, datetime: String) -> String {
		return "\(accessKey)/\(credentialScope(datetime))"
	}
	
	private func signedHeaders(headers: [String:String]) -> String {
		var list = Array(headers.keys).map { $0.lowercaseString }.sort()
		if let itemIndex = list.indexOf("authorization") {
			list.removeAtIndex(itemIndex)
		}
		return list.joinWithSeparator(";")
	}
	
	private func canonicalHeaders(headers: [String: String]) -> String {
		var list = [String]()
		let keys = Array(headers.keys).sort {$0.localizedCompare($1) == NSComparisonResult.OrderedAscending}
		
		for key in keys {
			if key.caseInsensitiveCompare("authorization") != NSComparisonResult.OrderedSame {
				// Note: This does not strip whitespace, but the spec says it should
				list.append("\(key.lowercaseString):\(headers[key]!)")
			}
		}
		return list.joinWithSeparator("\n")
	}
	
	private func signature(secretKey: String, url: NSURL, headers: [String: String],
	                       datetime: String, httpMethod: String, bodyDigest: String) -> String {
		let secret = NSString(format: "AWS4%@", secretKey).dataUsingEncoding(NSUTF8StringEncoding)!
		let date = hmac(datetime.substringToIndex(datetime.startIndex.advancedBy(8)), key: secret)
		let region = hmac(regionName, key: date)
		let service = hmac(serviceName, key: region)
		let credentials = hmac("aws4_request", key: service)
		let string = stringToSign(datetime, url: url, headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest)
		// FOR DEBUGGING
//		print("------------")
//		print(string)
//		print("------------")
		return hmac(string, key: credentials).toHexString()
	}
	
	private func credentialScope(datetime: String) -> String {
		return [
			datetime.substringToIndex(datetime.startIndex.advancedBy(8)),
			regionName,
			serviceName,
			"aws4_request"
			].joinWithSeparator("/")
	}
	
	private func stringToSign(datetime: String, url: NSURL, headers: [String: String],
	                          httpMethod: String, bodyDigest: String) -> String {
		// FOR DEBUGGING
//		print("===============")
//		print(canonicalRequest(url, headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest))
//		print("===============")
		return [
			"AWS4-HMAC-SHA256",
			datetime,
			credentialScope(datetime),
			sha256(canonicalRequest(url, headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest)),
			].joinWithSeparator("\n")
	}
	
	private func canonicalRequest(url: NSURL, headers: [String: String],
	                              httpMethod: String, bodyDigest: String) -> String {
		return [
			httpMethod,                       // HTTP Method
			pathForURL(url),                  // Resource Path
			url.query ?? "",                  // Canonicalized Query String
			"\(canonicalHeaders(headers))\n", // Canonicalized Header String (Plus a newline for some reason)
			signedHeaders(headers),           // Signed Headers String
			bodyDigest,                       // Sha265 of Body
			].joinWithSeparator("\n")
	}
	
	// MARK: Methods added for ParaClient
	
	public func invokeSignedRequest<T>(accessKey: String, secretKey: String, httpMethod: String, endpointURL: String,
	                                reqPath: String, headers: NSMutableDictionary? = [:],
	                                params: [String: AnyObject]? = [:], body: JSON? = nil, rawResult: Bool? = true,
	                                callback: T? -> Void, error: (NSError -> Void)? = { _ in })	{
		
		if accessKey.isEmpty {
			print("Blank access key: \(httpMethod) \(reqPath)")
			callback(nil)
			return
		}
		
		var doSign = true
		if secretKey.isEmpty {
			headers!["Authorization"] = "Anonymous \(accessKey)"
			doSign = false
		}
		
		var url = endpointURL + reqPath
		var urlForSigning = url
		let isJWT = secretKey.hasPrefix("Bearer")
		var bodyDigest = sha256("")
		var signedHeaders = [:]
		if urlForSigning.characters.last == "/" {
			urlForSigning = String(url.characters.dropLast())
		}
		
		let request = NSMutableURLRequest.init(URL: NSURL(string: url)!)
		request.HTTPMethod = httpMethod
		
		if params?.count > 0 {
			var paramArrayForSigning = [String]()
			var paramArray = [String]()
			let sortedKeys = params!.sort { $0.0 < $1.0 }
			for (k, _) in sortedKeys {
				if let listValue = params![k] as? [String] {
					if !listValue.isEmpty {
						paramArrayForSigning.append("\(k)=\(Signer.encodeURIComponent(listValue[0]))")
						for val in listValue {
							paramArray.append("\(k)=\(Signer.encodeURIComponent(val))")
						}
					}
				} else {
					paramArrayForSigning.append("\(k)=\(Signer.encodeURIComponent(params![k]!.description))")
					paramArray.append("\(k)=\(Signer.encodeURIComponent(params![k]!.description))")
				}
				
			}
			urlForSigning = urlForSigning + "?" + paramArrayForSigning.joinWithSeparator("&")
			url = url + "?" + paramArray.joinWithSeparator("&")
			request.URL = NSURL(string: url)
		}
		
		if body != nil {
			let bodyString = body!.rawString() ?? ""
			bodyDigest = sha256(bodyString)
			request.setValue(JSON_TYPE, forHTTPHeaderField: "Content-Type")
			request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
		}
		
		if isJWT {
			headers!["Authorization"] = "Bearer \(secretKey)"
		} else if doSign {
			signedHeaders = self.signedHeaders(accessKey, secretKey: secretKey, url: NSURL(string: urlForSigning)!,
			                                   bodyDigest: bodyDigest, httpMethod: httpMethod)
			headers!["Authorization"] = signedHeaders["Authorization"]
			headers!["x-amz-date"] = signedHeaders["x-amz-date"]
		}
		
		for (k, v) in headers! {
			request.setValue(v as? String, forHTTPHeaderField: k as! String)
		}
		
		Alamofire.request(request).validate().responseData { response in
			print("------------> DEBUG \(httpMethod) \(url)")
			switch response.result {
				case .Success:
					if let value = response.result.value {
						if value.length > 0 {
							let json = JSON(data: value)
							
//							print("__________________ \(response.response?.MIMEType) \(json)")
							if rawResult! {
								if response.response?.MIMEType == self.JSON_TYPE {
									callback(json as? T)
								} else {
									callback(String(data: value, encoding: NSUTF8StringEncoding) as? T)
								}
							} else {
								let obj = ParaObject()
								obj.setFields(json.dictionaryObject!)
								callback(obj as? T)
							}
						} else {
							callback(nil)
						}
					} else {
						callback(nil)
					}
				case .Failure(let err):
					if response.response!.statusCode == 404 {
						callback(nil)
					} else {
						print("Request '\(httpMethod) \(reqPath)' failed: \(err)")
						error?(err)
					}
			}
		}
		
	}

	public static func encodeURIComponent(s: String) -> String {
		let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
		allowed.addCharactersInString("-_.~")
		//allowed.addCharactersInString("-_.!~*'()")
		return s.stringByAddingPercentEncodingWithAllowedCharacters(allowed) ?? ""
	}
//	
//	public static func encodeURI(s: String) -> String {
//		let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
//		//allowed.addCharactersInString("-_.~")
//		allowed.addCharactersInString("-_.~")
//		return s.stringByAddingPercentEncodingWithAllowedCharacters(allowed) ?? ""
//	}
}
