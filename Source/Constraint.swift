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

/**
Represents a validation constraint.
*/
public class Constraint {
	
	/**
	The constraint name.
	*/
	public var name: String
	/**
	The payload (a map)
	*/
	public var payload: [String: AnyObject]
	
	public init (name: String, payload: [String: AnyObject]) {
		self.name = name
		self.payload = payload
	}
	
	/**
	The 'required' constraint - marks a field as required.
	- returns: constraint
	*/
	public static func required() -> Constraint {
		return Constraint(name: "required", payload: ["message": "messages.required"])
	}
	
	/**
	The 'min' constraint - field must contain a number larger than or equal to min.
	- parameter min: the minimum value
	- returns: constraint
	*/
	public static func min(min: Int) -> Constraint {
		return Constraint(name: "min", payload: [
			"value": min,
			"message": "messages.min"
			]
		)
	}
	
	/**
	The 'max' constraint - field must contain a number smaller than or equal to max.
	- parameter max: the maximum value
	- returns: constraint
	*/
	public static func max(max: Int) -> Constraint {
		return Constraint(name: "max", payload: [
			"value": max,
			"message": "messages.max"
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
	public static func size(min: Int, max: Int) -> Constraint {
		return Constraint(name: "size", payload: [
			"min": min,
			"max": max,
			"message": "messages.size"
			]
		)
	}
	
	/**
	The 'digits' constraint - field must be a Number or String containing digits where:
	- parameter i: is the number of digits in the integral part is limited by 'integer', and the
	- parameter f: is the number of digits for the fractional part is limited
	- returns: constraint
	*/
	public static func digits(i: Int, f: Int) -> Constraint {
		return Constraint(name: "digits", payload: [
			"integer": i,
			"fraction": f,
			"message": "messages.digits"
			]
		)
	}
	
	/**
	The 'pattern' constraint - field must contain a value matching a regular expression.
	- parameter regex: a regular expression
	- returns: constraint
	*/
	public static func pattern(regex: String) -> Constraint {
		return Constraint(name: "pattern", payload: [
			"value": regex,
			"message": "messages.pattern"
			]
		)
	}
	
	/**
	The 'email' constraint - field must contain a valid email.
	- returns: constraint
	*/
	public static func email() -> Constraint {
		return Constraint(name: "email", payload: ["message": "messages.email"])
	}
	
	/**
	The 'falsy' constraint - field value must not be equal to 'true'.
	- returns: constraint
	*/
	public static func falsy() -> Constraint {
		return Constraint(name: "false", payload: ["message": "messages.false"])
	}
	
	/**
	The 'truthy' constraint - field value must be equal to 'true'.
	- returns: constraint
	*/
	public static func truthy() -> Constraint {
		return Constraint(name: "true", payload: ["message": "messages.true"])
	}
	
	/**
	The 'future' constraint - field value must be a Date or a timestamp in the future.
	- returns: constraint
	*/
	public static func future() -> Constraint {
		return Constraint(name: "future", payload: ["message": "messages.future"])
	}
	
	/**
	The 'past' constraint - field value must be a Date or a timestamp in the past.
	- returns: constraint
	*/
	public static func past() -> Constraint {
		return Constraint(name: "past", payload: ["message": "messages.past"])
	}
	
	/**
	The 'url' constraint - field value must be a valid URL.
	- returns: constraint
	*/
	public static func url() -> Constraint {
		return Constraint(name: "url", payload: ["message": "messages.url"])
	}
}