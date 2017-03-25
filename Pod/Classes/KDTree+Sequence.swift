//
//  KDTree+Sequence.swift
//  Pods
//
//  Created by Konrad Feiler on 25/03/2017.
//
//

import Foundation

extension KDTree: Sequence {
    
    public func makeIterator() -> AnyIterator<Element> {
        
        switch self {
        case .leaf: return AnyIterator { return nil }
        case let .node(left, value, _, right):
            var index = 0
            var iteratorStruct = KDTreeIteratorStruct(left: left, right: right)

            return AnyIterator {
                if index == 0 {
                    index = 1
                    return value
                }
                else if index == 1, let nextValue = iteratorStruct.leftIterator?.next() {
                    return nextValue
                }
                else {
                    index = 2
                    return iteratorStruct.rightIterator?.next()
                }
            }
            
        }
    }
}

fileprivate struct KDTreeIteratorStruct<Element: KDTreePoint> {
    let left: KDTree<Element>
    let right: KDTree<Element>
    
    init(left: KDTree<Element>, right: KDTree<Element>) {
        self.left = left
        self.right = right
    }
    
    lazy var leftIterator: AnyIterator<Element>? = { return self.left.makeIterator() }()
    lazy var rightIterator: AnyIterator<Element>? = { return self.right.makeIterator() }()
}
