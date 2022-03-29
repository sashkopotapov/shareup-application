import Foundation

public struct Score: Codable, Hashable {
    public var id: Int
    public var date: DayDate
    public var word: String
    public var tries: [String]

    public init(id: Int, date: DayDate, word: String, tries: [String]) {
        self.id = id
        self.date = date
        self.word = word
        self.tries = tries
    }
}

public struct DayDate: Comparable, Codable, Hashable {
    public var year: Int
    public var month: Int
    public var day: Int

    public var stringValue: String { String(format: "%04d-%02d-%02d", year, month, day) }

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public static func < (lhs: DayDate, rhs: DayDate) -> Bool {
        guard lhs.year >= rhs.year else { return true }
        guard lhs.month >= rhs.month else { return true }
        return lhs.day < rhs.day
    }

    public enum DecodingError: Error, Equatable {
        case invalidFormat(String)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        let components = string.components(separatedBy: "-").compactMap(Int.init)
        guard components.count == 3 else { throw DecodingError.invalidFormat(string) }
        year = components[0]
        month = components[1]
        day = components[2]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}
