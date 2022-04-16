import Combine
import Foundation

public struct Backend {
    public var getAllScores: () -> AnyPublisher<[Score], BackendError>
    public var addNewScore: (Score) -> AnyPublisher<Score, BackendError>
}

public extension Backend {
    var typeErasedGetAllScores: AnyPublisher<[Score], Error> {
        return getAllScores().mapError({ $0 as Error }).eraseToAnyPublisher()
    }
    
    var typeErasedAddNewScore: (Score) -> AnyPublisher<Score, Error> {
        return { addNewScore($0).mapError({ $0 as Error }).eraseToAnyPublisher() }
    }
}

public extension Backend {
    static func live(accessToken: String) -> Self {
        let session = URLSession(configuration: .default)
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        let url = URL(string: "https://wordle.shareup.fun/scores")
        
        return Self(getAllScores: {
            guard let url = url else {
                return Fail<[Score], BackendError>(
                    error: BackendError
                        .couldNotPrepareRequest
                )
                .eraseToAnyPublisher()
            }

            var request = URLRequest(url: url)
            request.addValue(accessToken, forHTTPHeaderField: "X-Authorization")

            return session
                .dataTaskPublisher(for: request)
                .mapError { BackendError.urlError($0) }
                .tryMap { (data: Data, response: URLResponse) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200
                    else { throw BackendError.invalidResponse(response) }
                    return data
                }
                .decode(type: ScoresResponse.self, decoder: decoder)
                .map(\.scores)
                .mapError { error in
                    if let backendError = error as? BackendError {
                        return backendError
                    } else {
                        return BackendError.decodingError(error as NSError)
                    }
                }
                .eraseToAnyPublisher()
        }, addNewScore: { score in
            guard let url = url else {
                return Fail<Score, BackendError>(
                    error: BackendError
                        .couldNotPrepareRequest
                )
                .eraseToAnyPublisher()
            }
            
            var request = URLRequest(url: url)
            request.addValue(accessToken, forHTTPHeaderField: "X-Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            do {
                request.httpBody = try encoder.encode(score)
            } catch {
                return Fail<Score, BackendError>(
                    error: BackendError
                        .encodingError(error as NSError)
                )
                .eraseToAnyPublisher()
            }
        
            return session
                .dataTaskPublisher(for: request)
                .mapError { BackendError.urlError($0) }
                .tryMap { (data: Data, response: URLResponse) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200
                    else { throw BackendError.invalidResponse(response) }
                    return data
                }
                .decode(type: Score.self, decoder: decoder)
                .mapError { error in
                    if let backendError = error as? BackendError {
                        return backendError
                    } else {
                        return BackendError.decodingError(error as NSError)
                    }
                }
                .eraseToAnyPublisher()
        })
    }

    #if DEBUG
        static var test: Self {
            Self(getAllScores: {
                Just([
                    .init(
                        id: 261,
                        date: .init(year: 2022, month: 3, day: 9),
                        word: "craze",
                        tries: ["grail", "track", "cramp", "crabs","crazy","craze"]
                    ),
                    .init(
                        id: 262,
                        date: .init(year: 2022, month: 3, day: 8),
                        word: "sweet",
                        tries: ["corgi", "pause", "sleds", "sweet"]
                    ),
                    .init(
                        id: 263,
                        date: .init(year: 2022, month: 3, day: 9),
                        word: "month",
                        tries: ["stair", "tuned", "monty", "month"]
                    ),
                    .init(
                        id: 264,
                        date: .init(year: 2022, month: 3, day: 10),
                        word: "lapse",
                        tries: ["stair", "peony", "lapse"]
                    ),
                ])
                .setFailureType(to: BackendError.self)
                .eraseToAnyPublisher()
            }, addNewScore: { score in
                return Just(score)
                    .setFailureType(to: BackendError.self)
                    .eraseToAnyPublisher()
            })
        }
    #endif
}

public enum BackendError: Error, Equatable {
    case couldNotPrepareRequest
    case urlError(URLError)
    case invalidResponse(URLResponse)
    case decodingError(NSError)
    case encodingError(NSError)
}
