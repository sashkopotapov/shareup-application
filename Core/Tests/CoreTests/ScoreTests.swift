@testable import Core
import XCTest

final class ScoreTests: XCTestCase {
    func testDecodeScoreFromJSON() throws {
        let decoded = try JSONDecoder().decode(Score.self, from: scoreJSON)
        XCTAssertEqual(score, decoded)
    }

    func testEncodeScoreToJSON() throws {
        let encoded = try JSONEncoder().encode(score)
        let decoded = try JSONDecoder().decode(Score.self, from: encoded)
        XCTAssertEqual(score, decoded)
    }

    func testCanDecodeScoresResponse() throws {
        let decoded = try JSONDecoder()
            .decode(ScoresResponse.self, from: scoresResponseJSON)
        XCTAssertEqual(scores, decoded.scores)
    }

    func testDayDateSorting() throws {
        XCTAssertLessThan(
            DayDate(year: 2021, month: 12, day: 31),
            DayDate(year: 2022, month: 1, day: 1)
        )
        XCTAssertLessThan(
            DayDate(year: 2022, month: 11, day: 31),
            DayDate(year: 2022, month: 12, day: 1)
        )
        XCTAssertLessThan(
            DayDate(year: 2022, month: 12, day: 30),
            DayDate(year: 2022, month: 12, day: 31)
        )
        XCTAssertFalse(score.date < score.date)
    }
}

private extension ScoreTests {
    var score: Score {
        Score(
            id: 1,
            date: .init(year: 2022, month: 3, day: 1),
            word: "sweet",
            tries: ["corgi", "pause", "sleds", "sweet"]
        )
    }

    var scoreJSON: Data {
        Data("""
        {
            "id": 1,
            "date": "2022-03-01",
           "word": "sweet",
            "tries": [
                "corgi",
                "pause",
                "sleds",
                "sweet"
            ]
        }
        """.utf8)
    }

    var scores: [Score] {
        [
            Score(
                id: 264,
                date: .init(year: 2022, month: 3, day: 10),
                word: "lapse",
                tries: ["stair", "peony", "lapse"]
            ),
            Score(
                id: 263,
                date: .init(year: 2022, month: 3, day: 9),
                word: "month",
                tries: ["stair", "tuned", "monty", "month"]
            ),
            Score(
                id: 262,
                date: .init(year: 2022, month: 3, day: 8),
                word: "sweet",
                tries: ["corgi", "pause", "sleds", "sweet"]
            ),
        ]
    }

    var scoresResponseJSON: Data {
        Data("""
        {
          "scores": [
            {
              "id": 264,
              "date": "2022-03-10",
              "word": "lapse",
              "tries": [
                "stair",
                "peony",
                "lapse"
              ]
            },
            {
              "id": 263,
              "date": "2022-03-09",
              "word": "month",
              "tries": [
                "stair",
                "tuned",
                "monty",
                "month"
              ]
            },
            {
              "id": 262,
              "date": "2022-03-08",
              "word": "sweet",
              "tries": [
                "corgi",
                "pause",
                "sleds",
                "sweet"
              ]
            }
          ]
        }
        """.utf8)
    }
}
