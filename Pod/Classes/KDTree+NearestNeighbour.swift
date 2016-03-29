//
//  KDTree+NearestNeighbour.swift
//  Pods
//
//  Created by Konrad Feiler on 29/03/16.
//
//

import Foundation

private struct StepDirection: OptionSetType {
    let rawValue: Int

    static let None  = StepDirection(rawValue: 0)
    static let Left  = StepDirection(rawValue: 1 << 0)
    static let Right = StepDirection(rawValue: 1 << 1)
}

private class SearchStep<Element: KDTreePoint> {
    let node: KDTree<Element>
    var steppedDirections = StepDirection.None
    
    init(node: KDTree<Element>, direction: StepDirection = StepDirection.None) {
        self.node = node
        steppedDirections = direction
    }
}

extension SearchStep : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(node.debugDescription)"
    }
}

private class NeighbourSearchData<Element: KDTreePoint> {
    let searchPoint: Element
    var currentBest: Element?
    var bestDistance: Double = Double.infinity
    var pathStack = [SearchStep<Element>]()
    
    init(searchPoint: Element) { self.searchPoint = searchPoint }
    
    private func bubbleUp() {
        while let currentStep = pathStack.popLast() {
            switch currentStep.node {
            case .Leaf:
                print("WARNING: There should be no leaves in the pathStack")
            case let .Node(left, value, dim, right):
                let currentDistance = value.distance(searchPoint)
                if currentDistance < bestDistance {
                    self.bestDistance = currentDistance
                    self.currentBest = value
                }
                
                //check whether there could be any other points on the other side of the current node
                //f(searchPoint) - f(value) is the distance of the searchPoint to the current hyperplane
                let f = Element.kdDimensionFunctions[dim]
                if abs(f(searchPoint) - f(value)) < self.bestDistance {
                    if !currentStep.steppedDirections.contains(.Left) {
                        currentStep.steppedDirections = [.Left, currentStep.steppedDirections]
                        left.findBestDown(self)
                    }
                    else if !currentStep.steppedDirections.contains(.Right) {
                        currentStep.steppedDirections = [currentStep.steppedDirections, .Right]
                        right.findBestDown(self)
                    }
                }
            }
        }
    }
}

//MARK: Nearest Neighbour
extension KDTree {
    
    private func findBestDown(searchData: NeighbourSearchData<Element>) {
        switch self {
        case .Leaf:
            return
        case let .Node(.Leaf, value, _, .Leaf):
            let currentDistance = value.distance(searchData.searchPoint)
            if currentDistance < searchData.bestDistance {
                searchData.bestDistance = currentDistance
                searchData.currentBest = value
            }
            return
        case let .Node(left, value, dim, right):
            if value == searchData.searchPoint {
                searchData.currentBest = value
                searchData.bestDistance = 0.0
                return
            }
            else {
                let f = Element.kdDimensionFunctions[dim]
                if f(searchData.searchPoint) < f(value) {
                    searchData.pathStack.append(SearchStep(node: self, direction: StepDirection.Left))
                    return left.findBestDown(searchData)
                }
                else {
                    searchData.pathStack.append(SearchStep(node: self, direction: StepDirection.Right))
                    return right.findBestDown(searchData)
                }
            }
        }
    }
    
    public func nearest(toElement element: Element) -> Element? {
        guard !self.isEmpty else { return nil }
        
        print("Finding nearest neigbour of \(element)")
        let searchData = NeighbourSearchData(searchPoint: element)
        self.findBestDown(searchData)
        print("currentBest: \(searchData.currentBest)")
        print("path stack: \(searchData.pathStack)")
        searchData.bubbleUp()
        print("currentBest: \(searchData.currentBest) after bubbling up")
        
        return searchData.currentBest
    }
}