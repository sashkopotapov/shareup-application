import Core
import Foundation
import OrderedCollections

typealias ScoresCollection = OrderedDictionary<Int, Score>

extension OrderedDictionary where Key == Int, Value == Score {
    init(_ values: [Value]) {
        self.init(uniqueKeysWithValues: values.map { ($0.id, $0) })
    }
}
