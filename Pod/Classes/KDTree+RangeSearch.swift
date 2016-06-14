//
//  KDTree+RangeSearch.swift
//  Pods
//
//  Created by Konrad Feiler on 06/04/16.
//
//

import Foundation

extension KDTreePoint {
    private func fitsIn(_ intervals: [(Double, Double)]) -> Bool {
        //make sure there is no dimension with the value outside of the interval
        let hasDimensionOutSide = (0..<Self.dimensions).contains({ (index: Int) -> Bool in
            let value = self.kdDimension(index)
            return value < intervals[index].0 || intervals[index].1 < value
        })
        return !hasDimensionOutSide
    }
}


extension KDTree {
    
    public func elementsIn(intervals: [(Double, Double)]) -> [Element] {
        guard intervals.count == Element.dimensions else {
            return []
        }
        
        switch self {
        case .Leaf:
            return []
        case let .Node(left, value, dim, right):
            print("Stepping through node \(value), \(dim)")
            var returnValues = value.fitsIn(intervals) ? [value] : []
            let dimensionValue = value.kdDimension(dim)
            if intervals[dim].0 < dimensionValue {
                returnValues.append(contentsOf: left.elementsIn(intervals: intervals))
            }
            if intervals[dim].1 > dimensionValue {
                returnValues.append(contentsOf: right.elementsIn(intervals: intervals))
            }
            return returnValues
        }
    }
    
}
