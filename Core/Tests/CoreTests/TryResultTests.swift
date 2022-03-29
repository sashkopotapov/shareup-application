@testable import Core
import XCTest

final class TryResultTests: XCTestCase {
    func testResultForTryAndWord() throws {
        XCTAssertEqual(
            [.wrong, .wrong, .correct, .wrong, .wrongPosition],
            result(for: "mommy", word: "nymph")
        )

        XCTAssertEqual(
            [.wrongPosition, .wrong, .wrong, .correct, .wrong],
            result(for: "yelps", word: "nymph")
        )

        XCTAssertEqual(
            [.wrongPosition, .wrongPosition, .wrong, .wrong, .wrong],
            result(for: "eerie", word: "sweet")
        )

        XCTAssertEqual(
            [.correct, .correct, .correct, .correct, .correct],
            result(for: "sweet", word: "sweet")
        )
    }
}
