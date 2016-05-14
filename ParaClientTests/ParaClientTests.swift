//
//  ParaClientTests.swift
//  ParaClientTests
//
//  Created by Alex on 5.04.16 г..
//  Copyright © 2016 г. Erudika. All rights reserved.
//

import XCTest
@testable import ParaClient
import SwiftyJSON
import Alamofire

class ParaClientTests: XCTestCase {
	
	private static var c1: ParaClient?
	private static var c2: ParaClient?
	private let catsType = "cat"
	private let dogsType = "dog"
	private let APP_ID = "app:para"
	private let ALLOW_ALL = "*"
	
	private var _u: ParaObject?
	private var _u1: ParaObject?
	private var _u2: ParaObject?
	private var _t: ParaObject?
	private var _s1: ParaObject?
	private var _s2: ParaObject?
	private var _a1: ParaObject?
	private var _a2: ParaObject?
	
	private static var ranOnce = false
	
	private func pc() -> ParaClient {
		if (ParaClientTests.c1 == nil) {
			ParaClientTests.c1 = ParaClient(accessKey: "app:para",
			                                secretKey: "rY8VVywpEBWKFMCPWTpl4FdlIJ7YxA1E7EcGNE9klLS1MHyYzar1nQ==")
			//c1!.setEndpoint("http://192.168.0.114:8080")
			ParaClientTests.c1!.setEndpoint("http://localhost:8080")
		}
		return ParaClientTests.c1!
	}
	
	private func pc2() -> ParaClient {
		if (ParaClientTests.c2 == nil) {
			ParaClientTests.c2 = ParaClient(accessKey: "app:para", secretKey: nil)
			ParaClientTests.c2!.setEndpoint(pc().endpoint)
		}
		return ParaClientTests.c2!
	}
	
	private func u() -> ParaObject {
		if (_u == nil) {
			_u = ParaObject(id: "111")
			_u!.name = "John Doe"
			_u!.timestamp = currentTimeMillis()
			_u!.tags = ["one", "two", "three"]
		}
		return _u!
	}
	
	private func u1() -> ParaObject {
		if (_u1 == nil) {
			_u1 = ParaObject(id: "222")
			_u1!.name = "Joe Black"
			_u1!.timestamp = currentTimeMillis()
			_u1!.tags = ["two", "four", "three"]
		}
		return _u1!
	}
	
	private func u2() -> ParaObject {
		if (_u2 == nil) {
			_u2 = ParaObject(id: "333")
			_u2!.name = "Ann Smith"
			_u2!.timestamp = currentTimeMillis()
			_u2!.tags = ["four", "five", "three"]
		}
		return _u2!
	}
	
	private func t() -> ParaObject {
		if (_t == nil) {
			_t = ParaObject(id: "tag:test")
			_t!.type = "tag"
			_t!.properties["tag"] = "test"
			_t!.properties["count"] = 3
			_t!.timestamp = currentTimeMillis()
		}
		return _t!
	}
	
	private func a1() -> ParaObject {
		if (_a1 == nil) {
			_a1 = ParaObject(id: "adr1")
			_a1!.type = "address"
			_a1!.name = "Place 1"
			_a1!.properties["address"] = "NYC"
			_a1!.properties["country"] = "US"
			_a1!.properties["latlng"] = "40.67,-73.94"
			_a1!.parentid = u().id
			_a1!.creatorid = u().id
		}
		return _a1!
	}
	
	private func a2() -> ParaObject {
		if (_a2 == nil) {
			_a2 = ParaObject(id: "adr2")
			_a2!.type = "address"
			_a2!.name = "Place 2"
			_a2!.properties["address"] = "NYC"
			_a2!.properties["country"] = "US"
			_a2!.properties["latlng"] = "40.69,-73.95"
			_a2!.parentid = t().id
			_a2!.creatorid = t().id
		}
		return _a2!
	}
	
	private func s1() -> ParaObject {
		if (_s1 == nil) {
			_s1 = ParaObject(id: "s1")
			_s1!.name = "This is a little test sentence. Testing, one, two, three."
			_s1!.timestamp = currentTimeMillis()
		}
		return _s1!
	}
	
	private func s2() -> ParaObject {
		if (_s2 == nil) {
			_s2 = ParaObject(id: "s2")
			_s2!.name = "We are testing this thing. This sentence is a test. One, two."
			_s2!.timestamp = currentTimeMillis()
		}
		return _s2!
	}
	
	private func currentTimeMillis() -> NSNumber {
		return NSNumber(unsignedLongLong: UInt64(NSDate().timeIntervalSince1970 * 1000))
	}
	
	override func setUp() {
		super.setUp()
		if (!ParaClientTests.ranOnce) {
			ParaClientTests.ranOnce = true
			let _1 = self.expectationWithDescription("")
			
			pc().me({ res in
				assert(res != nil, "Para server must be running before testing!")
				self.pc().createAll([self.u(), self.u1(), self.u2(), self.t(),
					self.s1(), self.s2(), self.a1(), self.a2()], callback: { res in
					print("\(res?.count) Objects created!")
					_1.fulfill()
				})
			})
			
			self.waitForExpectationsWithTimeout(10) { error in
				XCTAssertNil(error, "Test failed.")
			}
			sleep(1)
		}
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testExample() {
		let _1 = expectationWithDescription("1")
		pc().getTimestamp({ response in
			XCTAssertNotNil(response)
			XCTAssertTrue(response > 0)
			_1.fulfill()
		})
		self.waitForExpectationsWithTimeout(10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}
	
	func testCRUD() {
		let _1 = self.expectationWithDescription("1")
		let _2 = self.expectationWithDescription("2")
		let _3 = self.expectationWithDescription("3")
		let _4 = self.expectationWithDescription("4")
		let _5 = self.expectationWithDescription("5")
		let _6 = self.expectationWithDescription("6")
		let _7 = self.expectationWithDescription("7")
		let _8 = self.expectationWithDescription("8")
		let _9 = self.expectationWithDescription("9")
		let _10 = self.expectationWithDescription("10")
		let _11 = self.expectationWithDescription("11")
		let _12 = self.expectationWithDescription("12")
		let _13 = self.expectationWithDescription("13")
		
		pc().read("", id: "", callback: { _ in
			assert(false)
		}, error: { _ in
			assert(true)
			_1.fulfill()
		})
		pc().read(id: "", callback: { res in
			assert(false)
		}, error: { _ in
			assert(true)
			_2.fulfill()
		})
		
		let t1 = ParaObject(id: "test1")
		t1.type = "tag"
		let ux = ParaObject(id: "u1")
		ux.type = "user"
		
		pc().create(t1, callback: { t1 in
			assert(t1 != nil)
			self.pc().read(id: t1!.id, callback: { trID in
				assert(trID != nil)
				XCTAssertNotNil(trID!.timestamp!)
				XCTAssertEqual(t1!.id, trID!.id)
				_5.fulfill()
			})
			self.pc().read(t1!.type, id: t1!.id, callback: { tr in
				assert(tr != nil)
				XCTAssertNotNil(tr!.timestamp!)
				XCTAssertEqual(t1!.id, tr!.id)
				
				tr!.properties["count"] = 15
				
				self.pc().update(tr!, callback: { tu in
					assert(tu != nil)
					XCTAssertEqual((tu!.properties["count"] as! Int), (tr!.properties["count"] as! Int))
					XCTAssertNotNil(tu!.updated)
					_6.fulfill()
					
					self.pc().delete(t1!, callback: { res in
						XCTAssertNil(res)
						self.pc().read(id: t1!.id, callback: { rez in
							XCTAssertNil(rez)
							_3.fulfill()
						})
						_13.fulfill()
					})
				})
				self.pc().update(ParaObject(id: "nil"), callback: { res in
					assert(res == nil, "update() should not 'upsert'")
					_7.fulfill()
				})
				_8.fulfill()
			})
			_4.fulfill()
		})
		
		pc().create(ux, callback: { user in
			assert(false, "user should not be created")
			_9.fulfill()
		}, error: { _ in
			assert(true)
			_9.fulfill()
		})
				
		let s =  ParaObject()
		s.type = dogsType
		s.properties["foo"] = "bark!"
		pc().create(s, callback: { s in
			assert(s != nil)
			self.pc().read("sysprop", id: s!.id, callback: { dog in
				XCTAssertTrue((dog!.properties["foo"]) != nil)
				XCTAssertEqual("bark!", dog!.properties["foo"] as? String)
				self.pc().delete(dog!)
				_11.fulfill()
			})
			
			self.pc().delete(s!, callback: { res in
				XCTAssertNil(res)
				_12.fulfill()
			})
			_10.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}
	
	
	func testBatchCRUD() {
		var dogs = [ParaObject]()
		for _ in 0...2 {
			let s =  ParaObject()
			s.type = dogsType
			s.properties["foo"] = "bark!"
			dogs.append(s)
		}
		
		pc().createAll([], callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		
		pc().createAll(dogs, callback: { l1 in
			XCTAssertEqual(3, l1?.count)
			XCTAssertNotNil(l1?[0].id)
			
			let nl = [l1![0].id, l1![1].id, l1![2].id]
			self.pc().readAll(nl, callback: { l2 in
				XCTAssertEqual(3, l2?.count)
				XCTAssertEqual(l1?[0].id, l2?[0].id)
				XCTAssertEqual(l1?[1].id, l2?[1].id)
				XCTAssertTrue((l2?[0].properties.keys.contains("foo"))!)
				XCTAssertEqual("bark!", (l2?[0].properties["foo"])! as? String)
			})
		
			let part1 = ParaObject(id: l1![0].id)
			let part2 = ParaObject(id: l1![1].id)
			let part3 = ParaObject(id: l1![2].id)
			part1.type = self.dogsType
			part2.type = self.dogsType
			part3.type = self.dogsType
			
			part1.properties["custom"] = "prop"
			part1.name = "NewName1"
			part2.name = "NewName2"
			part3.name = "NewName3"
			
			self.pc().updateAll([part1, part2, part3], callback: { l3 in
				XCTAssertTrue(l3![0].properties.keys.contains("custom"))
				XCTAssertEqual(self.dogsType, l3![0].type)
				XCTAssertEqual(self.dogsType, l3![1].type)
				XCTAssertEqual(self.dogsType, l3![2].type)
				
				XCTAssertEqual(part1.name, l3![0].name)
				XCTAssertEqual(part2.name, l3![1].name)
				XCTAssertEqual(part3.name, l3![2].name)
				
				self.pc().deleteAll(nl, callback: { _ in
					sleep(1)
					self.pc().list(self.dogsType, pager: nil, callback: { res in
						XCTAssertTrue(res!.count == 0)
					})
					
					self.pc().me({ res in
						let datatypes = res!.properties["datatypes"] as? [String: String]
						XCTAssertTrue(datatypes!.values.contains(self.dogsType))
					})
				})
			})
		})
		
		pc().readAll([], callback: { res in
			XCTAssertTrue(res!.count == 0)
		})
		
		pc().updateAll([], callback: { res in
			XCTAssertTrue(res!.count == 0)
		})
	}

	func testList() {
		var cats = [ParaObject]()
		for i in 0...2 {
			let s = ParaObject(id: catsType + "\(i)")
			s.type = catsType
			cats.append(s)
		}
		
		pc().list("", callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		
		pc().createAll(cats, callback: { list in
			sleep(1)
			
			self.pc().list(self.catsType, callback: { list1 in
				XCTAssertFalse(list1?.count == 0)
				XCTAssertEqual(3, list1?.count)
				XCTAssertEqual("sysprop", list1?[0].type)
			})
			
			self.pc().list(self.catsType, pager: Pager(limit: 2), callback: { list2 in
				XCTAssertFalse(list2?.count == 0)
				XCTAssertEqual(2, list2?.count)
				
				let nl = [cats[0].id, cats[1].id, cats[2].id]
				
				self.pc().deleteAll(nl, callback: { _ in
					self.pc().me({ res in
						let datatypes = res!.properties["datatypes"] as? [String: String]
						XCTAssertTrue(datatypes!.values.contains(self.catsType))
					})
				})
			})
		})
	}

	func testSearch() {
		pc().findById("", callback: { res in
			XCTAssertNil(res)
		})
		pc().findById(u().id, callback: { res in
			XCTAssertNotNil(res)
		})
		pc().findById(t().id, callback: { res in
			XCTAssertNotNil(res)
		})
		
		pc().findByIds([], callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findByIds([u().id, u1().id, u2().id], callback: { res in
			XCTAssertEqual(3, res?.count)
		})
		pc().findNearby("", query: "", radius: 100, lat: 1, lng: 1, callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findNearby(u().type, query: "*", radius: 10, lat: 40.60, lng: -73.90, callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		pc().findNearby(t().type, query: "*", radius: 20, lat: 40.62, lng: -73.91, callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		
		pc().findPrefix("", field: "", prefix: "", callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		
		pc().findPrefix("", field: "nil", prefix: "xx", callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		
		pc().findPrefix(u().type, field: "name", prefix: "ann", callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		
		pc().findQuery("", query: "", callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		pc().findQuery("", query: "*", callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		pc().findQuery(a1().type, query: "country:US", callback: { res in
			XCTAssertEqual(2, res?.count)
		})
		pc().findQuery(u().type, query: "ann", callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		pc().findQuery(u().type, query: "Ann", callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		pc().findQuery("", query: "*", callback: { res in
			XCTAssertTrue(res?.count > 4)
		})
		
		let p =  Pager()
		XCTAssertEqual(0, p.count)
		pc().findQuery(u().type, query: "*", pager: p, callback: { res in
			XCTAssertEqual(UInt(res!.count), p.count)
			XCTAssertTrue(p.count > 0)
		})
		
		pc().findSimilar(t().type, filterKey: "", fields: nil, liketext: "", callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findSimilar(t().type, filterKey: "", fields: [], liketext: "", callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findSimilar(s1().type, filterKey: s1().id, fields: ["name"], liketext: s1().name, callback: { res in
			XCTAssertFalse(res?.count == 0)
			XCTAssertEqual(self.s2(), res![0])
		})
		
		pc().findTagged(u().type, tags: nil, callback: { res in
			XCTAssertEqual(0, res?.count)
		})
		pc().findTagged(u().type, tags: ["two"], callback: { res in
			XCTAssertEqual(2, res?.count)
		})
		pc().findTagged(u().type, tags: ["one", "two"], callback: { res in
			XCTAssertEqual(1, res?.count)
		})
		pc().findTagged(u().type, tags: ["three"], callback: { res in
			XCTAssertEqual(3, res?.count)
		})
		pc().findTagged(u().type, tags: ["four", "three"], callback: { res in
			XCTAssertEqual(2, res?.count)
		})
		pc().findTagged(u().type, tags: ["five", "three"], callback: { res in
			XCTAssertEqual(1, res?.count)
		})
		pc().findTagged(t().type, tags: ["four", "three"], callback: { res in
			XCTAssertEqual(0, res?.count)
		})
		
		pc().findTags(callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		pc().findTags("", callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		pc().findTags("unknown", callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findTags(t().properties["tag"] as? String, callback: { res in
			XCTAssertTrue(res?.count >= 1)
		})
		
		pc().findTermInList(u().type, field: "id", terms: [u().id, u1().id, u2().id, "xxx", "yyy"], callback: { res in
			XCTAssertEqual(3, res?.count)
		})
		
		// many terms
		let terms = ["id": u().id]
		let terms1 = ["type": "", "id": " "]
		let terms2 = [" ": "bad", "": ""]
		
		pc().findTerms(u().type, terms: terms, matchAll: true, callback: { res in
			XCTAssertEqual(1, res?.count)
		})
		pc().findTerms(u().type, terms: terms1, matchAll: true, callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findTerms(u().type, terms: terms2, matchAll: true, callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		
		// single term
		pc().findTerms("", terms: [:], matchAll: true, callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findTerms(u().type, terms: ["": ""], matchAll: true,  callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findTerms(u().type, terms: ["term": ""], matchAll: true, callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findTerms(u().type, terms: ["type": u().type], matchAll: true, callback: { res in
			XCTAssertTrue(res?.count >= 2)
		})
		
		pc().findWildcard(u().type, field: "", wildcard: "", callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().findWildcard(u().type, field: "name", wildcard: "an*", callback: { res in
			XCTAssertFalse(res?.count == 0)
		})
		
		pc().getCount("", callback: { res in
			XCTAssertTrue(res > 4)
		})
		pc().getCount("", callback: { res in
			XCTAssertNotEqual(0, res)
		})
		pc().getCount("test", callback: { res in
			XCTAssertEqual(0, res)
		})
		pc().getCount(u().type, callback: { res in
			XCTAssertTrue(res >= 3)
		})
		
		pc().getCount("", terms: [:], callback: { res in
			XCTAssertEqual(0, res)
		})
		pc().getCount(u().type, terms: ["id": " "], callback: { res in
			XCTAssertEqual(0, res)
		})
		pc().getCount(u().type, terms: ["id": u().id], callback: { res in
			XCTAssertEqual(1, res)
		})
		pc().getCount("", terms: ["type": u().type], callback: { res in
			XCTAssertTrue(res > 1)
		})
	}
	
	func testLinks() {
		pc().link(u(), id2: t().id, callback: { res in
			XCTAssertNotNil(res)
			self.pc().link(self.u(), id2: self.u2().id, callback: { res in
				XCTAssertNotNil(res)
				
				self.pc().isLinked(self.u(), toObj: ParaObject(), callback: { res in
					XCTAssertFalse(res)
				})
				self.pc().isLinked(self.u(), toObj: self.t(), callback: { res in
					XCTAssertTrue(res)
				})
				self.pc().isLinked(self.u(), toObj: self.u2(), callback: { res in
					XCTAssertTrue(res)
				})
				
				self.pc().getLinkedObjects(self.u(), type2: "tag", callback: { res in
					XCTAssertEqual(1, res.count)
				})
				self.pc().getLinkedObjects(self.u(), type2: "ParaObject", callback: { res in
					XCTAssertEqual(1, res.count)
				})
				
				self.pc().countLinks(self.u(), type2: "", callback: { res in
					XCTAssertEqual(0, res)
				})
				self.pc().countLinks(self.u(), type2: "tag", callback: { res in
					XCTAssertEqual(1, res)
				})
				self.pc().countLinks(self.u(), type2: "ParaObject", callback: { res in
					XCTAssertEqual(1, res)
				})
				
				self.pc().unlinkAll(self.u(), callback: { res in
					self.pc().isLinked(self.u(), toObj: self.t(), callback: { res in
						XCTAssertFalse(res)
					})
					self.pc().isLinked(self.u(), toObj: self.u2(), callback: { res in
						XCTAssertFalse(res)
					})
				})
			})
		}, error: { err in
			assert(false, "Link test failed.")
		})
	}

	
	func testUtils() {
		pc().newId({ id1 in
			self.pc().newId({ id2 in
				XCTAssertNotNil(id1)
				XCTAssertFalse(id1.isEmpty)
				XCTAssertNotEqual(id1, id2)
			})
		})
			
		pc().getTimestamp({ ts in
			XCTAssertNotNil(ts)
			XCTAssertNotEqual(0, ts)
		})
			
		pc().formatDate("MM dd yyyy", locale: "US", callback: { date1 in
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "MM dd yyyy"
			let date2 = dateFormatter.stringFromDate(NSDate())
			XCTAssertEqual(date1, date2)
		})
		
		pc().noSpaces(" test  123         test ", replaceWith: "", callback: { ns1 in
			let ns2 = "test123test"
			XCTAssertEqual(ns1, ns2)
		})
		
		pc().stripAndTrim(" %^&*( cool )      @!", callback: { st1 in
			let st2 = "cool"
			XCTAssertEqual(st1, st2)
		})
		
		pc().markdownToHtml("### hello **test**", callback: { md1 in
			let md2 = "<h3>hello <strong>test</strong></h3>"
			XCTAssertEqual(md1?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), md2)
		})
		
		pc().approximately(UInt(15000), callback: { ht1 in
			let ht2 = "15s"
			XCTAssertEqual(ht1, ht2)
		})
	}
	
	func testMisc() {
		pc().types({ types in
			XCTAssertTrue(types!.keys.contains("users"))
		})
		
		pc().me({ app in
			XCTAssertEqual(self.APP_ID, app?.id)
		})
	}
	
	func testValidationConstraints() {
		// Validations
		let kittenType = "kitten"
		pc().validationConstraints({ constraints in
			XCTAssertNotNil(constraints)
			XCTAssertFalse(constraints!.isEmpty)
			XCTAssertTrue(constraints!.keys.contains("app"))
			XCTAssertTrue(constraints!.keys.contains("user"))
		})
		
		pc().validationConstraints("app", callback: { constraint in
			XCTAssertFalse(constraint!.isEmpty)
			XCTAssertTrue(constraint!.keys.contains("app"))
			XCTAssertEqual(1, constraint!.count)
		})
		
		pc().addValidationConstraint(kittenType, field: "paws", constraint: Constraint.required(), callback: { _ in
			self.pc().validationConstraints(kittenType, callback: { constraint in
				XCTAssertTrue((constraint![kittenType] as! [String: AnyObject]).keys.contains("paws"))
				
				let ct = ParaObject(id: "felix")
				ct.type = kittenType
				// validation fails
				self.pc().create(ct, callback: { res in
					XCTAssertNil(res)
					// fix
					ct.properties["paws"] = "4"
					self.pc().create(ct, callback: { res in
						XCTAssertNotNil(res)
					})
				})
			})
		})
		
		pc().removeValidationConstraint(kittenType, field: "paws", constraintName: "required", callback: { _ in
			self.pc().validationConstraints(kittenType, callback: { constraint in
				XCTAssertFalse(constraint!.keys.contains(kittenType))
			})
		})
	}
	
	func testResourcePermissions() {
		// Permissions
		pc().resourcePermissions({ res in
			XCTAssertNotNil(res)
		})
		pc().grantResourcePermission("", resourcePath: dogsType, permission: [], callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		pc().grantResourcePermission(" ", resourcePath: "", permission: [], callback: { res in
			XCTAssertTrue(res?.count == 0)
		})
		
		pc().grantResourcePermission(u1().id, resourcePath: dogsType, permission: ["GET"], callback: { _ in
			self.pc().resourcePermissions(self.u1().id, callback: { permits in
				XCTAssertTrue(permits!.keys.contains(self.u1().id))
				XCTAssertTrue((permits![self.u1().id] as! [String: AnyObject]).keys.contains(self.dogsType))
				self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
					XCTAssertTrue(res)
				})
				self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "POST", callback: { res in
					XCTAssertFalse(res)
				})
			})
				
			// anonymous permissions
			self.pc().isAllowedTo(self.ALLOW_ALL, resourcePath: "utils/timestamp", httpMethod: "GET", callback: { res in
				XCTAssertFalse(res)
			})
			self.pc().grantResourcePermission(self.ALLOW_ALL, resourcePath: "utils/timestamp", permission: ["GET"],
												allowGuestAccess: true, callback: { res in
				XCTAssertNotNil(res)
				self.pc2().getTimestamp({ res in
					XCTAssertTrue(res > 0)
				})
				
				self.pc().isAllowedTo("*", resourcePath: "utils/timestamp", httpMethod: "DELETE", callback: { res in
					XCTAssertFalse(res)
				})
			})
				
			self.pc().resourcePermissions({ permits in
				XCTAssertTrue(permits!.keys.contains(self.u1().id))
				XCTAssertTrue((permits![self.u1().id] as! [String: AnyObject]).keys.contains(self.dogsType))
			})
				
			self.pc().revokeResourcePermission(self.u1().id, resourcePath: self.dogsType, callback: { res in
				self.pc().resourcePermissions(self.u1().id, callback: { permits in
					XCTAssertFalse((permits![self.u1().id] as! [String: AnyObject]).keys.contains(self.dogsType))
					self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
						XCTAssertFalse(res)
					})
					self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "POST", callback: { res in
						XCTAssertFalse(res)
					})
				})
			})
		})

		let WRITE = ["POST", "PUT", "PATCH", "DELETE"]
		
		pc().grantResourcePermission(self.u2().id, resourcePath: self.ALLOW_ALL, permission: WRITE, callback: { res in
			self.pc().isAllowedTo(self.u2().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
				XCTAssertTrue(res)
			})
			self.pc().isAllowedTo(self.u2().id, resourcePath: self.dogsType, httpMethod: "PATCH", callback: { res in
				XCTAssertTrue(res)
			})
		
			self.pc().revokeAllResourcePermissions(self.u2().id, callback: { permits in
				self.pc().resourcePermissions({ res in
					self.pc().isAllowedTo(self.u2().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
						XCTAssertFalse(res)
					})
					XCTAssertFalse(permits!.keys.contains(self.u2().id))
				})
			})
		})
		
		pc().grantResourcePermission(u1().id, resourcePath: dogsType, permission: WRITE, callback: { res in
			self.pc().grantResourcePermission(self.ALLOW_ALL, resourcePath: self.catsType, permission: WRITE, callback: { res in
				self.pc().grantResourcePermission(self.ALLOW_ALL, resourcePath: self.ALLOW_ALL, permission: ["GET"], callback: { res in
					// user-specific permissions are in effect
					self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
						XCTAssertTrue(res)
					})
					self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
						XCTAssertFalse(res)
					})
					self.pc().isAllowedTo(self.u1().id, resourcePath: self.catsType, httpMethod: "PUT", callback: { res in
						XCTAssertTrue(res)
					})
					self.pc().isAllowedTo(self.u1().id, resourcePath: self.catsType, httpMethod: "GET", callback: { res in
						XCTAssertTrue(res)
					})
							
					self.pc().revokeAllResourcePermissions(self.u1().id, callback: { res in
						// user-specific permissions not found so check wildcard
						self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
							XCTAssertFalse(res)
						})
						self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
							XCTAssertTrue(res)
						})
						self.pc().isAllowedTo(self.u1().id, resourcePath: self.catsType, httpMethod: "PUT", callback: { res in
							XCTAssertTrue(res)
						})
						self.pc().isAllowedTo(self.u1().id, resourcePath: self.catsType, httpMethod: "GET", callback: { res in
							XCTAssertTrue(res)
							self.pc().revokeResourcePermission(self.ALLOW_ALL, resourcePath: self.catsType, callback: { res in
								// resource-specific permissions not found so check wildcard
								self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
									XCTAssertFalse(res)
								})
								self.pc().isAllowedTo(self.u1().id, resourcePath: self.catsType, httpMethod: "PUT", callback: { res in
									XCTAssertFalse(res)
								})
								self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
								})
								self.pc().isAllowedTo(self.u1().id, resourcePath: self.catsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
								})
								self.pc().isAllowedTo(self.u2().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
								})
								self.pc().isAllowedTo(self.u2().id, resourcePath: self.catsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
									self.pc().revokeAllResourcePermissions(self.ALLOW_ALL, callback: { _ in })
									self.pc().revokeAllResourcePermissions(self.u1().id, callback: { _ in })
								})
							})
						})
					})
				})
			})
		})
	}
	
	func testAccessTokens() {
		XCTAssertNil(pc().getAccessToken())
		pc().signIn("facebook", providerToken: "test_token", callback: { res in
			XCTAssertNil(res)
		})
		pc().signOut()
		pc().revokeAllTokens({ res in
			XCTAssertFalse(res)
		})
	}
	
}

