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
        return !Self.kdDimensionFunctions.enumerate().contains { (index: Int, f: Self -> Double) in
            let value = f(self)
            return value < intervalls[index].0 || intervalls[index].1 < value
        }        
    }
}


extension KDTree {
    
    public func elementsInRange(intervals: [(Double, Double)]) -> [Element] {
        guard intervals.count == Element.kdDimensionFunctions.count else {
            print("Warning: Please provide as man interval ranges as dimensionfunctions")
            return []
        }
        
        switch self {
        case .Leaf:
            return []
        case let .Node(left, value, dim, right):
            print("Stepping through node \(value), \(dim)")
            var returnValues = value.fitsInIntervalls(intervals) ? [value] : []
            let dimensionValue = Element.kdDimensionFunctions[dim](value)
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
