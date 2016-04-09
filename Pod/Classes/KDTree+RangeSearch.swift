//
//  KDTree+RangeSearch.swift
//  Pods
//
//  Created by Konrad Feiler on 06/04/16.
//
//

import Foundation

extension KDTreePoint {
    private func fitsInIntervalls(intervalls: [(Double, Double)]) -> Bool {
        //make sure there is no dimension with the value outside of the interval
        let hasDimensionOutSide = (0..<Self.dimensions).contains({ (index: Int) -> Bool in
            let value = self.kdDimension(index)
            return value < intervalls[index].0 || intervalls[index].1 < value
        })
        return !hasDimensionOutSide
    }
}


extension KDTree {
    
    public func elementsInRange(intervals: [(Double, Double)]) -> [Element] {
        guard intervals.count == Element.dimensions else {
            print("Warning: Please provide as man interval ranges as dimensionfunctions")
            return []
        }
        
        switch self {
        case .Leaf:
            return []
        case let .Node(left, value, dim, right):
            print("Stepping through node \(value), \(dim)")
            var returnValues = value.fitsInIntervalls(intervals) ? [value] : []
            let dimensionValue = value.kdDimension(dim)
            if intervals[dim].0 < dimensionValue {
                returnValues.appendContentsOf(left.elementsInRange(intervals))
                print("Appended elements from lower side, count after: \(returnValues.count)")
            }
            if intervals[dim].1 > dimensionValue {
                returnValues.appendContentsOf(right.elementsInRange(intervals))
                print("Appended elements from higher side, count after: \(returnValues.count)")
            }
            return returnValues
        }
    }
    
}
