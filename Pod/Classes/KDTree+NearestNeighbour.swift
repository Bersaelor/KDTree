//
//  KDTree+NearestNeighbour.swift
//  Pods
//
//  Created by Konrad Feiler on 29/03/16.
//
//

import Foundation

// MARK: Nearest Neighbour
extension KDTree {
    
    /// Returns a the nearest `KDTreePoint` to the search point `toElement`,
    /// If `toElement` is a member of the tree, the algorithm will return the closest other value
    /// Optional parameter 'maxDistance' if you are not interested in neighbours beyond a specified distance
    ///
    /// - Complexity: O(N log N).
    public func nearest(toElement element: Element, maxDistance: Double = Double.infinity) -> Element? {
        guard !self.isEmpty else { return nil }
        
        return nearest(toElement: element, bestValue: nil, bestDistance: maxDistance).bestValue
    }
    
    fileprivate func nearest(toElement searchElement: Element, bestValue: Element?, bestDistance: Double) -> (bestValue: Element?, bestDistance: Double) {
        switch self {
        case .leaf: break
        case let .node(.leaf, value, _, .leaf):
            guard searchElement != value else { return (bestValue, bestDistance) }
            let currentDistance = value.squaredDistance(to: searchElement)
            if currentDistance < bestDistance { return (value, currentDistance) }
        case let .node(left, value, dim, right):
            let dimensionDifference = value.kdDimension(dim) - searchElement.kdDimension(dim)
            let isLeftOfValue = dimensionDifference > 0
            
            //check the best estimate side
            let closerSubtree = isLeftOfValue ? left : right
            var (bestNewElement, bestNewDistance) = closerSubtree.nearest(toElement: searchElement, bestValue: bestValue, bestDistance: bestDistance)
            
            //check the nodes value
            if searchElement != value {
                let currentDistance = value.squaredDistance(to: searchElement)
                if currentDistance < bestNewDistance { (bestNewElement, bestNewDistance) = (value, currentDistance) }
            }
            
            //if the bestDistance so far intersects the hyperplane at the other side of this value
            //there could be points in the other subtree
            if dimensionDifference*dimensionDifference < bestNewDistance {
                let otherSubtree = isLeftOfValue ? right : left
                (bestNewElement, bestNewDistance) = otherSubtree.nearest(toElement: searchElement, bestValue: bestNewElement, bestDistance: bestNewDistance)
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

        if let index = nearestValues.index(where: { return distance < $0.distance }) {
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
    
    /// Returns the k nearest `KDTreePoint`s to the search point `toElement`,
    ///
    /// - Complexity: O(log N).
    public func nearestK(_ number: Int, toElement searchElement: Element) -> [Element] {
        var neighbours: Neighbours = Neighbours(goalNumber: number)
        self.nearestK(toElement: searchElement, bestValues: &neighbours)
        return neighbours.nearestValues.map { $0.point as! Element }
    }
    
    fileprivate func nearestK(toElement searchElement: Element, bestValues: inout Neighbours) {
        switch self {
        case let .node(left, value, dim, right):
            let dimensionDifference = value.kdDimension(dim) - searchElement.kdDimension(dim)
            let isLeftOfValue = dimensionDifference > 0
            
            //check the best estimate side
            let closerSubtree = isLeftOfValue ? left : right
            closerSubtree.nearestK(toElement: searchElement, bestValues: &bestValues)

            //check the nodes value
            let currentDistance = value.squaredDistance(to: searchElement)
            bestValues.append(value, distance: currentDistance)

            //if the bestDistance so far intersects the hyperplane at the other side of this value
            //there could be points in the other subtree
            if dimensionDifference*dimensionDifference < bestValues.biggestDistance || !bestValues.full {
                let otherSubtree = isLeftOfValue ? right : left
                otherSubtree.nearestK(toElement: searchElement, bestValues: &bestValues)
            }
        case .leaf: break
        }
    }
}
