// Copyright 2017 Christopher Sexton
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
open class Signer {
	let regionName: String
	let serviceName: String
	
	let JSON_TYPE = "application/json"
	
	public required init() {
		self.regionName = "us-east-1"
		self.serviceName = "para"
	}
	
	func signedHeaders(_ accessKey: String, secretKey: String, url: URL, bodyDigest: String,
	                   httpMethod: String = "GET", date: Date = Date()) -> [String: String] {
		let datetime = timestamp(date)
		let port = ((url as NSURL).port != nil) ? ":" + String(describing: (url as NSURL).port!) : ""
		var headers = ["x-amz-date": datetime, "Host": url.host! + port]		
		headers["Authorization"] = authorization(accessKey, secretKey: secretKey, url: url, headers: headers,
		                                         datetime: datetime, httpMethod: httpMethod, bodyDigest: bodyDigest)
		
		return headers
	}
	
	// MARK: Utilities
	
	fileprivate func pathForURL(_ url: URL) -> String {
		var path = url.path
		if path.isEmpty {
			path = "/"
		} else {
			// do this to preserve encoded path fragments, like those containing encoded '/' (%2F)
			// NSURL.path  decodes them and they are lost
			var encodedPartsArray = [String]()
			// get rid of 'http(s)://'
			let fullURL = String(url.absoluteString[url.absoluteString.index(url.absoluteString.startIndex, offsetBy: 8)...])
			var rawPath = String(fullURL[fullURL.range(of: "/")!.lowerBound...])
			if rawPath.contains("?") {
				rawPath = String(rawPath[..<rawPath.range(of: "?")!.lowerBound])
			}
			for part in rawPath.components(separatedBy: "/") {
				if !part.isEmpty {
					encodedPartsArray.append(Signer.encodeURIComponent(part))
				}
			}
			path = "/" + encodedPartsArray.joined(separator: "/")
		}
		return path
	}
	
	func sha256(_ str: String) -> String {
		let data = str.data(using: String.Encoding.utf8)!
		return data.sha256().toHexString()
	}
	
	fileprivate func hmac(_ string: NSString, key: Data) -> Data {
		let msg = string.data(using: String.Encoding.utf8.rawValue)!.bytes
		let hmac:[UInt8] = try! HMAC(key: key.bytes, variant: .sha256).authenticate(msg)
		return Data(bytes: hmac)
	}
	
	fileprivate func timestamp(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
		formatter.timeZone = TimeZone(identifier: "UTC")
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter.string(from: date)
	}
	
	// MARK: Methods Ported from AWS SDK
	
	fileprivate func authorization(_ accessKey: String, secretKey: String, url: URL, headers: Dictionary<String, String>,
	                           datetime: String, httpMethod: String, bodyDigest: String) -> String {
		let cred = credential(accessKey, datetime: datetime)
		let shead = signedHeaders(headers)
		let sig = signature(secretKey, url: url, headers: headers, datetime: datetime,
		                    httpMethod: httpMethod, bodyDigest: bodyDigest)
		
		return [
			"AWS4-HMAC-SHA256 Credential=\(cred)",
			"SignedHeaders=\(shead)",
			"Signature=\(sig)",
			].joined(separator: ", ")
	}
	
	fileprivate func credential(_ accessKey: String, datetime: String) -> String {
		return "\(accessKey)/\(credentialScope(datetime))"
	}
	
	fileprivate func signedHeaders(_ headers: [String:String]) -> String {
		var list = Array(headers.keys).map { $0.lowercased() }.sorted()
		if let itemIndex = list.index(of: "authorization") {
			list.remove(at: itemIndex)
		}
		return list.joined(separator: ";")
	}
	
	fileprivate func canonicalHeaders(_ headers: [String: String]) -> String {
		var list = [String]()
		let keys = Array(headers.keys).sorted {$0.localizedCompare($1) == ComparisonResult.orderedAscending}
		
		for key in keys {
			if key.caseInsensitiveCompare("authorization") != ComparisonResult.orderedSame {
				// Note: This does not strip whitespace, but the spec says it should
				list.append("\(key.lowercased()):\(headers[key]!)")
			}
		}
		return list.joined(separator: "\n")
	}
	
	fileprivate func signature(_ secretKey: String, url: URL, headers: [String: String],
	                       datetime: String, httpMethod: String, bodyDigest: String) -> String {
		let secret = NSString(format: "AWS4%@", secretKey).data(using: String.Encoding.utf8.rawValue)!
		let date = hmac(String(datetime[..<datetime.index(datetime.startIndex, offsetBy: 8)]) as NSString, key: secret)
		let region = hmac(regionName as NSString, key: date)
		let service = hmac(serviceName as NSString, key: region)
		let credentials = hmac("aws4_request", key: service)
		let string = stringToSign(datetime, url: url, headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest)
		return hmac(string as NSString, key: credentials).toHexString()
	}
	
	fileprivate func credentialScope(_ datetime: String) -> String {
		return [
			String(datetime[..<datetime.index(datetime.startIndex, offsetBy: 8)]),
			regionName,
			serviceName,
			"aws4_request"
			].joined(separator: "/")
	}
	
	fileprivate func stringToSign(_ datetime: String, url: URL, headers: [String: String],
	                          httpMethod: String, bodyDigest: String) -> String {
		return [
			"AWS4-HMAC-SHA256",
			datetime,
			credentialScope(datetime),
			sha256(canonicalRequest(url, headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest)),
			].joined(separator: "\n")
	}
	
	fileprivate func canonicalRequest(_ url: URL, headers: [String: String],
	                              httpMethod: String, bodyDigest: String) -> String {
		return [
			httpMethod,                       // HTTP Method
			pathForURL(url),                  // Resource Path
			url.query ?? "",                  // Canonicalized Query String
			"\(canonicalHeaders(headers))\n", // Canonicalized Header String (Plus a newline for some reason)
			signedHeaders(headers),           // Signed Headers String
			bodyDigest,                       // Sha265 of Body
			].joined(separator: "\n")
	}
	
	// MARK: Methods added for ParaClient
	
	open func invokeSignedRequest<T>(_ accessKey: String, secretKey: String, httpMethod: String, endpointURL: String,
	                                reqPath: String, headers: NSMutableDictionary? = [:],
	                                params: [String: AnyObject]? = [:], body: JSON? = nil, rawResult: Bool? = true,
	                                callback: @escaping (T?) -> Void, error: ((NSError) -> Void)? = { _ in })	{
		
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
		var signedHeaders = [String:String]()
		if urlForSigning.last == "/" {
			urlForSigning = String(url.dropLast())
		}
		
		var request = URLRequest(url: URL(string: url)!)
		request.httpMethod = httpMethod
		
		if (params?.count)! > 0 {
			var paramArrayForSigning = [String]()
			var paramArray = [String]()
			let sortedKeys = params!.sorted { $0.0 < $1.0 }
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
			urlForSigning = urlForSigning + "?" + paramArrayForSigning.joined(separator: "&")
			url = url + "?" + paramArray.joined(separator: "&")
			request.url = URL(string: url)
		}
		
		if body != nil {
			let bodyString = body!.rawString() ?? ""
			bodyDigest = sha256(bodyString)
			request.setValue(JSON_TYPE, forHTTPHeaderField: "Content-Type")
			request.httpBody = bodyString.data(using: String.Encoding.utf8)
		}
		
		if isJWT {
			headers!["Authorization"] = secretKey
		} else if doSign {
			signedHeaders = self.signedHeaders(accessKey, secretKey: secretKey, url: URL(string: urlForSigning)!,
			                                   bodyDigest: bodyDigest, httpMethod: httpMethod)
			headers!["Authorization"] = signedHeaders["Authorization"]
			headers!["x-amz-date"] = signedHeaders["x-amz-date"]
		}
		
		for (k, v) in headers! {
			request.setValue(v as? String, forHTTPHeaderField: k as! String)
		}
		
		AF.request(request).validate().responseData { response in
			switch response.result {
				case .success:
                    if let value = response.value {
						if value.count > 0 {
							do {
								let json = try JSON(data: value)
							
								if rawResult! {
									if response.response?.mimeType == self.JSON_TYPE {
										callback(json as? T)
									} else {
										callback(String(data: value, encoding: String.Encoding.utf8) as? T)
									}
								} else {
									let obj = ParaObject()
									obj.setFields(json.dictionaryObject! as [String : AnyObject]?)
									callback(obj as? T)
								}
							} catch {
								print("Error \(error)")
							}
						} else {
							callback(nil)
						}
					} else {
						callback(nil)
					}
				case .failure(let err):
					if response.response?.statusCode == 404 {
						callback(nil)
					} else {
						print("Request '\(httpMethod) \(reqPath)' failed: \(err)")
						error?(err as NSError)
					}
			}
		}
		
	}

    public static func encodeURIComponent(_ s: String) -> String {
		let allowed = NSMutableCharacterSet.alphanumeric()
		allowed.addCharacters(in: "-_.~")
		//allowed.addCharactersInString("-_.!~*'()")
		return s.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet) ?? ""
	}
//	
//	public static func encodeURI(s: String) -> String {
//		let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
//		//allowed.addCharactersInString("-_.~")
//		allowed.addCharactersInString("-_.~")
//		return s.stringByAddingPercentEncodingWithAllowedCharacters(allowed) ?? ""
//	}
}
