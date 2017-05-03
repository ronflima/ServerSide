import XCTest
@testable import ServerSide

public class ServerSideTests: XCTestCase {

    func testCreation() {
        XCTAssertNotEqual(Server.main.pid, 0)
    }

    static var allTests : [(String, (ServerSideTests) -> () throws -> Void)] {
        return [
            ("testCreation", testCreation),
        ]
    }
}
