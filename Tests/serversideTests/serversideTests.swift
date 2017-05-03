import XCTest
@testable import ServerSide

class serversideTests: XCTestCase {

    func testCreation() {
        XCTAssertNotEqual(Server.default.pid, 0)
    }

    static var allTests : [(String, (serversideTests) -> () throws -> Void)] {
        return [
            ("testCreation", testCreation),
        ]
    }
}
