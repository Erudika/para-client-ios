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
This class stores pagination data. It limits the results for queries in the DAO
and Search objects and also counts the total number of results that are returned.
*/
public class Pager {

	public var page: UInt = 1
	public var count: UInt = 0
	public var sortby: String = "timestamp"
	public var desc: Bool = true
	public var limit: UInt = 30
	public var name: String?
	public var lastKey: String?
	
	public convenience init () {
		self.init(limit: 30)
	}
	
	public convenience init (limit: UInt) {
		self.init(page: 1, limit: limit)
	}
	
	public convenience init (page: UInt, limit: UInt) {
		self.init(page: page, sortby: "timestamp", desc: true, limit: limit)
	}
	
	public init (page: UInt, sortby: String, desc: Bool, limit: UInt) {
		self.page = page
		self.sortby = sortby
		self.desc = desc
		self.limit = limit
	}	
}