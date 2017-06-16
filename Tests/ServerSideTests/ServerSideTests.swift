import XCTest
import Venice

@testable import ServerSide

public class ServerSideTests: XCTestCase {
    func testGracefulStop() throws {
        var stop = false
        try Server.current.start { (arguments) in
            while !stop {
                do {
                    try Coroutine.yield()
                } catch {
                    stop = true
                }
            }
        }
        var called = false
        Server.current.atExit = {
            called = true
        }
        try Server.current.stop()
        XCTAssertEqual(called, true, "Failed to call atExit")
    }

    static var allTests : [(String, (ServerSideTests) -> () throws -> Void)] {
        return [
            ("testGracefulStop", testGracefulStop),
        ]
    }
}
