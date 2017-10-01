//
//  ValueIndexer.swift
//  SwiftyHYGDB
//
//  Created by Konrad Feiler on 01.10.17.
//

import Foundation

protocol IndexerValue: Hashable {
    func isValid() -> Bool
}
 
struct Indexer<Value: IndexerValue> {
    private var collectedValues = [Value: Int16]()

    mutating func index(for value: Value?) -> Int16 {
        guard let value = value, value.isValid() else { return Int16(SwiftyHYGDB.missingValueIndex) }
        if let existingValueNr = collectedValues[value] {
            return existingValueNr
        } else {
            let spectralTypeNr = Int16(collectedValues.count)
            collectedValues[value] = spectralTypeNr
            return spectralTypeNr
        }
    }
    
    func indexedValues() -> [Value] {
        return collectedValues.sorted(by: { (a, b) -> Bool in
            return a.value < b.value
        }).map { $0.key }
    }
}

extension Indexer {
    init(existingValues: [Value]) {
        for (key, value) in existingValues.enumerated().map({ ($1, Int16($0)) }) {
            collectedValues[key] = value
        }
    }
}
