//
//  ParaClientTests.swift
//  ParaClientTests
//
//  Created by Alex on 5.04.16 г..
//  Copyright © 2022 г. Erudika. All rights reserved.
//

import XCTest
import ParaClient
import SwiftyJSON
import Alamofire
@testable import ParaClient

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
			                                secretKey: "JperV7KrcqPK9PAWzZZz7YVDTRex19sQbFdeamsJifqXP+8EyvgPtA==")
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
			_s1!.properties["text"] = "This is a little test sentence. Testing, one, two, three."
			_s1!.timestamp = currentTimeMillis()
		}
		return _s1!
	}

	private func s2() -> ParaObject {
		if (_s2 == nil) {
			_s2 = ParaObject(id: "s2")
			_s2!.properties["text"] = "We are testing this thing. This sentence is a test. One, two."
			_s2!.timestamp = currentTimeMillis()
		}
		return _s2!
	}

	private func currentTimeMillis() -> NSNumber {
		return NSNumber(value: UInt64(NSDate().timeIntervalSince1970 * 1000))
	}

	override func setUp() {
		super.setUp()
		if (!ParaClientTests.ranOnce) {
			ParaClientTests.ranOnce = true
			let _1 = self.expectation(description: "")

			pc().me(nil, { res in
				assert(res != nil, "Para server must be running before testing!")
				self.pc().createAll([self.u(), self.u1(), self.u2(), self.t(),
					self.s1(), self.s2(), self.a1(), self.a2()], callback: { res in
					print("\((res?.count)!) Objects created!")
					_1.fulfill()
				})
			})
			self.waitForExpectations(timeout: 10) { error in
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
		let _1 = expectation(description: "1")
		pc().getTimestamp({ response in
			XCTAssertNotNil(response)
			XCTAssertTrue(response > 0)
			_1.fulfill()
		})
		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testCRUD() {
		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")
		let _7 = self.expectation(description: "7")
		let _8 = self.expectation(description: "8")
		let _9 = self.expectation(description: "9")
		let _10 = self.expectation(description: "10")
		let _11 = self.expectation(description: "11")
		let _12 = self.expectation(description: "12")
		let _13 = self.expectation(description: "13")

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
				XCTAssertNotNil(trID!.timestamp)
				XCTAssertEqual(t1!.id, trID!.id)
				_5.fulfill()
			})
			self.pc().read(t1!.type, id: t1!.id, callback: { tr in
				assert(tr != nil)
				XCTAssertNotNil(tr!.timestamp)
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

		self.waitForExpectations(timeout: 10) { error in
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

		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")
		let _7 = self.expectation(description: "7")
		let _8 = self.expectation(description: "8")
		let _9 = self.expectation(description: "9")

		pc().createAll([], callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_1.fulfill()
		})

		pc().createAll(dogs, callback: { l1 in
			assert(l1?.count == 3)
			assert(l1?[0].id != nil)

			let nl = [l1![0].id, l1![1].id, l1![2].id]
			self.pc().readAll(nl, callback: { l2 in
				assert(l2?.count == 3)
				XCTAssertEqual(l1?[0].id, l2?[0].id)
				XCTAssertEqual(l1?[1].id, l2?[1].id)
				XCTAssertTrue((l2?[0].properties.keys.contains("foo"))!)
				XCTAssertEqual("bark!", (l2?[0].properties["foo"])! as? String)
				_2.fulfill()
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
					self.pc().list(self.dogsType, callback: { res in
						XCTAssertTrue(res!.count == 0)
						_3.fulfill()
					})

					self.pc().me(nil, { res in
						let datatypes = res!.properties["datatypes"] as? [String: String]
						XCTAssertTrue(datatypes!.values.contains(self.dogsType))
						_4.fulfill()
					})
					_5.fulfill()
				})
				_6.fulfill()
			})
			_7.fulfill()
		})

		pc().readAll([], callback: { res in
			XCTAssertTrue(res!.count == 0)
			_8.fulfill()
		})

		pc().updateAll([], callback: { res in
			XCTAssertTrue(res!.count == 0)
			_9.fulfill()
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testList() {
		var cats = [ParaObject]()
		for i in 0...2 {
			let s = ParaObject(id: catsType + "\(i)")
			s.type = catsType
			cats.append(s)
		}

		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")

		pc().list("", callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_1.fulfill()
		})

		pc().createAll(cats, callback: { list in
			sleep(1)

			self.pc().list(self.catsType, callback: { list1 in
				XCTAssertFalse(list1?.count == 0)
				XCTAssertEqual(3, list1?.count)
				XCTAssertEqual(self.catsType, list1?[0].type)
				_2.fulfill()
			})

			self.pc().list(self.catsType, pager: Pager(limit: 2), callback: { list2 in
				XCTAssertFalse(list2?.count == 0)
				XCTAssertEqual(2, list2?.count)

				let nl = [cats[0].id, cats[1].id, cats[2].id]

				self.pc().deleteAll(nl, callback: { _ in
					self.pc().me(nil, { res in
						let datatypes = res!.properties["datatypes"] as? [String: String]
						XCTAssertTrue(datatypes!.values.contains(self.catsType))
						_3.fulfill()
					})
					_4.fulfill()
				})
				_5.fulfill()
			})
			_6.fulfill()
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testSearch() {
		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")
		let _7 = self.expectation(description: "7")
		let _8 = self.expectation(description: "8")
		let _9 = self.expectation(description: "9")
		let _10 = self.expectation(description: "10")
		let _11 = self.expectation(description: "11")
		let _12 = self.expectation(description: "12")
		let _13 = self.expectation(description: "13")
		let _14 = self.expectation(description: "14")
		let _15 = self.expectation(description: "15")
		let _16 = self.expectation(description: "16")
		let _17 = self.expectation(description: "17")
		let _18 = self.expectation(description: "18")
		let _19 = self.expectation(description: "19")
		let _20 = self.expectation(description: "20")
		let _21 = self.expectation(description: "21")
		let _22 = self.expectation(description: "22")
		let _23 = self.expectation(description: "23")
		let _24 = self.expectation(description: "24")
		let _25 = self.expectation(description: "25")
		let _26 = self.expectation(description: "26")
		let _27 = self.expectation(description: "27")
		let _28 = self.expectation(description: "28")
		let _29 = self.expectation(description: "29")
		let _30 = self.expectation(description: "30")
		let _31 = self.expectation(description: "31")
		let _32 = self.expectation(description: "32")
		let _33 = self.expectation(description: "33")
		let _34 = self.expectation(description: "34")
		let _35 = self.expectation(description: "35")
		let _36 = self.expectation(description: "36")
		let _37 = self.expectation(description: "37")
		let _38 = self.expectation(description: "38")
		let _39 = self.expectation(description: "39")
		let _40 = self.expectation(description: "40")
		let _41 = self.expectation(description: "41")
		let _42 = self.expectation(description: "42")
		let _43 = self.expectation(description: "43")
		let _44 = self.expectation(description: "44")
		let _45 = self.expectation(description: "45")
		let _46 = self.expectation(description: "46")
		let _47 = self.expectation(description: "47")
		let _48 = self.expectation(description: "48")
		let _49 = self.expectation(description: "49")
		let _50 = self.expectation(description: "50")

		pc().findById("", callback: { res in
			XCTAssertNil(res)
			_1.fulfill()
		})
		pc().findById(u().id, callback: { res in
			XCTAssertNotNil(res)
			_2.fulfill()
		})
		pc().findById(t().id, callback: { res in
			XCTAssertNotNil(res)
			_3.fulfill()
		})

		pc().findByIds([], callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_4.fulfill()
		})
		pc().findByIds([u().id, u1().id, u2().id], callback: { res in
			XCTAssertEqual(3, (res?.count)!)
			_5.fulfill()
		})
		pc().findNearby("", query: "", radius: 100, lat: 1, lng: 1, callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_6.fulfill()
		})
		pc().findNearby(u().type, query: "*", radius: 10, lat: 40.60, lng: -73.90, callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_7.fulfill()
		})
		pc().findNearby(t().type, query: "*", radius: 20, lat: 40.62, lng: -73.91, callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_8.fulfill()
		})

		pc().findPrefix("", field: "", prefix: "", callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_9.fulfill()
		})

		pc().findPrefix("", field: "nil", prefix: "xx", callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_10.fulfill()
		})

		pc().findPrefix(u().type, field: "name", prefix: "Ann", callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_11.fulfill()
		})

		pc().findQuery("", query: "", callback: { res in
			XCTAssertFalse((res?.count)! > 0)
			_12.fulfill()
		})
		pc().findQuery("", query: "*", callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_13.fulfill()
		})
		pc().findQuery(a1().type, query: "country:US", callback: { res in
			XCTAssertEqual(2, (res?.count)!)
			_14.fulfill()
		})
		pc().findQuery(u().type, query: "Ann*", callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_15.fulfill()
		})
		pc().findQuery(u().type, query: "Ann*", callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_16.fulfill()
		})
		pc().findQuery("", query: "*", callback: { res in
			XCTAssertTrue((res?.count)! > 4)
			_17.fulfill()
		})

		let p =  Pager()
		XCTAssertEqual(0, p.count)
		pc().findQuery(u().type, query: "*", pager: p, callback: { res in
			XCTAssertEqual(UInt(res!.count), p.count)
			XCTAssertTrue(p.count > 0)
			_18.fulfill()
		})

		pc().findSimilar(t().type, filterKey: "", fields: nil, liketext: "", callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_19.fulfill()
		})
		pc().findSimilar(t().type, filterKey: "", fields: [], liketext: "", callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_20.fulfill()
		})
		pc().findSimilar(s1().type, filterKey: s1().id, fields: ["properties.text"], liketext: s1().properties["text"] as! String, callback: { res in
			assert((res?.count)! > 0)
			XCTAssertEqual(self.s2().id, res![0].id)
			XCTAssertEqual(self.s2().name, res![0].name)
			_21.fulfill()
		})

		pc().findTagged(u().type, callback: { res in
			XCTAssertEqual(0, (res?.count)!)
			_22.fulfill()
		})
		pc().findTagged(u().type, tags: ["two"], callback: { res in
			XCTAssertEqual(2, (res?.count)!)
			_23.fulfill()
		})
		pc().findTagged(u().type, tags: ["one", "two"], callback: { res in
			XCTAssertEqual(1, (res?.count)!)
			_24.fulfill()
		})
		pc().findTagged(u().type, tags: ["three"], callback: { res in
			XCTAssertEqual(3, (res?.count)!)
			_25.fulfill()
		})
		pc().findTagged(u().type, tags: ["four", "three"], callback: { res in
			XCTAssertEqual(2, (res?.count)!)
			_26.fulfill()
		})
		pc().findTagged(u().type, tags: ["five", "three"], callback: { res in
			XCTAssertEqual(1, (res?.count)!)
			_27.fulfill()
		})
		pc().findTagged(t().type, tags: ["four", "three"], callback: { res in
			XCTAssertEqual(0, (res?.count)!)
			_28.fulfill()
		})

		pc().findTags(callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_29.fulfill()
		})
		pc().findTags("", callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_30.fulfill()
		})
		pc().findTags("unknown", callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_31.fulfill()
		})
		pc().findTags(t().properties["tag"] as? String, callback: { res in
			XCTAssertTrue((res?.count)! >= 1)
			_32.fulfill()
		})

		pc().findTermInList(u().type, field: "id", terms: [u().id, u1().id, u2().id, "xxx", "yyy"], callback: { res in
			XCTAssertEqual(3, (res?.count)!)
			_33.fulfill()
		})

		// many terms
		let terms = ["id": u().id]
		let terms1 = ["type": "", "id": " "]
		let terms2 = [" ": "bad", "": ""]

		pc().findTerms(u().type, terms: terms as [String : AnyObject], matchAll: true, callback: { res in
			XCTAssertEqual(1, (res?.count)!)
			_34.fulfill()
		})
		pc().findTerms(u().type, terms: terms1 as [String : AnyObject], matchAll: true, callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_35.fulfill()
		})
		pc().findTerms(u().type, terms: terms2 as [String : AnyObject], matchAll: true, callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_36.fulfill()
		})

		// single term
		pc().findTerms("", terms: [:], matchAll: true, callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_37.fulfill()
		})
		pc().findTerms(u().type, terms: ["": "" as AnyObject], matchAll: true,  callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_38.fulfill()
		})
		pc().findTerms(u().type, terms: ["term": "" as AnyObject], matchAll: true, callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_39.fulfill()
		})
		pc().findTerms(u().type, terms: ["type": u().type as AnyObject], matchAll: true, callback: { res in
			XCTAssertTrue((res?.count)! >= 2)
			_40.fulfill()
		})

		pc().findWildcard(u().type, field: "", wildcard: "", callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_41.fulfill()
		})
		pc().findWildcard(u().type, field: "name", wildcard: "An*", callback: { res in
			XCTAssertFalse((res?.count)! == 0)
			_42.fulfill()
		})

		pc().getCount("", callback: { res in
			XCTAssertTrue(res > 4)
			_43.fulfill()
		})
		pc().getCount("", callback: { res in
			XCTAssertNotEqual(0, res)
			_44.fulfill()
		})
		pc().getCount("test", callback: { res in
			XCTAssertEqual(0, res)
			_45.fulfill()
		})
		pc().getCount(u().type, callback: { res in
			XCTAssertTrue(res >= 3)
			_46.fulfill()
		})

		pc().getCount("", terms: [:], callback: { res in
			XCTAssertEqual(0, res)
			_47.fulfill()
		})
		pc().getCount(u().type, terms: ["id": " " as AnyObject], callback: { res in
			XCTAssertEqual(0, res)
			_48.fulfill()
		})
		pc().getCount(u().type, terms: ["id": u().id as AnyObject], callback: { res in
			XCTAssertEqual(1, res)
			_49.fulfill()
		})
		pc().getCount("", terms: ["type": u().type as AnyObject], callback: { res in
			XCTAssertTrue(res > 1)
			_50.fulfill()
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testLinks() {
		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")
		let _7 = self.expectation(description: "7")
		let _8 = self.expectation(description: "8")
		let _9 = self.expectation(description: "9")
		let _10 = self.expectation(description: "10")
		let _11 = self.expectation(description: "11")
		let _12 = self.expectation(description: "12")
		let _13 = self.expectation(description: "13")
		let _14 = self.expectation(description: "13")

		pc().link(u(), id2: t().id, callback: { res in
			XCTAssertNotNil(res)
			self.pc().link(self.u(), id2: self.u2().id, callback: { res in
				XCTAssertNotNil(res)

				sleep(1)

				self.pc().isLinked(self.u(), toObj: ParaObject(), callback: { res in
					XCTAssertFalse(res)
					_1.fulfill()
				})
				self.pc().isLinked(self.u(), toObj: self.t(), callback: { res in
					XCTAssertTrue(res)
					_2.fulfill()
				})
				self.pc().isLinked(self.u(), toObj: self.u2(), callback: { res in
					XCTAssertTrue(res)
					_3.fulfill()
				})

				self.pc().getLinkedObjects(self.u(), type2: "tag", callback: { res in
					XCTAssertEqual(1, res.count)
					_4.fulfill()
				})
				self.pc().getLinkedObjects(self.u(), type2: "sysprop", callback: { res in
					XCTAssertEqual(1, res.count)
					_5.fulfill()
				})

				self.pc().countLinks(self.u(), type2: "", callback: { res in
					XCTAssertEqual(0, res)
					_6.fulfill()
				})
				self.pc().countLinks(self.u(), type2: "tag", callback: { res in
					XCTAssertEqual(1, res)
					_7.fulfill()
				})
				self.pc().countLinks(self.u(), type2: "sysprop", callback: { res in
					XCTAssertEqual(1, res)
					_8.fulfill()
				})

				self.pc().countChildren(self.u(), type2: "address", callback: { res in
					XCTAssertEqual(2, res)
					_14.fulfill()
				})

				self.pc().unlinkAll(self.u(), callback: { res in
					self.pc().isLinked(self.u(), toObj: self.t(), callback: { res in
						XCTAssertFalse(res)
						_9.fulfill()
					})
					self.pc().isLinked(self.u(), toObj: self.u2(), callback: { res in
						XCTAssertFalse(res)
						_10.fulfill()
					})
					_11.fulfill()
				})
				_12.fulfill()
			})
			_13.fulfill()
		}, error: { err in
			assert(false, "Link test failed.")
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testUtils() {
		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")
		let _7 = self.expectation(description: "7")
		let _8 = self.expectation(description: "8")

		pc().newId({ id1 in
			self.pc().newId({ id2 in
				XCTAssertNotNil(id1)
				XCTAssertFalse(id1!.isEmpty)
				XCTAssertNotEqual(id1, id2)
				_1.fulfill()
			})
			_2.fulfill()
		})

		pc().getTimestamp({ ts in
			XCTAssertNotNil(ts)
			XCTAssertNotEqual(0, ts)
			_3.fulfill()
		})

		pc().formatDate("MM dd yyyy", locale: "US", callback: { date1 in
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MM dd yyyy"
			let date2 = dateFormatter.string(from: Date())
			XCTAssertEqual(date1, date2)
			_4.fulfill()
		})

		pc().noSpaces(" test  123         test ", replaceWith: "", callback: { ns1 in
			let ns2 = "test123test"
			XCTAssertEqual(ns1, ns2)
			_5.fulfill()
		})

		pc().stripAndTrim(" %^&*( cool )      @!", callback: { st1 in
			let st2 = "cool"
			XCTAssertEqual(st1, st2)
			_6.fulfill()
		})

		pc().markdownToHtml("### hello **test**", callback: { md1 in
			let md2 = "<h3>hello <strong>test</strong></h3>"
			XCTAssertEqual(md1?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines), md2)
			_7.fulfill()
		})

		pc().approximately(UInt(15000), callback: { ht1 in
			let ht2 = "15s"
			XCTAssertEqual(ht1, ht2)
			_8.fulfill()
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testMisc() {
		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")

		pc().types({ types in
			XCTAssertTrue(types!.keys.contains("users"))
			_1.fulfill()
		})

		pc().me(nil, { app in
			XCTAssertEqual(self.APP_ID, app?.id)
			_2.fulfill()
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testValidationConstraints() {
		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")
		let _7 = self.expectation(description: "7")
		let _8 = self.expectation(description: "8")

		// Validations
		let kittenType = "kitten"
		pc().validationConstraints({ constraints in
			XCTAssertNotNil(constraints)
			XCTAssertFalse(constraints!.isEmpty)
			XCTAssertTrue(constraints!.keys.contains("app"))
			XCTAssertTrue(constraints!.keys.contains("user"))
			_1.fulfill()
		})

		pc().validationConstraints("app", callback: { constraint in
			XCTAssertFalse(constraint!.isEmpty)
			XCTAssertTrue(constraint!.keys.contains("app"))
			XCTAssertEqual(1, constraint!.count)
			_2.fulfill()
		})

		pc().addValidationConstraint(kittenType, field: "paws", constraint: Constraint.required(), callback: { _ in
			self.pc().validationConstraints(kittenType, callback: { constraint in
				assert(!constraint!.isEmpty)

				XCTAssertTrue((constraint![kittenType] as! [String: AnyObject]).keys.contains("paws"))

				let ct = ParaObject(id: "felix")
				ct.type = kittenType
				// validation fails
				self.pc().create(ct, callback: { res in
					assert(false)
				}, error: { err in
					assert(true)
					// fix
					ct.properties["paws"] = "4"
					self.pc().create(ct, callback: { res in
						XCTAssertNotNil(res)

						self.pc().delete(res!)

						self.pc().removeValidationConstraint(kittenType, field: "paws", constraintName: "required", callback: { _ in
							self.pc().validationConstraints(kittenType, callback: { constraint in
								XCTAssertFalse(constraint!.keys.contains(kittenType))
								_3.fulfill()
							})
							_4.fulfill()
						})
						_5.fulfill()
					})
					_6.fulfill()
				})
				_7.fulfill()
			})
			_8.fulfill()
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testResourcePermissions() {
		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")
		let _7 = self.expectation(description: "7")
		let _8 = self.expectation(description: "8")
		let _9 = self.expectation(description: "9")
		let _10 = self.expectation(description: "10")
//		let _11 = self.expectation(description: "11")
		let _12 = self.expectation(description: "12")
		let _13 = self.expectation(description: "13")
		let _14 = self.expectation(description: "14")
		let _15 = self.expectation(description: "15")
		let _16 = self.expectation(description: "16")
		let _17 = self.expectation(description: "17")
		let _18 = self.expectation(description: "18")
		let _19 = self.expectation(description: "19")
		let _20 = self.expectation(description: "20")
		let _21 = self.expectation(description: "21")
		let _22 = self.expectation(description: "22")
		let _23 = self.expectation(description: "23")
		let _24 = self.expectation(description: "24")
		let _25 = self.expectation(description: "25")
		let _26 = self.expectation(description: "26")
		let _27 = self.expectation(description: "27")
		let _28 = self.expectation(description: "28")
		let _29 = self.expectation(description: "29")
		let _30 = self.expectation(description: "30")
		let _31 = self.expectation(description: "31")
		let _32 = self.expectation(description: "32")
		let _33 = self.expectation(description: "33")
		let _34 = self.expectation(description: "34")
		let _35 = self.expectation(description: "35")
		let _36 = self.expectation(description: "36")
		let _37 = self.expectation(description: "37")
		let _38 = self.expectation(description: "38")
		let _39 = self.expectation(description: "39")
		let _40 = self.expectation(description: "40")
		let _41 = self.expectation(description: "41")
		let _42 = self.expectation(description: "42")
		let _43 = self.expectation(description: "43")
		let _44 = self.expectation(description: "44")

		// Permissions
		pc().resourcePermissions({ res in
			XCTAssertNotNil(res)
			_1.fulfill()
		})
		pc().grantResourcePermission("", resourcePath: dogsType, permission: [], callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_2.fulfill()
		})
		pc().grantResourcePermission(" ", resourcePath: "", permission: [], callback: { res in
			XCTAssertTrue((res?.count)! == 0)
			_3.fulfill()
		})

		pc().grantResourcePermission(u1().id, resourcePath: dogsType, permission: ["GET"], callback: { _ in
			self.pc().resourcePermissions(self.u1().id, callback: { permits in
				XCTAssertTrue(permits!.keys.contains(self.u1().id))
				XCTAssertTrue((permits![self.u1().id] as! [String: AnyObject]).keys.contains(self.dogsType))

				self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "POST", callback: { res in
					XCTAssertFalse(res)
					self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
						XCTAssertTrue(res)
						_4.fulfill()
					})
					_5.fulfill()
				})
				_6.fulfill()
			})

			// anonymous permissions
			self.pc().isAllowedTo(self.ALLOW_ALL, resourcePath: "utils/timestamp", httpMethod: "GET", callback: { res in
				XCTAssertFalse(res)
				_7.fulfill()

				self.pc().grantResourcePermission(self.ALLOW_ALL, resourcePath: "utils/timestamp", permission: ["GET"],
					allowGuestAccess: true, callback: { res in
					XCTAssertNotNil(res)
					self.pc2().getTimestamp({ res in
						XCTAssertTrue(res > 0)
						_8.fulfill()
					})

					self.pc().isAllowedTo(self.ALLOW_ALL, resourcePath: "utils/timestamp", httpMethod: "DELETE",
						callback: { res in
						XCTAssertFalse(res)
						sleep(1)

						self.pc().revokeResourcePermission(self.u1().id, resourcePath: self.dogsType, callback: { res in
							sleep(1)
							self.pc().resourcePermissions(self.u1().id, callback: { permits in
								XCTAssertFalse((permits![self.u1().id] as! [String: AnyObject]).keys.contains(self.dogsType))

								self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
									_12.fulfill()
								})
								self.pc().isAllowedTo(self.u1().id, resourcePath: self.dogsType, httpMethod: "POST", callback: { res in
									XCTAssertFalse(res)
									_13.fulfill()
								})
								_14.fulfill()
							})
							_15.fulfill()
						})

						self.pc().revokeResourcePermission(self.ALLOW_ALL, resourcePath: "utils/timestamp",
							callback: { _ in _44.fulfill() })

						_9.fulfill()
					})
					_10.fulfill()
				})
			})

//			self.pc().resourcePermissions({ permits in
//				XCTAssertTrue(permits!.keys.contains(self.u1().id))
//				XCTAssertTrue((permits![self.u1().id] as! [String: AnyObject]).keys.contains(self.dogsType))
//				_11.fulfill()
//			})
			_16.fulfill()
		})

		let WRITE = ["POST", "PUT", "PATCH", "DELETE"]

		pc().grantResourcePermission(self.u2().id, resourcePath: self.ALLOW_ALL, permission: WRITE, callback: { res in
			sleep(1)
			self.pc().isAllowedTo(self.u2().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
				XCTAssertTrue(res)
				_17.fulfill()
			})
			self.pc().isAllowedTo(self.u2().id, resourcePath: self.dogsType, httpMethod: "PATCH", callback: { res in
				XCTAssertTrue(res)
				_18.fulfill()
			})

			self.pc().revokeAllResourcePermissions(self.u2().id, callback: { permits in
				sleep(1)
				self.pc().resourcePermissions({ res in
					self.pc().isAllowedTo(self.u2().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
						XCTAssertFalse(res)
						_19.fulfill()
					})
					XCTAssertTrue((permits![self.u2().id] as! [String: AnyObject]).isEmpty)
					_20.fulfill()
				})
				_21.fulfill()
			})
			_22.fulfill()
		})

		pc().grantResourcePermission(u().id, resourcePath: dogsType, permission: WRITE, callback: { res in
			self.pc().grantResourcePermission(self.ALLOW_ALL, resourcePath: self.catsType, permission: WRITE, callback: { res in
				self.pc().grantResourcePermission(self.ALLOW_ALL, resourcePath: self.ALLOW_ALL, permission: ["GET"], callback: { res in
					// user-specific permissions are in effect
					self.pc().isAllowedTo(self.u().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
						XCTAssertTrue(res)
						_23.fulfill()
					})
					self.pc().isAllowedTo(self.u().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
						XCTAssertFalse(res)
						_24.fulfill()
					})
					self.pc().isAllowedTo(self.u().id, resourcePath: self.catsType, httpMethod: "PUT", callback: { res in
						XCTAssertTrue(res)
						_25.fulfill()
					})
					self.pc().isAllowedTo(self.u().id, resourcePath: self.catsType, httpMethod: "GET", callback: { res in
						XCTAssertTrue(res)
						_26.fulfill()
					})

					self.pc().revokeAllResourcePermissions(self.u().id, callback: { res in
						// user-specific permissions not found so check wildcard
						self.pc().isAllowedTo(self.u().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
							XCTAssertFalse(res)
							_27.fulfill()
						})
						self.pc().isAllowedTo(self.u().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
							XCTAssertTrue(res)
							_28.fulfill()
						})
						self.pc().isAllowedTo(self.u().id, resourcePath: self.catsType, httpMethod: "PUT", callback: { res in
							XCTAssertTrue(res)
							_29.fulfill()
						})
						self.pc().isAllowedTo(self.u().id, resourcePath: self.catsType, httpMethod: "GET", callback: { res in
							XCTAssertTrue(res)
							self.pc().revokeResourcePermission(self.ALLOW_ALL, resourcePath: self.catsType, callback: { res in
								// resource-specific permissions not found so check wildcard
								self.pc().isAllowedTo(self.u().id, resourcePath: self.dogsType, httpMethod: "PUT", callback: { res in
									XCTAssertFalse(res)
									_30.fulfill()
								})
								self.pc().isAllowedTo(self.u().id, resourcePath: self.catsType, httpMethod: "PUT", callback: { res in
									XCTAssertFalse(res)
									_31.fulfill()
								})
								self.pc().isAllowedTo(self.u().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
									_32.fulfill()
								})
								self.pc().isAllowedTo(self.u().id, resourcePath: self.catsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
									_33.fulfill()
								})
								self.pc().isAllowedTo(self.u2().id, resourcePath: self.dogsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
									_34.fulfill()
								})
								self.pc().isAllowedTo(self.u2().id, resourcePath: self.catsType, httpMethod: "GET", callback: { res in
									XCTAssertTrue(res)
									self.pc().revokeAllResourcePermissions(self.ALLOW_ALL, callback: { _ in _35.fulfill() })
									self.pc().revokeAllResourcePermissions(self.u().id, callback: { _ in _36.fulfill() })
									_37.fulfill()
								})
								_38.fulfill()
							})
							_39.fulfill()
						})
						_40.fulfill()
					})
					_41.fulfill()
				})
				_42.fulfill()
			})
			_43.fulfill()
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
	}

	func testAppSettings() {
		let _1 = self.expectation(description: "1")
		let _2 = self.expectation(description: "2")
		let _3 = self.expectation(description: "3")
		let _4 = self.expectation(description: "4")
		let _5 = self.expectation(description: "5")
		let _6 = self.expectation(description: "6")
		let _7 = self.expectation(description: "7")
		let _8 = self.expectation(description: "8")
		let _9 = self.expectation(description: "9")
		let _10 = self.expectation(description: "10")
		let _11 = self.expectation(description: "11")
		let _12 = self.expectation(description: "12")
		let _13 = self.expectation(description: "13")
		let _14 = self.expectation(description: "14")

		pc().appSettings(callback: { res in
			XCTAssertNotNil(res)
			XCTAssertTrue((res?.count)! == 0)

			self.pc().appSettings(" ", callback: { res in
				XCTAssertNotNil(res)
				XCTAssertTrue((res?.count)! == 0)
				_1.fulfill()
			})

			self.pc().appSettings(nil, callback: { res in
				XCTAssertNotNil(res)
				XCTAssertTrue((res?.count)! == 0)
				_2.fulfill()
			})

			self.pc().addAppSetting("prop1", value: 1 as AnyObject, callback: { res in
				self.pc().addAppSetting("prop2", value: true as AnyObject, callback: { res in
					self.pc().addAppSetting("prop3", value: "string" as AnyObject, callback: { res in
						self.pc().appSettings(callback: { res in
							XCTAssertNotNil(res)
							XCTAssertTrue((res?.count)! == 3)

							self.pc().appSettings("prop1", callback: { res in
								XCTAssertTrue((res?["value"])! as! NSNumber == 1)
								_3.fulfill()
							})

							self.pc().appSettings("prop2", callback: { res in
								XCTAssertNotNil(res)
								XCTAssertTrue((res?["value"])! as! Bool)
								_4.fulfill()
							})

							self.pc().appSettings("prop3", callback: { res in
								XCTAssertNotNil(res)
								XCTAssertTrue(((res?["value"])! as! NSObject) as! String == "string")

								self.pc().removeAppSetting("prop3", callback: { res in
									self.pc().removeAppSetting("prop2", callback: { res in
										self.pc().removeAppSetting("prop1", callback: { res in
											self.pc().appSettings(callback: { res in
												XCTAssertTrue((res?.count)! == 0)
												_5.fulfill()
											})
											_6.fulfill()
										})
										_7.fulfill()
									})
									_8.fulfill()
								})
								_9.fulfill()
							})
							_10.fulfill()
						})
						_11.fulfill()
					})
					_12.fulfill()
				})
				_13.fulfill()
			})
			_14.fulfill()
		})

		self.waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error, "Test failed.")
		}
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

