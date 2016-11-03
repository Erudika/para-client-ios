// Copyright 2013-2016 Erudika. https://erudika.com
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

/**
Represents a validation constraint.
*/
open class Constraint {
	
	/**
	The constraint name.
	*/
	open var name: String
	/**
	The payload (a map)
	*/
	open var payload: [String: AnyObject]
	
	public init (name: String, payload: [String: AnyObject]) {
		self.name = name
		self.payload = payload
	}
	
	/**
	The 'required' constraint - marks a field as required.
	- returns: constraint
	*/
	open static func required() -> Constraint {
		return Constraint(name: "required", payload: ["message": "messages.required" as AnyObject])
	}
	
	/**
	The 'min' constraint - field must contain a number larger than or equal to min.
	- parameter min: the minimum value
	- returns: constraint
	*/
	open static func min(_ min: Int) -> Constraint {
		return Constraint(name: "min", payload: [
			"value": min as AnyObject,
			"message": "messages.min" as AnyObject
			]
		)
	}
	
	/**
	The 'max' constraint - field must contain a number smaller than or equal to max.
	- parameter max: the maximum value
	- returns: constraint
	*/
	open static func max(_ max: Int) -> Constraint {
		return Constraint(name: "max", payload: [
			"value": max as AnyObject,
			"message": "messages.max" as AnyObject
			]
		)
	}
	
	/**
	The 'size' constraint - field must be a String, Object or Array 
	with a given minimum and maximum length.
	- parameter min: the minimum value
	- parameter max: the maximum value
	- returns: constraint
	*/
	open static func size(_ min: Int, max: Int) -> Constraint {
		return Constraint(name: "size", payload: [
			"min": min as AnyObject,
			"max": max as AnyObject,
			"message": "messages.size" as AnyObject
			]
		)
	}
	
	/**
	The 'digits' constraint - field must be a Number or String containing digits where:
	- parameter i: is the number of digits in the integral part is limited by 'integer', and the
	- parameter f: is the number of digits for the fractional part is limited
	- returns: constraint
	*/
	open static func digits(_ i: Int, f: Int) -> Constraint {
		return Constraint(name: "digits", payload: [
			"integer": i as AnyObject,
			"fraction": f as AnyObject,
			"message": "messages.digits" as AnyObject
			]
		)
	}
	
	/**
	The 'pattern' constraint - field must contain a value matching a regular expression.
	- parameter regex: a regular expression
	- returns: constraint
	*/
	open static func pattern(_ regex: String) -> Constraint {
		return Constraint(name: "pattern", payload: [
			"value": regex as AnyObject,
			"message": "messages.pattern" as AnyObject
			]
		)
	}
	
	/**
	The 'email' constraint - field must contain a valid email.
	- returns: constraint
	*/
	open static func email() -> Constraint {
		return Constraint(name: "email", payload: ["message": "messages.email" as AnyObject])
	}
	
	/**
	The 'falsy' constraint - field value must not be equal to 'true'.
	- returns: constraint
	*/
	open static func falsy() -> Constraint {
		return Constraint(name: "false", payload: ["message": "messages.false" as AnyObject])
	}
	
	/**
	The 'truthy' constraint - field value must be equal to 'true'.
	- returns: constraint
	*/
	open static func truthy() -> Constraint {
		return Constraint(name: "true", payload: ["message": "messages.true" as AnyObject])
	}
	
	/**
	The 'future' constraint - field value must be a Date or a timestamp in the future.
	- returns: constraint
	*/
	open static func future() -> Constraint {
		return Constraint(name: "future", payload: ["message": "messages.future" as AnyObject])
	}
	
	/**
	The 'past' constraint - field value must be a Date or a timestamp in the past.
	- returns: constraint
	*/
	open static func past() -> Constraint {
		return Constraint(name: "past", payload: ["message": "messages.past" as AnyObject])
	}
	
	/**
	The 'url' constraint - field value must be a valid URL.
	- returns: constraint
	*/
	open static func url() -> Constraint {
		return Constraint(name: "url", payload: ["message": "messages.url" as AnyObject])
	}
}
