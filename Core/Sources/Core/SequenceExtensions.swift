//
//  File.swift
//  
//
//  Created by Oleksandr Potapov on 20.04.2022.
//

import Foundation

public extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted(by: { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        })
    }
}
