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
	
	
//	func testBatchCRUD() {
//		var dogs = [ParaObject]()
//		for _ in 0...2 {
//			var s =  ParaObject()
//			s.type = dogsType
//			s.properties["foo"] = "bark!"
//			dogs.append(s)
//		}
//		
//		pc().createAll(nil,  {
//		 {
//		XCTAssertTrue(res.isEmpty())
//		}
//		})
//		
//		pc().createAll(dogs,  {
//		 {
//		List<ParaObject> l1 = res
//		XCTAssertEqual(3, l1.size())
//		XCTAssertNotNil(l1.get(0).id)
//		
//		ArrayList<String> nl =  ArrayList<String>(3)
//		nl.add(l1.get(0).id)
//		nl.add(l1.get(1).id)
//		nl.add(l1.get(2).id)
//		pc().readAll(nl,  {
//		 {
//		List<ParaObject> l2 = res
//		XCTAssertEqual(3, l2.size())
//		XCTAssertEqual(l1.get(0).id, l2.get(0).id)
//		XCTAssertEqual(l1.get(1).id, l2.get(1).id)
//		XCTAssertTrue((l2.get(0)).hasProperty("foo"))
//		XCTAssertEqual("bark!", (l2.get(0)).getProperty("foo"))
//		}
//		})
//		
//		ParaObject part1 =  ParaObject(l1.get(0).id)
//		ParaObject part2 =  ParaObject(l1.get(1).id)
//		ParaObject part3 =  ParaObject(l1.get(2).id)
//		part1.setType(dogsType)
//		part2.setType(dogsType)
//		part3.setType(dogsType)
//		
//		(part1).properties["custom", "prop")
//		part1.setName("NewName1")
//		part2.setName("NewName2")
//		part3.setName("NewName3")
//		
//		pc().updateAll(Arrays.asList(part1, part2, part3),  {
//		 {
//		List<ParaObject> l3 = res
//		
//		XCTAssertTrue((l3.get(0)).hasProperty("custom"))
//		XCTAssertEqual(dogsType, l3.get(0).getType())
//		XCTAssertEqual(dogsType, l3.get(1).getType())
//		XCTAssertEqual(dogsType, l3.get(2).getType())
//		
//		XCTAssertEqual(part1.getName(), l3.get(0).getName())
//		XCTAssertEqual(part2.getName(), l3.get(1).getName())
//		XCTAssertEqual(part3.getName(), l3.get(2).getName())
//		
//		pc().deleteAll(nl,  {
//		 {
//		sleep(1)
//		pc().list(dogsType, nil,  {
//		 {
//		XCTAssertTrue(res.isEmpty())
//		}
//		})
//		
//		pc().me( {
//		 {
//		Map<String, String> datatypes = (Map<String, String>)
//		((ParaObject)res).getProperty("datatypes")
//		XCTAssertTrue(datatypes.containsValue(dogsType))
//		}
//		})
//		}
//		})
//		}
//		})
//		}
//		})
//		
//		pc().readAll(nil,  {
//		 {
//		XCTAssertTrue(res.isEmpty())
//		}
//		})
//		pc().readAll(ArrayList<String>(0),  {
//		 {
//		XCTAssertTrue(res.isEmpty())
//		}
//		})
//		pc().updateAll(nil,  {
//			XCTAssertTrue(res.isEmpty())
//		})
//		pc().updateAll(ArrayList<ParaObject>(0),  {
//			XCTAssertTrue(res.isEmpty())
//		})
//	}

//
//	func testList() {
//	var cats =  ArrayList<ParaObject>()
//	for (int i = 0 i < 3 i++) {
//	ParaObject s =  ParaObject(catsType + i)
//	s.setType(catsType)
//	cats.add(s)
//	}
//	
//	pc().list(nil, nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().list("", nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	
//	pc().createAll(cats,  {
//	 {
//	
//	sleep(1)
//	
//	pc().list(catsType, nil,  {
//	 {
//	List<ParaObject> list1 = res
//	XCTAssertFalse(list1.isEmpty())
//	XCTAssertEqual(3, list1.size())
//	XCTAssertEqual(ParaObject.class, list1.get(0).getClass())
//	}
//	})
//	
//	pc().list(catsType, Pager(2),  {
//	 {
//	List<ParaObject> list2 = res
//	XCTAssertFalse(list2.isEmpty())
//	XCTAssertEqual(2, list2.size())
//	
//	ArrayList<String> nl =  ArrayList<String>(3)
//	nl.add(cats.get(0).id)
//	nl.add(cats.get(1).id)
//	nl.add(cats.get(2).id)
//	
//	pc().deleteAll(nl,  {
//	 {
//	pc().me( {
//	 {
//	Map<String, String> datatypes = (Map<String, String>)
//	((ParaObject)res).getProperty("datatypes")
//	XCTAssertTrue(datatypes.containsValue(catsType))
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	
//	
//	func testSearch() {
//	pc().findById(nil,  {
//	 {
//	XCTAssertNil(res)
//	}
//	})
//	pc().findById("",  {
//	 {
//	XCTAssertNil(res)
//	}
//	})
//	pc().findById(u().id,  {
//	 {
//	XCTAssertNotNil(res)
//	}
//	})
//	pc().findById(t().id,  {
//	 {
//	XCTAssertNotNil(res)
//	}
//	})
//	
//	pc().findByIds(nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findByIds(Arrays.asList(u().id, u1().id, u2().id),
//	 {
//	 {
//	XCTAssertEqual(3, res.size())
//	}
//	})
//	pc().findNearby(nil, nil, 100, 1, 1, nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findNearby(u().getType(), "*", 10, 40.60, -73.90, nil,
//	 {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	pc().findNearby(t().getType(), "*", 20, 40.62, -73.91, nil,
//	 {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	
//	pc().findPrefix(nil, nil, "", nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	
//	pc().findPrefix("", "nil", "xx", nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	
//	pc().findPrefix(u().getType(), "name", "ann", nil,  {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	
//	pc().findQuery(nil, nil, nil,  {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	pc().findQuery("", "*", nil,  {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	pc().findQuery(a1().getType(), "country:US", nil,  {
//	 {
//	XCTAssertEqual(2, res.size())
//	}
//	})
//	pc().findQuery(u().getType(), "ann", nil,  {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	pc().findQuery(u().getType(), "Ann", nil,  {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	pc().findQuery(nil, "*", nil,  {
//	 {
//	XCTAssertTrue(res.size() > 4)
//	}
//	})
//	
//	Pager p =  Pager()
//	XCTAssertEqual(0, p.getCount())
//	pc().findQuery(u().getType(), "*", p,  {
//	 {
//	XCTAssertEqual(res.size(), p.getCount())
//	XCTAssertTrue(p.getCount() > 0)
//	}
//	})
//	
//	pc().findSimilar(t().getType(), "", nil, nil, nil,
//	 {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findSimilar(t().getType(), "", String[0], "", nil,
//	 {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findSimilar(s1().getType(), s1().id, {"name"}, s1().getName(), nil,
//	 {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	XCTAssertEqual(s2(), res.get(0))
//	}
//	})
//	
//	pc().findTagged(u().getType(), nil, nil,  {
//	 {
//	XCTAssertEqual(0, res.size())
//	}
//	})
//	pc().findTagged(u().getType(), {"two"}, nil,  {
//	 {
//	XCTAssertEqual(2, res.size())
//	}
//	})
//	pc().findTagged(u().getType(), {"one", "two"}, nil,  {
//	 {
//	XCTAssertEqual(1, res.size())
//	}
//	})
//	pc().findTagged(u().getType(), {"three"}, nil,  {
//	 {
//	XCTAssertEqual(3, res.size())
//	}
//	})
//	pc().findTagged(u().getType(), {"four", "three"}, nil,  {
//	 {
//	XCTAssertEqual(2, res.size())
//	}
//	})
//	pc().findTagged(u().getType(), {"five", "three"}, nil,  {
//	 {
//	XCTAssertEqual(1, res.size())
//	}
//	})
//	pc().findTagged(t().getType(), {"four", "three"}, nil,  {
//	 {
//	XCTAssertEqual(0, res.size())
//	}
//	})
//	
//	pc().findTags(nil, nil,  {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	pc().findTags("", nil,  {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	pc().findTags("unknown", nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findTags(t().getProperty("tag").description, nil,  {
//	 {
//	XCTAssertTrue(res.size() >= 1)
//	}
//	})
//	
//	pc().findTermInList(u().getType(), "id", Arrays.asList(u().id,
//	u1().id, u2().id, "xxx", "yyy"), nil,  {
//	 {
//	XCTAssertEqual(3, res.size())
//	}
//	})
//	
//	// many terms
//	Map<String, Object> terms =  [String: AnyObject]()
//	//		terms.put("type", u.getType())
//	terms.put("id", u().id)
//	
//	Map<String, Object> terms1 =  [String: AnyObject]()
//	terms1.put("type", nil)
//	terms1.put("id", " ")
//	
//	Map<String, Object> terms2 =  [String: AnyObject]()
//	terms2.put(" ", "bad")
//	terms2.put("", "")
//	
//	pc().findTerms(u().getType(), terms, true, nil,  {
//	 {
//	XCTAssertEqual(1, res.size())
//	}
//	})
//	pc().findTerms(u().getType(), terms1, true, nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findTerms(u().getType(), terms2, true, nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	
//	// single term
//	pc().findTerms(nil, nil, true, nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findTerms(u().getType(), Collections.singletonMap("", nil), true, nil,
//	 {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findTerms(u().getType(), Collections.singletonMap("", ""), true, nil,
//	 {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findTerms(u().getType(), Collections.singletonMap("term", nil), true, nil,
//	 {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findTerms(u().getType(), Collections.singletonMap("type", u().getType()), true, nil,
//	 {
//	 {
//	XCTAssertTrue(res.size() >= 2)
//	}
//	})
//	
//	pc().findWildcard(u().getType(), nil, nil, nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findWildcard(u().getType(), "", "", nil,  {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().findWildcard(u().getType(), "name", "an*", nil,  {
//	 {
//	XCTAssertFalse(res.isEmpty())
//	}
//	})
//	
//	pc().getCount(nil, Listener<Long>() {
//	 {
//	XCTAssertTrue(res.intValue() > 4)
//	}
//	})
//	pc().getCount("", Listener<Long>() {
//	 {
//	XCTAssertNotEqual(0, res.intValue())
//	}
//	})
//	pc().getCount("test", Listener<Long>() {
//	 {
//	XCTAssertEqual(0, res.intValue())
//	}
//	})
//	pc().getCount(u().getType(), Listener<Long>() {
//	 {
//	XCTAssertTrue(res.intValue() >= 3)
//	}
//	})
//	
//	pc().getCount(nil, nil, Listener<Long>() {
//	 {
//	XCTAssertEqual(0, res.intValue())
//	}
//	})
//	pc().getCount(u().getType(), Collections.singletonMap("id", " "), Listener<Long>() {
//	 {
//	XCTAssertEqual(0, res.intValue())
//	}
//	})
//	pc().getCount(u().getType(), Collections.singletonMap("id", u().id), Listener<Long>() {
//	 {
//	XCTAssertEqual(1, res.intValue())
//	}
//	})
//	pc().getCount(nil, Collections.singletonMap("type", u().getType()), Listener<Long>() {
//	 {
//	XCTAssertTrue(res.intValue() > 1)
//	}
//	})
//	}
//	
//	
//	public void testLinks() {
//	pc().link(u(), t().id,  {
//	public void onResponse(String res) {
//	XCTAssertNotNil(res)
//	pc().link(u(), u2().id,  {
//	public void onResponse(String res) {
//	XCTAssertNotNil(res)
//	
//	pc().isLinked(u(), nil,  {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	pc().isLinked(u(), t(),  {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isLinked(u(), u2(),  {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	
//	pc().getLinkedObjects(u(), "tag", nil,  {
//	 {
//	XCTAssertEqual(1, res.size())
//	}
//	})
//	pc().getLinkedObjects(u(), "ParaObject", nil,  {
//	 {
//	XCTAssertEqual(1, res.size())
//	}
//	})
//	
//	pc().countLinks(u(), nil, Listener<Long>() {
//	 {
//	XCTAssertEqual(0, res.intValue())
//	}
//	})
//	pc().countLinks(u(), "tag", Listener<Long>() {
//	 {
//	XCTAssertEqual(1, res.intValue())
//	}
//	})
//	pc().countLinks(u(), "ParaObject", Listener<Long>() {
//	 {
//	XCTAssertEqual(1, res.intValue())
//	}
//	})
//	
//	pc().unlinkAll(u(), Listener<Map>() {
//	 {
//	pc().isLinked(u(), t(),  {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	pc().isLinked(u(), u2(),  {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	}, ErrorListener() {
//	public void onErrorResponse(VolleyError volleyError) {
//	fail("Link test failed.")
//	}
//	})
//	}
//	
//	
//	public void testUtils() {
//	pc().newId( {
//	 {
//	pc().newId( {
//	 {
//	XCTAssertNotNil(id1)
//	XCTAssertFalse(id1.isEmpty())
//	XCTAssertNotEqual(id1, id2)
//	}
//	})
//	}
//	})
//	
//	pc().getTimestamp( {
//	 {
//	XCTAssertNotNil(ts)
//	XCTAssertNotEqual(0, ts.intValue())
//	}
//	})
//	
//	pc().formatDate("MM dd yyyy", Locale.US,  {
//	 {
//	String date2 =  SimpleDateFormat("MM dd yyyy").format(Date())
//	XCTAssertEqual(date1, date2)
//	}
//	})
//	
//	pc().noSpaces(" test  123		test ", "",  {
//	 {
//	String ns2 = "test123test"
//	XCTAssertEqual(ns1, ns2)
//	}
//	})
//	
//	pc().stripAndTrim(" %^&*( cool )		@!",  {
//	 {
//	String st2 = "cool"
//	XCTAssertEqual(st1, st2)
//	}
//	})
//	
//	pc().markdownToHtml("### hello **test**",  {
//	 {
//	String md2 = "<h3>hello <strong>test</strong></h3>"
//	XCTAssertEqual(md1.trim(), md2)
//	}
//	})
//	
//	pc().approximately(15000,  {
//	 {
//	String ht2 = "15s"
//	XCTAssertEqual(ht1, ht2)
//	}
//	})
//	}
//	
//	
//	public void testMisc() {
//	pc().types( {
//	 {
//	XCTAssertNotNil(types)
//	XCTAssertFalse(types.isEmpty())
//	XCTAssertTrue(types.containsKey("users"))
//	}
//	})
//	
//	pc().me( {
//	 {
//	XCTAssertEqual(APP_ID, app.id)
//	}
//	})
//	}
//	
//	
//	public void testValidationConstraints() {
//	// Validations
//	String kittenType = "kitten"
//	pc().validationConstraints(
//	 {
//	 {
//	XCTAssertNotNil(constraints)
//	XCTAssertFalse(constraints.isEmpty())
//	XCTAssertTrue(constraints.containsKey("app"))
//	XCTAssertTrue(constraints.containsKey("user"))
//	}
//	})
//	
//	pc().validationConstraints("app",
//	 {
//	 {
//	XCTAssertFalse(constraint.isEmpty())
//	XCTAssertTrue(constraint.containsKey("app"))
//	XCTAssertEqual(1, constraint.size())
//	}
//	})
//	
//	pc().addValidationConstraint(kittenType, "paws", required(),
//	 {
//	 {
//	pc().validationConstraints(kittenType,
//	 {
//	 {
//	XCTAssertTrue(constraint.get(kittenType).containsKey("paws"))
//	
//	ParaObject ct =  ParaObject("felix")
//	ct.setType(kittenType)
//	// validation fails
//	pc().create(ct,  {
//	 {
//	XCTAssertNil(res)
//	// fix
//	ct.properties["paws", "4")
//	pc().create(ct,  {
//	 {
//	XCTAssertNotNil(res)
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	})
//	
//	
//	pc().removeValidationConstraint(kittenType, "paws", "required",
//	 {
//	 {
//	pc().validationConstraints(kittenType,
//	 {
//	 {
//	XCTAssertFalse(constraint.containsKey(kittenType))
//	}
//	})
//	}
//	})
//	}
//	
//	
//	public void testResourcePermissions() {
//	// Permissions
//	pc().resourcePermissions( {
//	 {
//	XCTAssertNotNil(res)
//	}
//	})
//	pc().grantResourcePermission(nil, dogsType, String[0],
//	 {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	pc().grantResourcePermission(" ", "", String[0],
//	 {
//	 {
//	XCTAssertTrue(res.isEmpty())
//	}
//	})
//	
//	pc().grantResourcePermission(u1().id, dogsType, {"GET"},
//	 {
//	 {
//	pc().resourcePermissions(u1().id,  {
//	 {
//	XCTAssertTrue(permits.containsKey(u1().id))
//	XCTAssertTrue(permits.get(u1().id).containsKey(dogsType))
//	pc().isAllowedTo(u1().id, dogsType, "GET",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, dogsType, "POST",
//	 {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	}
//	})
//	
//	// anonymous permissions
//	pc().isAllowedTo(ALLOW_ALL, "utils/timestamp", "GET",  {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	pc().grantResourcePermission(ALLOW_ALL, "utils/timestamp", {"GET"}, true,
//	 {
//	 {
//	XCTAssertNotNil(res)
//	pc2().getTimestamp(Listener<Long>() {
//	 {
//	XCTAssertTrue(res > 0)
//	}
//	})
//	
//	pc().isAllowedTo("*", "utils/timestamp", "DELETE",  {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	}
//	})
//	
//	pc().resourcePermissions( {
//	 {
//	XCTAssertTrue(permits.containsKey(u1().id))
//	XCTAssertTrue(permits.get(u1().id).containsKey(dogsType))
//	}
//	})
//	
//	pc().revokeResourcePermission(u1().id, dogsType,
//	 {
//	 {
//	pc().resourcePermissions(u1().id,
//	 {
//	 {
//	XCTAssertFalse(permits.get(u1().id).containsKey(dogsType))
//	pc().isAllowedTo(u1().id, dogsType, "GET",
//	 {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, dogsType, "POST",
//	 {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	})
//	
//	String[] WRITE =  String[]{"POST", "PUT", "PATCH", "DELETE"}
//	
//	pc().grantResourcePermission(u2().id, ALLOW_ALL, WRITE,
//	 {
//	 {
//	pc().isAllowedTo(u2().id, dogsType, "PUT",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isAllowedTo(u2().id, dogsType, "PATCH",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	
//	pc().revokeAllResourcePermissions(u2().id,
//	 {
//	 {
//	pc().resourcePermissions( {
//	 {
//	pc().isAllowedTo(u2().id, dogsType, "PUT",
//	 {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	XCTAssertFalse(permits.containsKey(u2().id))
//	}
//	})
//	
//	}
//	})
//	}
//	})
//	
//	pc().grantResourcePermission(u1().id, dogsType, WRITE,
//	 {
//	 {
//	pc().grantResourcePermission(ALLOW_ALL, catsType, WRITE,
//	 {
//	 {
//	pc().grantResourcePermission(ALLOW_ALL, ALLOW_ALL, {"GET"},
//	 {
//	 {
//	// user-specific permissions are in effect
//	pc().isAllowedTo(u1().id, dogsType, "PUT",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, dogsType, "GET",
//	 {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, catsType, "PUT",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, catsType, "GET",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	
//	pc().revokeAllResourcePermissions(u1().id,
//	 {
//	 {
//	// user-specific permissions not found so check wildcard
//	pc().isAllowedTo(u1().id, dogsType, "PUT",
//	 {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, dogsType, "GET",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, catsType, "PUT",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, catsType, "GET",
//	 {
//	 {
//	XCTAssertTrue(res)
//	pc().revokeResourcePermission(ALLOW_ALL, catsType,
//	 {
//	 {
//	// resource-specific permissions not found so check wildcard
//	pc().isAllowedTo(u1().id, dogsType, "PUT",
//	 {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, catsType, "PUT",
//	 {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, dogsType, "GET",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isAllowedTo(u1().id, catsType, "GET",
//	 {
//	 {
//	XCTAssertTrue(res)
//	}
//	})
//	pc().isAllowedTo(u2().id, dogsType, "GET",
//	 {
//	 {
//	XCTAssertTrue(res)
//	
//	}
//	})
//	pc().isAllowedTo(u2().id, catsType, "GET",
//	 {
//	 {
//	XCTAssertTrue(res)
//	pc().revokeAllResourcePermissions(ALLOW_ALL, nil)
//	pc().revokeAllResourcePermissions(u1().id, nil)
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	})
//	}
//	
//	
//	public void testAccessTokens() {
//	XCTAssertNil(pc().getAccessToken())
//	pc().signIn("facebook", "test_token",  {
//	 {
//	XCTAssertNil(res)
//	}
//	})
//	pc().signOut()
//	pc().revokeAllTokens( {
//	 {
//	XCTAssertFalse(res)
//	}
//	})
//	}
	
	
	
	
	
	
}

