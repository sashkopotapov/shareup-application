import Foundation

public enum LetterResult {
    case correct
    case wrongPosition
    case wrong
}

public func result(for try: String, word: String) -> [LetterResult] {
    var tryCopy: [Character?] = `try`.map { $0 }
    var letters: [Character?] = word.map { $0 }
    var result: [LetterResult?] = [nil, nil, nil, nil, nil]

    // First, pull out the correct characters
    for (index, character) in `try`.enumerated() {
        guard let characterInWord = letters[index] else { continue }
        guard character == characterInWord else { continue }
        result[index] = .correct
        letters[index] = nil
        tryCopy[index] = nil
    }

    // Second, pull out the characters in the wrong location
    for (index, character) in `try`.enumerated() {
        guard character == tryCopy[index],
              let indexOfCharacerInWord = letters.firstIndex(of: character)
        else { continue }
        result[index] = .wrongPosition
        letters[indexOfCharacerInWord] = nil
        tryCopy[index] = nil
    }

    return result.compactMap { $0 ?? .wrong }
}
