//
//  KDTree+NearestNeighbour.swift
//
// Copyright (c) 2020 mathHeartCode UG(haftungsbeschränkt) <konrad@mathheartcode.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

// MARK: Nearest Neighbour
extension KDTree {
    
    /// Returns a the nearest `KDTreePoint` to the search point,
    /// If `element` is a member of the tree, the algorithm will return the closest other value
    /// Optional parameter 'maxDistance' if you are not interested in neighbours beyond a specified distance
    ///
    /// - Complexity: O(N log N).
    public func nearest(to element: Element, maxDistance: Double = Double.infinity, where condition: (Element) -> Bool = { _ in true }) -> Element? {
        guard !self.isEmpty else { return nil }
        
        return nearest(to: element, bestValue: nil, bestDistance: maxDistance, condition: condition).bestValue
    }
    
    fileprivate func nearest(to searchElement: Element, bestValue: Element?, bestDistance: Double, condition: (Element) -> Bool) -> (bestValue: Element?, bestDistance: Double) {
        switch self {
        case .leaf: break
        case let .node(.leaf, value, _, .leaf) where condition(value):
            let currentDistance = value.squaredDistance(to: searchElement)
            if currentDistance < bestDistance { return (value, currentDistance) }
        case let .node(left, value, dim, right):
            guard searchElement != value else { return (value, 0.0) }
            let dimensionDifference = value.kdDimension(dim) - searchElement.kdDimension(dim)
            let isLeftOfValue = dimensionDifference > 0
            
            //check the best estimate side
            let closerSubtree = isLeftOfValue ? left : right
            var (bestNewElement, bestNewDistance) = closerSubtree.nearest(to: searchElement, bestValue: bestValue, bestDistance: bestDistance, condition: condition)
            
            // if the bestDistance so far intersects the hyperplane at the other side of this value
            // there could be points in the other subtree
            if dimensionDifference*dimensionDifference < bestNewDistance {
                //check the nodes value
                if searchElement != value && condition(value) {
                    let currentDistance = value.squaredDistance(to: searchElement)
                    if currentDistance < bestNewDistance { (bestNewElement, bestNewDistance) = (value, currentDistance) }
                }
                
                let otherSubtree = isLeftOfValue ? right : left
                (bestNewElement, bestNewDistance) = otherSubtree.nearest(to: searchElement, bestValue: bestNewElement, bestDistance: bestNewDistance, condition: condition)
            }
            
            return (bestNewElement, bestNewDistance)
        }
        return (bestValue, bestDistance)
    }
}


private struct Neighbours {
    typealias ElementPair = (distance: Double, point: Any)

    fileprivate var nearestValues: [ElementPair] = []
    fileprivate let goalNumber: Int
    fileprivate var currentSize = 0
    fileprivate var full: Bool = false
    var biggestDistance: Double = Double.infinity
    
    init(goalNumber: Int) {
        nearestValues.reserveCapacity(goalNumber)
        self.goalNumber = goalNumber
    }
    
    mutating func append(_ value: Any, distance: Double) {
        guard !full || distance < biggestDistance else { return }

        if let index = nearestValues.firstIndex(where: { return distance < $0.distance }) {
            nearestValues.insert(ElementPair(distance: distance, point: value), at: index)
            if full {
                nearestValues.removeLast()
                biggestDistance = nearestValues.last!.distance
            }
            else {
                currentSize += 1
                full = currentSize >= goalNumber
            }
        }
        else {
            //not full so we append at the end
            nearestValues.append(ElementPair(distance: distance, point: value))
            currentSize += 1
            full = currentSize >= goalNumber
            biggestDistance = distance
        }
    }
}

// MARK: k Nearest Neighbour
extension KDTree {
    
    /// Returns the k nearest `KDTreePoint`s to the search point,
    ///
    /// - Complexity: O(log N).
    public func nearestK(_ number: Int, to searchElement: Element, where condition: (Element) -> Bool = { _ in true }) -> [Element] {
        var neighbours: Neighbours = Neighbours(goalNumber: number)
        self.nearestK(to: searchElement, bestValues: &neighbours, where: condition)
        return neighbours.nearestValues.map { $0.point as! Element }
    }
    

    fileprivate func nearestK(to searchElement: Element, bestValues: inout Neighbours, where condition: (Element) -> Bool) {
        switch self {
        case let .node(left, value, dim, right):
            let dimensionDifference = value.kdDimension(dim) - searchElement.kdDimension(dim)
            let isLeftOfValue = dimensionDifference > 0
            
            //check the best estimate side
            let closerSubtree = isLeftOfValue ? left : right
            closerSubtree.nearestK(to: searchElement, bestValues: &bestValues, where: condition)

            if condition(value) {
                //check the nodes value
                let currentDistance = value.squaredDistance(to: searchElement)
                bestValues.append(value, distance: currentDistance)
            }

            //if the bestDistance so far intersects the hyperplane at the other side of this value
            //there could be points in the other subtree
            if dimensionDifference*dimensionDifference < bestValues.biggestDistance || !bestValues.full {
                let otherSubtree = isLeftOfValue ? right : left
                otherSubtree.nearestK(to: searchElement, bestValues: &bestValues, where: condition)
            }
        case .leaf: break
        }
    }
    
    /// Returns all points within a certain radius of the search point,
    ///
    ///   - radius: The euclidian radius of the sphere around the search point
    ///   - searchElement: the center of the search
    ///
    /// - Complexity: O(log N).
    public func allPoints(within radius: Double, of searchElement: Element) -> [Element] {
        var neighbours = [Element]()
        self.allPoints(within: radius, of: searchElement, points: &neighbours)
        return neighbours
    }
    
    fileprivate func allPoints(within radius: Double, of searchElement: Element, points: inout [Element]) {
        switch self {
        case let .node(left, value, dim, right):
            let dimensionDifference = value.kdDimension(dim) - searchElement.kdDimension(dim)
            let isLeftOfValue = dimensionDifference > 0
            
            //check the best estimate side
            let closerSubtree = isLeftOfValue ? left : right
            closerSubtree.allPoints(within: radius, of: searchElement, points: &points)
            
            //if the search radius intersects the hyperplane of this tree node
            //there could be points in the other subtree
            if abs(dimensionDifference) < radius {
                //check the nodes value
                let currentDistance = value.squaredDistance(to: searchElement)
                if currentDistance <= radius * radius {
                    points.append(value)
                }
                
                let otherSubtree = isLeftOfValue ? right : left
                otherSubtree.allPoints(within: radius, of: searchElement, points: &points)
            }
        case .leaf: break
        }
    }
}
