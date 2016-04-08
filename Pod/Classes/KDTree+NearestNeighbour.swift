//
//  KDTree+NearestNeighbour.swift
//  Pods
//
//  Created by Konrad Feiler on 29/03/16.
//
//

import Foundation

//MARK: Nearest Neighbour
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
    
    private func nearest(toElement searchElement: Element, bestValue: Element?, bestDistance: Double) -> (bestValue: Element?, bestDistance: Double) {
        switch self {
        case .Leaf: break
        case let .Node(.Leaf, value, _, .Leaf):
            guard searchElement != value else { return (bestValue, bestDistance) }
            let currentDistance = value.squaredDistance(searchElement)
            if currentDistance < bestDistance { return (value, currentDistance) }
        case let .Node(left, value, dim, right):

            let dimensionFunction = Element.kdDimensionFunctions[dim]
            let dimensionDifference = dimensionFunction(value) - dimensionFunction(searchElement)
            let isLeftOfValue = dimensionDifference > 0
            
            //check the best estimate side
            let closerSubtree = isLeftOfValue ? left : right
            var (bestNewElement, bestNewDistance) = closerSubtree.nearest(toElement: searchElement, bestValue: bestValue, bestDistance: bestDistance)
            
            //check the nodes value
            if searchElement != value {
                let currentDistance = value.squaredDistance(searchElement)
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

private struct Neighbours<Element> {
    private var nearestValues: [(Element, Double)]
    var count: Int { return nearestValues.count }
    let goalNumber: Int
    var full: Bool { return nearestValues.count >= goalNumber }
    var biggestDistance: Double { return nearestValues.last?.1 ?? Double.infinity }
    
    init(goalNumber: Int, values: [(Element, Double)]) {
        self.goalNumber = goalNumber
        self.nearestValues = values
    }
    
    mutating func append(value: Element, distance: Double) {
        if let index = nearestValues.indexOf({ return distance < $0.1 }) {
            nearestValues.insert((value, distance), atIndex: index)
            if nearestValues.count > goalNumber { nearestValues.removeLast() }
        }
        else {
            nearestValues.append((value, distance))
        }
    }
}

//MARK: k Nearest Neighbour
extension KDTree {
    
    /// Returns the k nearest `KDTreePoint`s to the search point `toElement`,
    ///
    /// - Complexity: O(N log N).
    public func nearestK(number: Int, toElement searchElement: Element) -> [Element] {
        var neighbours: Neighbours<Element> = Neighbours(goalNumber: number, values: [])
        self.nearestK(toElement: searchElement, bestValues: &neighbours)
        return neighbours.nearestValues.map { $0.0 }
    }
    
    private func nearestK(toElement searchElement: Element, inout bestValues: Neighbours<Element>) {
        switch self {
        case .Leaf: break
        case let .Node(.Leaf, value, _, .Leaf):
            let currentDistance = value.squaredDistance(searchElement)
            if !bestValues.full || currentDistance < bestValues.biggestDistance {
                bestValues.append(value, distance: currentDistance)
            }
        case let .Node(left, value, dim, right):
            let dimensionFunction = Element.kdDimensionFunctions[dim]
            let dimensionDifference = dimensionFunction(value) - dimensionFunction(searchElement)
            let isLeftOfValue = dimensionDifference > 0
            
            //check the best estimate side
            let closerSubtree = isLeftOfValue ? left : right
            closerSubtree.nearestK(toElement: searchElement, bestValues: &bestValues)

            //check the nodes value
            let currentDistance = value.squaredDistance(searchElement)
            if !bestValues.full || currentDistance < bestValues.biggestDistance {
                bestValues.append(value, distance: currentDistance)
            }

            //if the bestDistance so far intersects the hyperplane at the other side of this value
            //there could be points in the other subtree
            if dimensionDifference*dimensionDifference < bestValues.biggestDistance {
                let otherSubtree = isLeftOfValue ? right : left
                otherSubtree.nearestK(toElement: searchElement, bestValues: &bestValues)
            }
        }
    }
}
