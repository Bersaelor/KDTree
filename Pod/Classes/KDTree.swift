//
//  KDTree+Equatable.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import Foundation

private enum ReplacementDirection {
    case Max
    case Min
}

public enum KDTree<Element: KDTreePoint> {
    case Leaf
    indirect case Node(left: KDTree<Element>, value: Element, dimension: Int, right: KDTree<Element>)
    //    case Node(left: KDTree<Element>, value: T, parent: KDTree<Element>?, right: KDTree<Element>)

    public init(values: [Element], depth: Int = 0) {
        guard !values.isEmpty else {
            self = .Leaf
            return
        }
        
        let currentSplittingDimension = depth % Element.dimensions
        if values.count == 1, let firstValue = values.first {
            self = .Node(left: .Leaf, value: firstValue, dimension: currentSplittingDimension, right: .Leaf)
        }
        else {
            let sortedValues = values.sorted { (a, b) -> Bool in
                return a.kdDimension(currentSplittingDimension) < b.kdDimension(currentSplittingDimension)
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
            var mappedTs = left.elements
            mappedTs.append(value)
            mappedTs.append(contentsOf: right.elements)
            return mappedTs
        }
    }
    
    /// Returns `true` iff `element` is in `self`.
    public func contains(_ value: Element) -> Bool {
        switch self {
        case .Leaf:
            return false
        case let .Node(left, v, dim, right):
            if value == v { return true }
            else {
                if value.kdDimension(dim) < v.kdDimension(dim) {
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
    public func insert(_ newValue: Element, dim: Int = 0) -> KDTree {
        switch self {
        case .Leaf:
            return .Node(left: .Leaf, value: newValue, dimension: dim, right: .Leaf)
        case let .Node(left, value, dim, right):
            if value == newValue { return self }
            else {
                let nextDim = (dim + 1) % Element.dimensions
                if newValue.kdDimension(dim) < value.kdDimension(dim) {
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
    public func remove(_ valueToBeRemoved: Element, dim: Int = 0) -> KDTree {
        switch self {
        case .Leaf:
            return self
        case let .Node(left, value, dim, right):
            if value == valueToBeRemoved {
                let (newLeftSubTree, leftReplacementValue) = left.findBestReplacement(dim, direction: ReplacementDirection.Max)
                if let replacement = leftReplacementValue {
                    return KDTree.Node(left: newLeftSubTree, value: replacement, dimension: dim, right: right)
                }

                let (newRightSubTree, rightReplacementValue) = right.findBestReplacement(dim, direction: ReplacementDirection.Min)
                if let replacement = rightReplacementValue {
                    return KDTree.Node(left: left, value: replacement, dimension: dim, right: newRightSubTree)
                }
                
                //if neither left nor right has a replacement we can safely return an empty leaf
                return KDTree.Leaf
            }
            else {
                let nextDim = (dim + 1) % Element.dimensions
                if valueToBeRemoved.kdDimension(dim) < value.kdDimension(dim) {
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
    
    private func findBestReplacement(_ dimOfCut: Int, direction: ReplacementDirection) -> (KDTree, Element?) {
        switch self {
        case .Leaf:
            return (self, nil)
        case .Node(let left, let value, let dim, let right):
            if dim == dimOfCut {
                //look at the best side of the split for the best replacement
                let subTree = (direction == .Min) ? left : right
                let (newSubTree, replacement) = subTree.findBestReplacement(dim, direction: direction)
                if let replacement = replacement {
                    if direction == .Min { return (.Node(left: newSubTree, value: value, dimension: dim, right: right), replacement) }
                    else { return (.Node(left: left, value: value, dimension: dim, right: newSubTree), replacement) }
                }
                //the own point is the optimum!
                return (self.remove(value), value)
            }
            else {
                //look at both side and the value and find the min/max regarding f() along the dimOfCut
                let nilDropIn = (direction == .Min) ? Double.infinity : -Double.infinity

                let (newLeftSubTree, leftReplacementValue) = left.findBestReplacement(dimOfCut, direction: direction)
                let (newRightSubTree, rightReplacementValue) = right.findBestReplacement(dimOfCut, direction: direction)
                let dimensionValues: [Double] = [leftReplacementValue, rightReplacementValue, value].map({ element -> Double in
                    return element.flatMap({ $0.kdDimension(dimOfCut) }) ?? nilDropIn
                })
                let optimumValue = (direction == .Min) ? dimensionValues.min() : dimensionValues.max()
                if let bestValue = leftReplacementValue where dimensionValues[0] == optimumValue {
                    return (.Node(left: newLeftSubTree, value: value, dimension: dim, right: right), bestValue)
                }
                else if let bestValue = rightReplacementValue where dimensionValues[1] == optimumValue {
                    return (.Node(left: left, value: value, dimension: dim, right: newRightSubTree), bestValue)
                }
                else { //the own point is the optimum!
                    return (self.remove(value), value)
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
    public func mapToArray<T>(_ transform: @noescape (Element) throws -> T) rethrows -> [T] {
        switch self {
        case .Leaf:
            return []
        case let .Node(left, value, _, right):
            var mappedTs = try left.mapToArray(transform)
            try mappedTs.append(transform(value))
            try mappedTs.append(contentsOf: right.mapToArray(transform))
            return mappedTs
        }
    }

    /// Returns a `KDTree` containing the results of mapping `transform`
    /// over `self`. 
    /// **IMPORTANT NOTE:** In general the resulting Tree won't be balanced at all. There are however specific cases 
    /// where a map would keep the balance intact.
    ///
    /// - Complexity: O(N).
    public func map<T: KDTreePoint>(_ transform: @noescape (Element) throws -> T) rethrows -> KDTree<T> {
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
    public func filter(_ includeElement: @noescape (Element) throws -> Bool) rethrows -> KDTree {
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
    public func forEach(_ body: @noescape (Element) throws -> Void) rethrows {
        switch self {
        case .Leaf:
            return
        case let .Node(left, value, _, right):
            try left.forEach(body)
            try body(value)
            try right.forEach(body)
        }
    }
    
    /// Call `body` on each node in `self` in the same order as a
    /// *for-in loop.*
    public func investigateTree(parents: [KDTree] = [], depth: Int = 0, body: (node: KDTree, parents: [KDTree], depth: Int) -> Void) {
        switch self {
        case .Leaf:
            return
        case let .Node(left, _, _, right):
            body(node: self, parents: parents, depth: depth)
            let nextParents = [self] + parents
            left.investigateTree(parents: nextParents, depth: depth+1, body: body)
            right.investigateTree(parents: nextParents, depth: depth+1, body: body)
        }
    }
    
    /// Returns the result of repeatedly calling `combine` with an
    /// accumulated value initialized to `initial` and each element of
    /// `self`, in turn, i.e. return
    /// `combine(combine(...combine(combine(initial, self[0]),
    /// self[1]),...self[count-2]), self[count-1])`.
    public func reduce<T>(_ initial: T, @noescape combine: (T, Element) throws -> T) rethrows -> T {
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
