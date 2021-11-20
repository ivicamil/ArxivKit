import XCTest
@testable import ArxivKit

final class ArxivQueryTests: XCTestCase {
    
    func testEmptyQuery() {
        let q1 = term("")
        let q2 = term("", in: .abstract)
        let q3 = term("\n   \t\r \r\n")
        XCTAssert(q1.isEmpty)
        XCTAssert(q2.isEmpty)
        XCTAssert(q3.isEmpty)
    }
    
    func testTrimmedQuery() {
        let q = term("electron")
        let q1 = term(" electron  ")
        let q2 = term("\telectron")
        let q3 = term("\nelectron")
        XCTAssertEqual(q.string, q1.string)
        XCTAssertEqual(q.string, q2.string)
        XCTAssertEqual(q.string, q3.string)
    }
    
}

