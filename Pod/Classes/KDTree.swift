//
//  KDTree+Equatable.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import Foundation

public enum KDTree<Element: KDTreePoint> {
    case Leaf
    indirect case Node(left: KDTree<Element>, value: Element, dimension: Int, right: KDTree<Element>)
    //    case Node(left: KDTree<Element>, value: T, parent: KDTree<Element>?, right: KDTree<Element>)

    public init(values: [Element], depth: Int = 0) {
        guard !values.isEmpty else {
            self = .Leaf
            return
        }
        
        let currentSplittingDimension = depth % Element.kdDimensionFunctions.count
        if values.count == 1, let firstValue = values.first {
            self = .Node(left: .Leaf, value: firstValue, dimension: currentSplittingDimension, right: .Leaf)
        }
        else {
            let sortedValues = values.sort { (a, b) -> Bool in
                let f = Element.kdDimensionFunctions[currentSplittingDimension]
                return f(a) < f(b)
            }
            let median = sortedValues.count / 2
            let leftTree = KDTree(values: Array(sortedValues[0..<median]), depth: depth+1)
            let rightTree = KDTree(values: Array(sortedValues[median+1..<sortedValues.count]), depth: depth+1)
            
            self = KDTree.Node(left: leftTree, value: sortedValues[median],
                               dimension: currentSplittingDimension, right: rightTree)
        }
    }
    
    /// Returns `true` iff `self` is empty.
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        switch self {
        case .Leaf: return true
        default: return false
        }
    }
    
    /// The number of elements the KDTree stores.
    public var count: Int {
        switch self {
        case .Leaf:
            return 0
        case let .Node(left, _, _, right):
            return 1 + left.count + right.count
        }
    }
    
    /// The elements the KDTree stores as an Array.
    public var elements: [Element] {
        switch self {
        case .Leaf:
            return []
        case let .Node(left, value, _, right):
            return [value] + left.elements + right.elements
        }
    }
    
    /// Returns `true` iff `element` is in `self`.
    public func contains(value: Element) -> Bool {
        switch self {
        case .Leaf:
            return false
        case let .Node(left, v, dim, right):
            if value == v { return true }
            else {
                let f = Element.kdDimensionFunctions[dim]
                if f(value) < f(v) {
                    return left.contains(value)
                }
                else {
                    return right.contains(value)
                }
            }
        }
    }
    
    /// Return a KDTree with the element inserted. Tree might not be balanced anymore after this
    ///
    /// - Complexity: O(n log n )..
    public func insert(newValue: Element, dim: Int = 0) -> KDTree {
        switch self {
        case .Leaf:
            return .Node(left: .Leaf, value: newValue, dimension: dim, right: .Leaf)
        case let .Node(left, value, dim, right):
            if value == newValue { return self }
            else {
                let f = Element.kdDimensionFunctions[dim]
                let nextDim = (dim + 1) % Element.kdDimensionFunctions.count
                if f(newValue) < f(value) {
                    return KDTree.Node(left: left.insert(newValue, dim: nextDim), value: value,
                                       dimension: dim, right: right)
                }
                else {
                    return KDTree.Node(left: left, value: value, dimension: dim,
                                       right: right.insert(newValue, dim: nextDim))
                }
            }
        }    
    }
    
    /// Return a KDTree with the element removed.
    ///
    /// If element is not contained the new KDTree will be equal to the old one
    public func remove(valueToBeRemoved: Element, dim: Int = 0) -> KDTree {
        switch self {
        case .Leaf:
            return self
        case let .Node(left, value, dim, right):
            if value == valueToBeRemoved {
                //TODO: could be optimized by finding an appropriate replacement value from the subtree
                return KDTree(values: left.elements + right.elements)
            }
            else {
                let f = Element.kdDimensionFunctions[dim]
                let nextDim = (dim + 1) % Element.kdDimensionFunctions.count
                if f(valueToBeRemoved) < f(value) {
                    return KDTree.Node(left: left.remove(valueToBeRemoved, dim: nextDim), value: value,
                                       dimension: dim, right: right)
                }
                else {
                    return KDTree.Node(left: left, value: value, dimension: dim,
                                       right: right.remove(valueToBeRemoved, dim: nextDim))
                }
            }
        }
    }
    
    /// Return the maximum distance of this KDTrees farthest leaf
    public var depth: Int {
        switch self {
        case .Leaf:
            return 0
        case let .Node(left, _, _, right):
            let maxSubTreeDepth = max(left.depth, right.depth)
            return 1 + maxSubTreeDepth
        }
    }
}

extension KDTree { //SequenceType like
    
    /// Returns an `Array` containing the results of mapping `transform`
    /// over `self`.
    ///
    /// - Complexity: O(N).
    public func mapToArray<T>(@noescape transform: (Element) throws -> T) rethrows -> [T] {
        switch self {
        case .Leaf:
            return []
        case let .Node(left, value, _, right):
            return try left.mapToArray(transform) + [transform(value)] + right.mapToArray(transform)
        }
    }

    /// Returns a `KDTree` containing the results of mapping `transform`
    /// over `self`. 
    /// **IMPORTANT NOTE:** In general the resulting Tree won't be balanced at all. There are however specific cases 
    /// where a map would keep the balance intact.
    ///
    /// - Complexity: O(N).
    public func map<T: KDTreeGrowing>(@noescape transform: (Element) throws -> T) rethrows -> KDTree<T> {
        switch self {
        case .Leaf:
            return .Leaf
        case let .Node(left, value, dim, right):
            let transformedValue = try transform(value)
            let leftTree = try left.map(transform)
            let rightTree = try right.map(transform)
            return KDTree<T>.Node(left: leftTree, value: transformedValue, dimension: dim, right: rightTree)
        }
    }

    /// Returns a `KDTree` containing the elements of `self`,
    /// in order, that satisfy the predicate `includeElement`.
    ///
    /// - Complexity: O(N).
    public func filter(@noescape includeElement: (Element) throws -> Bool) rethrows -> KDTree {
        switch self {
        case .Leaf:
            return self
        case let .Node(left, value, dim, right):
            if try !includeElement(value) {
                let filteredElements = try (left.elements + right.elements).filter(includeElement)
                return KDTree(values: filteredElements)
            }
            else {
                return try KDTree.Node(left: left.filter(includeElement), value: value,
                                       dimension: dim, right: right.filter(includeElement))
            }
        }
    }
    
    /// Call `body` on each element in `self` in the same order as a
    /// *for-in loop.*
    ///
    ///     kdTree.forEach {
    ///       // body code
    ///     }
    ///
    /// is similar to:
    ///
    ///     for element in sequence {
    ///       // body code
    ///     }
    ///
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    ///
    /// - Complexity: O(`self.count`)
    public func forEach(@noescape body: (Element) throws -> Void) rethrows {
        switch self {
        case .Leaf:
            return
        case let .Node(left, value, _, right):
            try left.forEach(body)
            try body(value)
            try right.forEach(body)
        }
    }
    
    /// Returns the result of repeatedly calling `combine` with an
    /// accumulated value initialized to `initial` and each element of
    /// `self`, in turn, i.e. return
    /// `combine(combine(...combine(combine(initial, self[0]),
    /// self[1]),...self[count-2]), self[count-1])`.
    public func reduce<T>(initial: T, @noescape combine: (T, Element) throws -> T) rethrows -> T {
        switch self {
        case .Leaf:
            return initial
        case let .Node(left, value, _, right):
            var result = try combine(initial, value)
            result = try left.reduce(result, combine: combine)
            result = try right.reduce(result, combine: combine)
            return result
        }
    }
}
