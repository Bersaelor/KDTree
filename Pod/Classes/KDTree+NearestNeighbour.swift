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
    
    public func nearest(toElement element: Element) -> Element? {
        guard !self.isEmpty else { return nil }
        
        return nearest(toElement: element, bestValue: nil, bestDistance: Double.infinity).bestValue
    }
    
    private func nearest(toElement searchElement: Element, bestValue: Element?, bestDistance: Double) -> (bestValue: Element?, bestDistance: Double) {
        switch self {
        case .Leaf: break
        case let .Node(.Leaf, value, _, .Leaf):
            let currentDistance = value.unsquaredDistance(searchElement)
            if currentDistance < bestDistance { return (value, currentDistance) }
        case let .Node(left, value, dim, right):
            if value == searchElement {
                return (value, 0.0)
            }
            else {
                let dimensionFunction = Element.kdDimensionFunctions[dim]
                let dimensionDifference = dimensionFunction(value) - dimensionFunction(searchElement)
                let isLeftOfValue = dimensionDifference > 0
                
                //check the best estimate side
                let closerSubtree = isLeftOfValue ? left : right
                var (bestNewElement, bestNewDistance) = closerSubtree.nearest(toElement: searchElement, bestValue: bestValue, bestDistance: bestDistance)
                
                //check the nodes value
                let currentDistance = value.unsquaredDistance(searchElement)
                if currentDistance < bestNewDistance { (bestNewElement, bestNewDistance) = (value, currentDistance) }
                
                //if the bestDistance so far intersects the hyperplane at the other side of this value
                //there could be points in the other subtree
                if dimensionDifference*dimensionDifference < bestNewDistance {
                    let otherSubtree = isLeftOfValue ? right : left
                    (bestNewElement, bestNewDistance) = otherSubtree.nearest(toElement: searchElement, bestValue: bestNewElement, bestDistance: bestNewDistance)
                }
                
                return (bestNewElement, bestNewDistance)
            }
        }
        return (bestValue, bestDistance)
    }
}
