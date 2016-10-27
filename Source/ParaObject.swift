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

import SwiftyJSON

/**
The core domain class. All Para objects extend it.
*/
open class ParaObject : NSObject {

	/// The id of an object. Usually an autogenerated unique string of numbers.
	open var id: String
	/// The time when the object was created, in milliseconds (Java-style Unix timestamp).
	open var timestamp: NSNumber?
	/// The type of the object.
	open var type: String
	/// The type in plural form
	open var plural: String
	/// The application name. Added to support multiple separate apps.
	/// Every object must belong to an app.
	open var appid: String
	/// The id of the parent object.
	open var parentid: String
	/// The id of the user who created this. Should point to a {@link User} id.
	open var creatorid: String
	/// The last time this object was updated. Timestamp in milliseconds.
	open var updated: NSNumber?
	/// The name of the object. Can be anything.
	open var name: String
	/// The tags associated with this object. Tags must not be null or empty.
	open var tags: [String]
	/// Returns the total sum of all votes for this object (score, weight etc.).
	open var votes: Int = 0
	/// Gets or sets a value indicating whether this object must be stored in DB.
	open var stored: Bool
	/// Gets or sets a value indicating whether this object must be indexed.
	open var indexed: Bool
	/// Gets or sets a value indicating whether this object must be cached.
	open var cached: Bool

	open var properties: [String: Any] = [:]

	fileprivate static var _coreFields: [String: Any]?

	public convenience override init () {
		self.init(id: "")
	}

	public convenience init (id: String) {
		self.init(id: id, type: "sysprop")
	}

	public init (id: String, type: String) {
		self.id = id
		self.type = type
		self.votes = 0
		self.name = "ParaObject"
		self.stored = true
		self.indexed = true
		self.cached = true
		self.plural = ""
		self.parentid = ""
		self.creatorid = ""
		self.appid = ""
		self.tags = []
	}
	
	/**
	The plural name of the object. For example: user -> users.
	- returns: a string
	*/
	public final func getPlural() -> String {
		if !self.plural.isEmpty {
			return self.plural
		}
		if self.type.isEmpty || self.type.characters.count < 2 {
			self.type = "sysprop"
		}
		let last = self.type.substring(from: self.type.characters.index(self.type.endIndex, offsetBy: -1))
		let lastStripped = self.type.substring(to: self.type.characters.index(self.type.endIndex, offsetBy: -1))
		return (self.type.isEmpty ? self.type :
			(last == "s" ? self.type + "es" :
			(last == "y") ? lastStripped + "ies" : self.type + "s"))
	}
	
	/**
	The URI of this object. For example: /users/123.
	- returns: the URI string
	*/
	open func getObjectURI() -> String {
		let def = "/" + getPlural()
		return !self.id.isEmpty ? def + "/" + self.id : def
	}
	
	open func setObjectURI(_: String) { }
	
	subscript(name: String) -> Any {
		get {
			return self.properties[name] ?? self.value(forKey: name)
		}
		set {
			if self.value(forKey: name) == nil && !ParaObject.getCoreFields().keys.contains(name) {
				self.properties[name] = newValue
			} else {
				self.setValue(newValue, forKey: name)
			}
		}
	}
	
	open override func value(forUndefinedKey key: String) -> Any? {
		return nil
	}
	
	/**
	Populates this object with data from a Dictionary.
	- parameter map: a dictionary of data
	*/
	open func setFields(_ map: [String: Any]? = [:]) {
		for (key, val) in map! {
			self[key] = val
		}
	}
	
	/**
	Returns a dictionary of fields and values.
	- returns: a dictionary of data
	*/
	open func getFields() -> [String: Any] {
		if self.plural.isEmpty {
			self.plural = getPlural()
		}
		var props = [String: Any]()
		let mirror = Mirror(reflecting: self)
		for child in mirror.children {
			if let key = child.label {
				if key != "properties" {
					if let po = child.value as? ParaObject {
						props[key] = po.getFields()
					} else {
						let value:Any = child.value
						let anyMirror = Mirror(reflecting: value)
						if anyMirror.displayStyle == .optional {
							if anyMirror.children.count > 0 {
								let (_, unwrapped) = anyMirror.children.first!
								props[key] = unwrapped
							}
						} else {
							props[key] = value
						}
					}
				}
			}
		}
		for (key, val) in properties {
			props[key] = val
		}
		return props
	}
	
	fileprivate static func getCoreFields() -> [String: Any] {
		if ParaObject._coreFields == nil {
			ParaObject._coreFields = [String: Any]()
			for child in Mirror(reflecting: ParaObject()).children {
				if let key = child.label {
					if key != "properties" {
						ParaObject._coreFields![key] = child.value
					}
				}
			}
		}
		return ParaObject._coreFields!
	}

	/// Returns the JSON serialization of this object.
	open func toJSON() -> JSON {
		return JSON(getFields())
	}
	
	/// Returns the JSON string of this object.
	open override var description: String {
		return self.toJSON().rawString() ?? "{}"
	}
}
