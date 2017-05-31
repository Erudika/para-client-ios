import XCTest
@testable import para_client_ios

class para_client_iosTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(para_client_ios().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
