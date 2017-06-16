import XCTest
import Venice

@testable import ServerSide

public class ServerSideTests: XCTestCase {
    func testGracefulStop() throws {
        var stop = false
        try ServerSide.current.start { (arguments) in
            while !stop {
                do {
                    try Coroutine.yield()
                } catch {
                    stop = true
                }
            }
        }
        var called = false
        ServerSide.current.atExit = {
            called = true
        }
        try ServerSide.current.stop()
        XCTAssertEqual(called, true, "Failed to call atExit")
    }

    static var allTests : [(String, (ServerSideTests) -> () throws -> Void)] {
        return [
            ("testGracefulStop", testGracefulStop),
        ]
    }
}
