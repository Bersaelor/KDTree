//
//  KDTree+Sequence.swift
//  Pods
//
//  Created by Konrad Feiler on 25/03/2017.
//
//

import Foundation

extension KDTree: Sequence {
    
//    public func makeIterator() -> KDTreeIterator {
    public func makeIterator() -> AnyIterator<Element> {
        
        switch self {
        case .leaf: return AnyIterator { return nil }
        case let .node(left, value, _, right):
            var index = 0
            var leftIterator: AnyIterator<Element>? = left.makeIterator()
            var rightIterator: AnyIterator<Element>? = right.makeIterator()

            return AnyIterator {
                if index == 0 {
                    index = 1
                    return value
                }
                else if index == 1, let nextValue = leftIterator?.next() {
                    return nextValue
                }
                else {
                    index = 2
                    return rightIterator?.next()
                }
            }
            
        }
    }
}
