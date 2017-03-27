import XCTest
@testable import serverside

class serversideTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(serverside().text, "Hello, World!")
    }


    static var allTests : [(String, (serversideTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
