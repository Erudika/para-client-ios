// Copyright 2013-2016 Erudika. http://erudika.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// For issues and patches go to: https://github.com/erudika

import Foundation
import SwiftyJSON
import Alamofire

/**
The Swift REST client for communicating with a Para API server.
*/
public class ParaClient {
	
	let DEFAULT_ENDPOINT: String = "https://paraio.com"
	let DEFAULT_PATH: String = "/v1/"
	let JWT_PATH: String = "/jwt_auth"
	let SEPARATOR: String = ":"
	
	var endpoint: String
	var path: String
	var tokenKey: String?
	var tokenKeyExpires: UInt64?
	var tokenKeyNextRefresh: UInt64?
	var accessKey: String
	var secretKey: String
	
	private final let signer = Signer()
	
	public required init (accessKey: String, secretKey: String?) {
		self.accessKey = accessKey
		self.secretKey = secretKey!
		self.endpoint = DEFAULT_ENDPOINT
		self.path = DEFAULT_PATH
		self.tokenKey = loadPref("tokenKey")
		let tke = loadPref("tokenKeyExpires")
		let tknr = loadPref("tokenKeyNextRefresh")
		self.tokenKeyExpires = tke != nil ? UInt64(tke!) : nil
		self.tokenKeyNextRefresh = tknr != nil ? UInt64(tknr!) : nil
		if (secretKey ?? "").isEmpty {
			print("Secret key not provided. Make sure you call 'signIn()' first.")
		}
	}
	
	// MARK: Public methods
	
	public func setEndpoint(endpoint: String) {
		self.endpoint = endpoint
	}
	
	/// Returns the endpoint URL
	public func getEndpoint() -> String {
		if (self.endpoint ?? "").isEmpty {
			return DEFAULT_ENDPOINT
		} else {
			return self.endpoint
		}
	}
	
	/// Sets the API request path
	public func setApiPath(path: String) {
		self.path = path
	}
	
	/// Returns the API request path
	public func getApiPath() -> String {
		if (tokenKey ?? "").isEmpty {
			return DEFAULT_PATH
		} else {
			if !self.path.hasSuffix("/") {
				self.path += "/"
			}
			return self.path
		}
	}
	
	/// Sets the JWT access token.
	public func setAccessToken(token: String) {
		if !(token ?? "").isEmpty {
			var parts = token.componentsSeparatedByString(".")
			let decoded:JSON = JSON(data: NSData(base64EncodedString: parts[1],
				options: NSDataBase64DecodingOptions(rawValue: 0))!)
			if decoded != nil && decoded["exp"] != nil {
				self.tokenKeyExpires = decoded.dictionaryValue["exp"]?.uInt64Value
				self.tokenKeyNextRefresh = decoded.dictionaryValue["refresh"]?.uInt64Value
			} else {
				self.tokenKeyExpires = nil
				self.tokenKeyNextRefresh = nil
			}
		}
		self.tokenKey = token
	}
	
	/// Returns the JWT access token, or null if not signed in
	public func getAccessToken() -> String? {
		return self.tokenKey
	}
	
	// MARK: Private methods
	
	/// Clears the JWT token from memory, if such exists.
	private func clearAccessToken() {
		self.tokenKey = nil
		self.tokenKeyExpires = nil
		self.tokenKeyNextRefresh = nil
		self.clearPref("tokenKey")
		self.clearPref("tokenKeyExpires")
		self.clearPref("tokenKeyNextRefresh")
	}
	
	/// Saves JWT tokens to disk
	private func saveAccessToken(jwtData: NSDictionary?) {
		if jwtData != nil && jwtData!.count > 0 {
			self.tokenKey = String(jwtData!["access_token"])
			self.tokenKeyExpires = jwtData!["expires"] as? UInt64
			self.tokenKeyNextRefresh = jwtData!["refresh"] as? UInt64
			self.savePref("tokenKey", value: self.tokenKey)
			self.savePref("tokenKeyExpires", value: String(self.tokenKeyExpires))
			self.savePref("tokenKeyNextRefresh", value: String(self.tokenKeyNextRefresh))
		}
	}
	
	/// Clears the JWT token from memory, if such exists.
	private func key(refresh: Bool) -> String {
		if self.tokenKey != nil {
			if refresh {
				refreshToken({ _ in })
			}
			return "Bearer \(self.tokenKey)"
		}
		return self.secretKey
	}
	
	private func getFullPath(resourcePath: String) -> String {
		if !resourcePath.isEmpty && resourcePath.hasPrefix(JWT_PATH) {
			return resourcePath
		}
		if resourcePath.hasPrefix("/") {
			return getApiPath() + resourcePath.substringFromIndex(resourcePath.startIndex.advancedBy(1))
		} else {
			return getApiPath() + resourcePath
		}
	}
	
	private func currentTimeMillis() -> UInt64 {
		return UInt64(NSDate().timeIntervalSince1970 * 1000)
	}
	
	private func invokeGet<T>(resourcePath: String, params: [String: AnyObject]? = [:],
	                       rawResult: Bool? = true, callback: T? -> Void, error: (NSError -> Void)? = { _ in }) {
		signer.invokeSignedRequest(self.accessKey, secretKey: key(JWT_PATH != resourcePath), httpMethod: "GET",
		                                endpointURL: getEndpoint(), reqPath: getFullPath(resourcePath),
		                                params: params, rawResult: rawResult, callback: callback, error: error)
	}
	
	private func invokePost<T>(resourcePath: String, entity: JSON?, rawResult: Bool? = true,
	                        callback: T? -> Void, error: (NSError -> Void)? = { _ in }) {
		signer.invokeSignedRequest(self.accessKey, secretKey: key(false), httpMethod: "POST",
		                                endpointURL: getEndpoint(), reqPath: getFullPath(resourcePath),
		                                body: entity, rawResult: rawResult, callback: callback, error: error)
	}
	
	private func invokePut<T>(resourcePath: String, entity: JSON?, rawResult: Bool? = true,
	                       callback: T? -> Void, error: (NSError -> Void)? = { _ in }) {
		signer.invokeSignedRequest(self.accessKey, secretKey: key(false), httpMethod: "PUT",
		                                endpointURL: getEndpoint(), reqPath: getFullPath(resourcePath),
		                                body: entity, rawResult: rawResult, callback: callback, error: error)
	}
	
	private func invokePatch<T>(resourcePath: String, entity: JSON?, rawResult: Bool? = true,
	                         callback: T? -> Void, error: (NSError -> Void)? = { _ in }) {
		signer.invokeSignedRequest(self.accessKey, secretKey: key(false), httpMethod: "PATCH",
		                                endpointURL: getEndpoint(), reqPath: getFullPath(resourcePath),
		                                body: entity, rawResult: rawResult, callback: callback, error: error)
	}
	
	private func invokeDelete<T>(resourcePath: String, params: [String: AnyObject]? = [:],
	                          rawResult: Bool? = true, callback: T? -> Void, error: (NSError -> Void)? = { _ in }) {
		signer.invokeSignedRequest(self.accessKey, secretKey: key(false), httpMethod: "DELETE",
		                                endpointURL: getEndpoint(), reqPath: getFullPath(resourcePath),
		                                params: params, rawResult: rawResult, callback: callback, error: error)
	}
	
	private func pagerToParams(pager: Pager? = nil) -> NSMutableDictionary {
		let map:NSMutableDictionary = [:]
		if pager != nil {
			map["page"] = String(pager!.page)
			map["desc"] = String(pager!.desc)
			map["limit"] = String(pager!.limit)
			if let sortby = pager?.sortby {
				map["sort"] = sortby
			}
		}
		return map
	}
	
	private func getItemsFromList(result: [JSON]? = []) -> [ParaObject] {
		if result != nil && !result!.isEmpty {
			var objects = [ParaObject]()
			for map in result! {
				let p = ParaObject()
				p.setFields(map.dictionaryObject)
				objects.append(p)
			}
			return objects
		}
		return []
	}
	
	private func getItems(result: [String: JSON]? = [:], pager: Pager? = nil) -> [ParaObject] {
		if result != nil && !result!.isEmpty && result!.keys.contains("items") {
			if pager != nil && result!.keys.contains("totalHits") {
				pager?.count = result!["totalHits"]?.uIntValue ?? 0
			}
			return getItemsFromList(result!["items"]?.arrayValue)
		}
		return []
	}
		
	private func savePref(key: String, value: String?) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setValue(value, forKey: key)
		defaults.synchronize()
	}
	
	private func loadPref(key: String) -> String? {
		let defaults = NSUserDefaults.standardUserDefaults()
		return defaults.stringForKey(key)
	}
	
	private func clearPref(key: String) {
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey(key)
	}
	
	/////////////////////////////////////////////
	// MARK: PERSISTENCE
	/////////////////////////////////////////////
	//
	/**
	Persists an object to the data store. If the object's type and id are given,
	then the request will be a PUT request and any existing object will be
	overwritten.
	- parameter obj: the domain object
	- parameter callback: called with response object when the request is completed
	*/
	public func create(obj: ParaObject, callback: ParaObject? -> Void, error: (NSError -> Void)? = { _ in }) {
		if (obj.id ?? "").isEmpty || (obj.type ?? "").isEmpty {
			invokePost(obj.type, entity: JSON(obj.getFields()), rawResult: false, callback: callback, error: error)
		} else {
			invokePut("\(obj.type)/\(obj.id)", entity: JSON(obj.getFields()), rawResult: false, callback: callback, error: error)
		}
	}
	
	/**
	Retrieves an object from the data store.
	- parameter type: the type of the object to read
	- parameter id: the id of the object to read
	- parameter callback: called with response object when the request is completed
	*/
	public func read(type: String? = nil, id: String, callback: ParaObject? -> Void, error: (NSError -> Void)? = { _ in }) {
		if (type ?? "").isEmpty {
			invokeGet("_id/\(id)", rawResult: false, callback: callback, error: error)
		} else {
			invokeGet("\(type!)/\(id)", rawResult: false, callback: callback, error: error)
		}
	}
	
	/**
	Updates an object permanently. Supports partial updates.
	- parameter obj: the object to update
	- parameter callback: called with response object when the request is completed
	*/
	public func update(obj: ParaObject, callback: ParaObject? -> Void, error: (NSError -> Void)? = { _ in }) {
		invokePatch(obj.getObjectURI(), entity: JSON(obj.getFields()), rawResult: false, callback: callback, error: error)
	}
	
	/**
	Deletes an object permanently.
	- parameter obj: tobject to delete
	- parameter callback: called with response object when the request is completed
	*/
	public func delete(obj: ParaObject, callback: (Any? -> Void)? = { _ in }, error: (NSError -> Void)? = { _ in }) {
		invokeDelete(obj.getObjectURI(), rawResult: false, callback: callback!, error: error)
	}
	
	/**
	Saves multiple objects to the data store.
	- parameter objects: the list of objects to save
	- parameter callback: called with response object when the request is completed
	*/
	public func createAll(objects: [ParaObject], callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		if objects.isEmpty {
			callback([])
			return
		}
		var entity = [AnyObject]()
		for po in objects {
			entity.append(po.getFields())
		}
		invokePost("_batch", entity: JSON(entity), callback: { res in
			callback(self.getItemsFromList(res?.arrayValue))
		} as JSON? -> Void, error: error)
	}
	
	/**
	Retrieves multiple objects from the data store.
	- parameter keys: a list of object ids
	- parameter callback: called with response object when the request is completed
	*/
	public func readAll(keys: [String], callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		if keys.isEmpty {
			callback([])
			return
		}
		let ids = ["ids": keys]
		invokeGet("_batch", params: ids, callback: { res in
			callback(self.getItemsFromList(res?.arrayValue))
		} as JSON? -> Void, error: error)
	}
	
	/**
	Updates multiple objects.
	- parameter objects: the objects to update
	- parameter callback: called with response object when the request is completed
	*/
	public func updateAll(objects: [ParaObject], callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		if objects.isEmpty {
			callback([])
			return
		}
		var entity = [AnyObject]()
		for po in objects {
			entity.append(po.getFields())
		}
		invokePatch("_batch", entity: JSON(entity), callback: { res in
			callback(self.getItemsFromList(res?.arrayValue))
		} as JSON? -> Void, error: error)
	}
	
	/**
	Deletes multiple objects.
	- parameter keys: the ids of the objects to delete
	- parameter callback: called with response object when the request is completed
	*/
	public func deleteAll(keys: [String], callback: ([Any]? -> Void) = { _ in }, error: (NSError -> Void)? = { _ in }) {
		if keys.isEmpty {
			callback([])
			return
		}
		let ids = ["ids": keys]
		invokeDelete("_batch", params: ids, callback: callback, error: error)
	}
	
	/**
	Returns a list all objects found for the given type.
	The result is paginated so only one page of items is returned, at a time.
	- parameter type: the type of objects to search for
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func list(type: String, pager: Pager? = nil, callback: [ParaObject]? -> Void,
	                 error: (NSError -> Void)? = { _ in }) {
		if type.isEmpty {
			callback([])
			return
		}
		invokeGet(type, params: (pagerToParams(pager) as NSDictionary) as? [String: AnyObject], callback: { res in
			callback(self.getItems(res?.dictionaryValue, pager: pager))
		} as JSON? -> Void, error: error)
	}
	
	/////////////////////////////////////////////
	// MARK: SEARCH
	/////////////////////////////////////////////
	//
	/**
	Simple id search.
	- parameter id: an id
	- parameter callback: called with response object when the request is completed
	*/
	public func findById(id: String, callback: ParaObject? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params:NSMutableDictionary = ["id": id]
		find("id", params: params, callback: { res in
			let list = self.getItems(res)
			callback(list.isEmpty ? nil : list[0])
		}, error: error)
	}
	
	/**
	Simple multi id search.
	- parameter ids: a list of ids to search for
	- parameter callback: called with response object when the request is completed
	*/
	public func findByIds(ids: [String], callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params:NSMutableDictionary = ["ids": ids]
		find("ids", params: params, callback: { res in
			callback(self.getItems(res))
		}, error: error)
	}
	
	/**
	Search through all Address objects in a radius of X km from a given point.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter query: the query string
	- parameter radius: the radius of the search circle
	- parameter lat: latitude
	- parameter lng: longitude
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findNearby(type: String, query: String, radius: Int, lat: Double, lng: Double,
	                       pager: Pager? = nil, callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = pagerToParams(pager)
		params["latlng"] = "\(lat),\(lng)"
		params["radius"] = String(radius)
		params["q"] = query
		params["type"] = type
		find("nearby", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Searches for objects that have a property which value starts with a given prefix.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter field: the property name of an object
	- parameter prefix: the prefix
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findPrefix(type: String, field: String, prefix: String,
	                       pager: Pager? = nil, callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = pagerToParams(pager)
		params["field"] = field
		params["prefix"] = prefix
		params["type"] = type
		find("prefix", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Simple query string search. This is the basic search method.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter query: the query string
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findQuery(type: String, query: String, pager: Pager? = nil, callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = pagerToParams(pager)
		params["q"] = query
		params["type"] = type
		find("", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Searches for objects that have similar property values to a given text.
	A "find like this" query.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter filterKey: exclude an object with this key from the results (optional)
	- parameter fields: a list of property names
	- parameter liketext: text to compare to
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findSimilar(type: String, filterKey: String, fields: [String]? = nil, liketext: String,
	                        pager: Pager? = nil, callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = pagerToParams(pager)
		params["fields"] = fields
		params["filterid"] = filterKey
		params["like"] = liketext
		params["type"] = type
		find("similar", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Searches for objects tagged with one or more tags.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter tags: the list of tags
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findTagged(type: String, tags: [String]? = nil, pager: Pager? = nil,
	                       callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = pagerToParams(pager)
		params["tags"] = tags
		params["type"] = type
		find("tagged", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Searches for Tag objects. This method might be deprecated in the future.
	- parameter keyword: the tag keyword to search for
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findTags(keyword: String? = nil, pager: Pager? = nil, callback: [ParaObject]? -> Void,
	                     error: (NSError -> Void)? = { _ in }) {
		let kword = (keyword ?? "").isEmpty ? "*" : "\(keyword)*"
		findWildcard("tag", field: "tag", wildcard: kword, pager: pager, callback: callback, error: error)
	}
	
	/**
	Searches for objects having a property value that is in list of possible values.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter field: the property name of an object
	- parameter terms: a list of terms (property values)
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findTermInList(type: String, field: String, terms: [String],
	                           pager: Pager? = nil, callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = pagerToParams(pager)
		params["field"] = field
		params["terms"] = terms
		params["type"] = type
		find("in", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Searches for objects that have properties matching some given values. A terms query.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter terms: a list of terms (property values)
	- parameter matchAll: match all terms. If true - AND search, if false - OR search
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findTerms(type: String, terms: [String: AnyObject], matchAll: Bool,
	                      pager: Pager? = nil, callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		if terms.isEmpty {
			callback([])
			return
		}
		let params = pagerToParams(pager)
		var list = [String]()
		params["matchall"] = String(matchAll)
		for (key, value) in terms {
			if value.description != nil {
				list.append("\(key):\(value.description)")
			}
		}
		if !terms.isEmpty {
			params["terms"] = list
		}
		params["type"] = type
		find("terms", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}

	/**
	Searches for objects that have a property with a value matching a wildcard query.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter field: the property name of an object
	- parameter wildcard: wildcard query string. For example "cat*".
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func findWildcard(type: String, field: String, wildcard: String, pager: Pager? = nil,
	                         callback: [ParaObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = pagerToParams(pager)
		params["field"] = field
		params["q"] = wildcard
		params["type"] = type
		find("wildcard", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Counts indexed objects.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter callback: called with response object when the request is completed
	*/
	public func getCount(type: String, callback: UInt -> Void, error: (NSError -> Void)? = { _ in }) {
		let params:NSMutableDictionary = ["type": type]
		find("count", params: params, callback: { res in
			let pager = Pager()
			self.getItems(res, pager: pager)
			callback(pager.count)
		}, error: error)
	}
	
	/**
	Counts indexed objects matching a set of terms/values.
	- parameter type: the type of object to search for. See ParaObject.getType()
	- parameter terms: a list of terms (property values)
	- parameter callback: called with response object when the request is completed
	*/
	public func getCount(type: String, terms: [String: AnyObject], callback: UInt -> Void,
	                     error: (NSError -> Void)? = { _ in }) {
		if terms.isEmpty {
			callback(0)
			return
		}
		let params = NSMutableDictionary()
		var list = [String]()
		for (key, value) in terms {
			if value.description != nil {
				list.append("\(key):\(value.description)")
			}
		}
		if !terms.isEmpty {
			params["terms"] = list
		}
		params["type"] = type
		params["count"] = "true"
		find("terms", params: params, callback: { res in
			let pager = Pager()
			self.getItems(res, pager: pager)
			callback(pager.count)
		}, error: error)
	}
	
	private func find(queryType: String, params: NSMutableDictionary,
	                  callback: [String: JSON]? -> Void, error: (NSError -> Void)? = { _ in }) {
		if params.count > 0 {
			let qType = queryType.isEmpty ? "" : "/" + queryType
			invokeGet("search" + qType, params: (params as NSDictionary) as? [String: AnyObject], rawResult: true,
			          callback: callback, error: error)
			return
		}
		callback(["items": [:], "totalHits": 0])
	}
	
	/////////////////////////////////////////////
	// MARK: LINKS
	/////////////////////////////////////////////
	//
	/**
	Count the total number of links between this object and another type of object.
	- parameter obj: the object to execute this method on
	- parameter type2: the other type of object
	- parameter callback: called with response object when the request is completed
	*/
	public func countLinks(obj: ParaObject, type2: String, callback: UInt -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || type2.isEmpty {
			callback(0)
			return
		}
		let params = ["count": "true"]
		invokeGet("\(obj.getObjectURI())/links/\(type2)", params: params, callback: { res in
			let pager = Pager()
			self.getItems(res?.dictionaryValue, pager: pager)
			callback(pager.count)
		} as JSON? -> Void, error: error)
	}
	
	/**
	Returns all objects linked to the given one. Only applicable to many-to-many relationships.
	- parameter obj: the object to execute this method on
	- parameter type2: the other type of object
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func getLinkedObjects(obj: ParaObject, type2: String, pager: Pager? = nil,
	                             callback: [ParaObject] -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || type2.isEmpty {
			callback([])
			return
		}
		invokeGet("\(obj.getObjectURI())/links/\(type2)", callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Checks if an object is linked to another.
	- parameter obj: the object to execute this method on
	- parameter type2: the other type
	- parameter id2: the other id
	- parameter callback: called with response object when the request is completed
	*/
	public func isLinked(obj: ParaObject, type2: String, id2: String, callback: Bool -> Void,
	                     error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || type2.isEmpty || id2.isEmpty {
			callback(false)
			return
		}
		invokeGet("\(obj.getObjectURI())/links/\(type2)/\(id2)", callback: { res in
			callback(res ?? false)
		}, error: error)
	}
	
	/**
	Checks if a given object is linked to this one.
	- parameter obj: the object to execute this method on
	- parameter toObj: the other object
	- parameter callback: called with response object when the request is completed
	*/
	public func isLinked(obj: ParaObject, toObj: ParaObject, callback: Bool -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || toObj.id.isEmpty {
			callback(false)
			return
		}
		isLinked(obj, type2: toObj.type, id2: toObj.id, callback: callback, error: error)
	}
	
	/**
	Links an object to this one in a many-to-many relationship.
	Only a link is created. Objects are left untouched.
	The type of the second object is automatically determined on read.
	- parameter obj: the object to execute this method on
	- parameter id2: link to the object with this id
	- parameter callback: called with response object when the request is completed
	*/
	public func link(obj: ParaObject, id2: String, callback: String? -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || id2.isEmpty {
			callback(nil)
			return
		}
		invokePost("\(obj.getObjectURI())/links/\(id2)", entity: nil, callback: callback, error: error)
	}
	
	/**
	Unlinks an object from this one. Only a link is deleted. Objects are left untouched.
	- parameter obj: the object to execute this method on
	- parameter type2: the other type
	- parameter id2: the other id
	- parameter callback: called with response object when the request is completed
	*/
	public func unlink(obj: ParaObject, type2: String, id2: String, callback: Any? -> Void,
	                   error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || type2.isEmpty || id2.isEmpty {
			callback(nil)
			return
		}
		invokeDelete("\(obj.getObjectURI())/links/\(type2)/\(id2)", callback: callback, error: error)
	}
	
	/**
	Unlinks all objects that are linked to this one.
	- parameter obj: the object to execute this method on
	- parameter callback: called with response object when the request is completed
	*/
	public func unlinkAll(obj: ParaObject, callback: Any? -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty {
			callback(nil)
			return
		}
		invokeDelete("\(obj.getObjectURI())/links", callback: callback, error: error)
	}
	
	/**
	Count the total number of child objects for this object.
	- parameter obj: the object to execute this method on
	- parameter type2: the type of the other object
	- parameter callback: called with response object when the request is completed
	*/
	public func countChildren(obj: ParaObject, type2: String, callback: UInt -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || type2.isEmpty {
			callback(0)
			return
		}
		let params = ["count": "true", "childrenonly": "true"]
		invokeGet("\(obj.getObjectURI())/links/\(type2)", params: params, callback: { res in
			let pager = Pager()
			self.getItems(res?.dictionaryValue, pager: pager)
			callback(pager.count)
		} as JSON? -> Void, error: error)
	}
	
	/**
	Returns all child objects linked to this object.
	- parameter obj: the object to execute this method on
	- parameter type2: the type of the other object
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func getChildren(obj: ParaObject, type2: String, pager: Pager? = nil,
	                        callback: [ParaObject] -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || type2.isEmpty {
			callback([])
			return
		}
		let params = ["childrenonly": "true"]
		invokeGet("\(obj.getObjectURI())/links/\(type2)", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Returns all child objects linked to this object.
	- parameter obj: the object to execute this method on
	- parameter type2: the type of the other object
	- parameter field: the field name to use as filter
	- parameter term: the field value to use as filter
	- parameter pager: a Pager
	- parameter callback: called with response object when the request is completed
	*/
	public func getChildren(obj: ParaObject, type2: String, field: String, term: String,
	                        pager: Pager? = nil, callback: [ParaObject] -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || type2.isEmpty {
			callback([])
			return
		}
		let params = ["childrenonly": "true", "field": field, "term": term]
		invokeGet("\(obj.getObjectURI())/links/\(type2)", params: params, callback: { res in
			callback(self.getItems(res, pager: pager))
		}, error: error)
	}
	
	/**
	Deletes all child objects permanently.
	- parameter obj: the object to execute this method on
	- parameter type2: the type of the other object
	- parameter callback: called with response object when the request is completed
	*/
	public func deleteChildren(obj: ParaObject, type2: String, callback: Any? -> Void, error: (NSError -> Void)? = { _ in }) {
		if obj.id.isEmpty || type2.isEmpty {
			callback([])
			return
		}
		let params = ["childrenonly": "true"]
		invokeDelete("\(obj.getObjectURI())/links/\(type2)", params: params, callback: callback, error: error)
	}
	
	/////////////////////////////////////////////
	// MARK: UTILS
	/////////////////////////////////////////////
	//
	/**
	Generates a new unique id.
	- parameter callback: called with response object when the request is completed
	*/
	public func newId(callback: String -> Void, error: (NSError -> Void)? = { _ in }) {
		invokeGet("utils/newid", callback: { res in
			callback(res ?? "")
		}, error: error)
	}
	
	/**
	Returns the current timestamp.
	- parameter callback: called with response object when the request is completed
	*/
	public func getTimestamp(callback: UInt64 -> Void, error: (NSError -> Void)? = { _ in }) {
		invokeGet("utils/timestamp", callback: { res in
			callback(res?.uInt64Value ?? 0)
		} as JSON? -> Void, error: error)
	}
	
	/**
	Formats a date in a specific format.
	- parameter format: the date format eg. "yyyy MMM dd"
	- parameter locale: the locale, eg. "en_US"
	- parameter callback: called with response object when the request is completed
	*/
	public func formatDate(format: String, locale: String, callback: String? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = ["format": format, "locale": locale]
		invokeGet("utils/formatdate", params: params, callback: callback, error: error)
	}
	
	/**
	Converts spaces to dashes.
	- parameter str: a string with spaces
	- parameter replaceWith: a string to replace spaces it with
	- parameter callback: called with response object when the request is completed
	*/
	public func noSpaces(str: String, replaceWith: String, callback: String? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = ["string": str, "replacement": replaceWith]
		invokeGet("utils/nospaces", params: params, callback: callback, error: error)
	}
	
	/**
	Strips all symbols, punctuation, whitespace and control chars from a string.
	- parameter str: a dirty string
	- parameter callback: called with response object when the request is completed
	*/
	public func stripAndTrim(str: String, callback: String? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = ["string": str]
		invokeGet("utils/nosymbols", params: params, callback: callback, error: error)
	}
	
	/**
	Converts Markdown to HTML
	- parameter markdownString: Markdown
	- parameter callback: called with response object when the request is completed
	*/
	public func markdownToHtml(markdownString: String, callback: String? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = ["md": markdownString]
		invokeGet("utils/md2html", params: params, callback: callback, error: error)
	}
	
	/**
	Returns the number of minutes, hours, months elapsed for a time delta (milliseconds).
	- parameter delta: the time delta between two events, in milliseconds
	- parameter callback: called with response object when the request is completed
	*/
	public func approximately(delta: UInt, callback: String? -> Void, error: (NSError -> Void)? = { _ in }) {
		let params = ["delta": delta]
		invokeGet("utils/timeago", params: params, callback: callback, error: error)
	}
	
	/////////////////////////////////////////////
	// MARK: MISC
	/////////////////////////////////////////////
	//
	/**
	Generates a new set of access/secret keys. Old keys are discarded and invalid after this.
	- parameter callback: called with response object when the request is completed
	*/
	public func newKeys(callback: [String: String] -> Void, error: (NSError -> Void)? = { _ in }) {
		invokePost("_newkeys", entity: nil, callback: { keys in
			if keys != nil && (keys?.keys.contains("secretKey"))! {
				self.secretKey = keys!["secretKey"]!
				callback(keys!)
			}
		} as [String: String]? -> Void, error: error)
	}
	
	/**
	Returns all registered types for this App.
	- parameter callback: called with response object when the request is completed
	*/
	public func types(callback: [String: String]? -> Void, error: (NSError -> Void)? = { _ in }) {
		invokeGet("_types", callback: callback, error: error)
	}
	
	/**
	Returns a User or an App that is currently authenticated.
	- parameter callback: called with response object when the request is completed
	*/
	public func me(callback: ParaObject? -> Void, error: (NSError -> Void)? = { _ in }) {
		invokeGet("_me", rawResult: false, callback: callback, error: error)
	}
	
	/////////////////////////////////////////////
	// MARK: VALIDATION CONSTRAINTS
	/////////////////////////////////////////////
	//
	/**
	Returns the validation constraints map.
	- parameter callback: called with response object when the request is completed
	*/
	public func validationConstraints(callback: [String: AnyObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		invokeGet("_constraints", callback: callback, error: error)
	}
	
	/**
	Returns the validation constraints map for a given type.
	- parameter type: a type
	- parameter callback: called with response object when the request is completed
	*/
	public func validationConstraints(type: String, callback: [String: AnyObject]? -> Void,
	                                  error: (NSError -> Void)? = { _ in }) {
		invokeGet("_constraints/\(type)", callback: callback, error: error)
	}
	
	/**
	Add a new constraint for a given field.
	- parameter type: a type
	- parameter field: a field name
	- parameter constraint: a Constraint
	- parameter callback: called with response object when the request is completed
	*/
	public func addValidationConstraint(type: String, field: String, constraint: Constraint,
	                                    callback: [String: AnyObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		if type.isEmpty || field.isEmpty {
			callback([:])
			return
		}
		invokePut("_constraints/\(type)/\(field)/\(constraint.name)", entity: JSON(constraint.payload),
		          callback: callback, error: error)
	}
	
	/**
	Removes a validation constraint for a given field.
	- parameter type: a type
	- parameter field: a field name
	- parameter constraintName: the name of the constraint to remove
	- parameter callback: called with response object when the request is completed
	*/
	public func removeValidationConstraint(type: String, field: String, constraintName: String,
	                                       callback: Any? -> Void, error: (NSError -> Void)? = { _ in }) {
		if type.isEmpty || field.isEmpty || constraintName.isEmpty {
			callback([:])
			return
		}
		invokeDelete("_constraints/\(type)/\(field)/\(constraintName)", callback: callback, error: error)
	}
	
	/////////////////////////////////////////////
	// MARK: RESOURCE PERMISSIONS
	/////////////////////////////////////////////
	//
	/**
	Returns the permissions for all subjects and resources for current app.
	- parameter callback: called with response object when the request is completed
	*/
	public func resourcePermissions(callback: [String: AnyObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		invokeGet("_permissions", callback: callback, error: error)
	}
	
	/**
	Returns only the permissions for a given subject (user) of the current app.
	- parameter subjectid: the subject id (user id)
	- parameter callback: called with response object when the request is completed
	*/
	public func resourcePermissions(subjectid: String, callback: [String: AnyObject]? -> Void,
	                                error: (NSError -> Void)? = { _ in }) {
		invokeGet("_permissions/\(subjectid)", callback: callback, error: error)
	}
	
	/**
	Grants a permission to a subject that allows them to call the specified HTTP methods on a given resource.
	- parameter subjectid: the subject id (user id)
	- parameter resourcePath: resource path or object type
	- parameter permission: an array of allowed HTTP methods
	- parameter allowGuestAccess: if true - all unauthenticated requests will go through, 'false' by default.
	- parameter callback: called with response object when the request is completed
	*/
	public func grantResourcePermission(subjectid: String, resourcePath: String, permission: [String],
	                                    allowGuestAccess: Bool = false, callback: [String: AnyObject]? -> Void,
	                                    error: (NSError -> Void)? = { _ in }) {
		if subjectid.isEmpty || resourcePath.isEmpty || permission.isEmpty {
			callback([:])
			return
		}
		var permit = permission
		if allowGuestAccess && subjectid == "*" {
			permit.append("?")
		}
		let resPath = Signer.encodeURIComponent(resourcePath)
		invokePut("_permissions/\(subjectid)/\(resPath)", entity: JSON(permission), callback: callback, error: error)
	}
	
	/**
	Revokes a permission for a subject, meaning they no longer will be able to access the given resource.
	- parameter subjectid: the subject id (user id)
	- parameter resourcePath: resource path or object type
	- parameter callback: called with response object when the request is completed
	*/
	public func revokeResourcePermission(subjectid: String, resourcePath: String,
	                                     callback: Any? -> Void, error: (NSError -> Void)? = { _ in }) {
		if subjectid.isEmpty || resourcePath.isEmpty {
			callback([:])
			return
		}
		let resPath = Signer.encodeURIComponent(resourcePath)
		invokeDelete("_permissions/\(subjectid)/\(resPath)", callback: callback, error: error)
	}
	
	/**
	Revokes all permission for a subject.
	- parameter subjectid: the subject id (user id)
	- parameter callback: called with response object when the request is completed
	*/
	public func revokeAllResourcePermissions(subjectid: String, callback: [String: AnyObject]? -> Void, error: (NSError -> Void)? = { _ in }) {
		if subjectid.isEmpty {
			callback([:])
			return
		}
		invokeDelete("_permissions/\(subjectid)", callback: callback, error: error)
	}
	
	/**
	Checks if a subject is allowed to call method X on resource Y.
	- parameter subjectid: the subject id (user id)
	- parameter resourcePath: resource path or object type
	- parameter httpMethod: HTTP method name
	- parameter callback: called with response object when the request is completed
	*/
	public func isAllowedTo(subjectid: String, resourcePath: String, httpMethod: String,
	                        callback: Bool -> Void, error: (NSError -> Void)? = { _ in }) {
		if subjectid.isEmpty || resourcePath.isEmpty {
			callback(false)
			return
		}
		let resPath = Signer.encodeURIComponent(resourcePath)
		invokeGet("_permissions/\(subjectid)/\(resPath)/\(httpMethod)", callback: { res in
			callback(res ?? false)
		}, error: error)
	}
	
	
	/////////////////////////////////////////////
	// MARK: ACCESS TOKENS
	/////////////////////////////////////////////
	//
	/**
	Takes an identity provider access token and fetches the user data from that provider.
	A new User object is created if that user doesn't exist.
	Access tokens are returned upon successful authentication using one of the SDKs from
	Facebook, Google, Twitter, etc.
	<b>Note:</b> Twitter uses OAuth 1 and gives you a token and a token secret.
	<b>You must concatenate them like this: <code>{oauth_token}:{oauth_token_secret}</code> and
	use that as the provider access token.</b>
	- parameter provider: identity provider, e.g. 'facebook', 'google'...
	- parameter providerToken: access token from a provider like Facebook, Google, Twitter
	- parameter callback: called with response object when the request is completed
	*/
	public func signIn(provider: String, providerToken: String, callback: ParaObject? -> Void,
	                   error: (NSError -> Void)? = { _ in }) {
		if !provider.isEmpty && !providerToken.isEmpty {
			var credentials = [String:String]()
			credentials["appid"] = self.accessKey
			credentials["provider"] = provider
			credentials["token"] = providerToken
			invokePost(JWT_PATH, entity: JSON(credentials), callback: { result in
				if result != nil && (result?.keys.contains("user"))! && (result?.keys.contains("jwt"))! {
					let jwtData:NSDictionary = result!["jwt"] as! NSDictionary
					let userData = result!["user"] as! [String: AnyObject]
					self.saveAccessToken(jwtData)
					let user = ParaObject()
					user.setFields(userData)
					callback(user)
				} else {
					self.clearAccessToken()
					callback(nil)
				}
			} as [String: AnyObject]? -> Void, error: { e in
				self.clearAccessToken()
				error!(e)
			})
		} else {
			callback(nil)
		}
	}
	
	/**
	Clears the JWT access token but token is not revoked.
	Tokens can be revoked globally per user with revokeAllTokens().
	*/
	public func signOut() {
		clearAccessToken()
	}
	
	/**
	Refreshes the JWT access token. This requires a valid existing token. Call link signIn() first.
	- parameter callback: called with response object when the request is completed
	*/
	public func refreshToken(callback: Bool -> Void, error: (NSError -> Void)? = { _ in }) {
		let now = currentTimeMillis()
		let notExpired = self.tokenKeyExpires != nil && self.tokenKeyExpires! > now
		let canRefresh = self.tokenKeyNextRefresh != nil &&
			(self.tokenKeyNextRefresh < now || self.tokenKeyNextRefresh > self.tokenKeyExpires)
		// token present and NOT expired
		if tokenKey != nil && notExpired && canRefresh {
			invokeGet(JWT_PATH, callback: { result in
				if result != nil && (result?.keys.contains("user"))! && (result?.keys.contains("jwt"))! {
					let jwtData:NSDictionary = result!["jwt"] as! NSDictionary
					self.saveAccessToken(jwtData)
					callback(true)
				} else {
					callback(false)
				}
			} as [String: AnyObject]? -> Void, error: { e in
				self.clearAccessToken()
				error!(e)
			})
		} else {
			callback(false)
		}
	}
	
	/**
	Revokes all user tokens for a given user id.
	This would be equivalent to "logout everywhere".
	<b>Note:</b> Generating a new API secret on the server will also invalidate all client tokens.
	Requires a valid existing token.
	- parameter callback: called with response object when the request is completed
	*/
	public func revokeAllTokens(callback: Bool -> Void, error: (NSError -> Void)? = { _ in }) {
		invokeDelete(JWT_PATH, callback: { res in callback(res != nil) }, error: error)
	}
	
}

