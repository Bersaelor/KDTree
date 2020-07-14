//
//  KDTree+RangeSearch.swift
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

extension KDTreePoint {
    fileprivate func fitsIn(_ intervals: [(Double, Double)]) -> Bool {
        //make sure there is no dimension with the value outside of the interval
        let hasDimensionOutSide = (0..<Self.dimensions).contains(where: { (index: Int) -> Bool in
            let value = self.kdDimension(index)
            return value < intervals[index].0 || intervals[index].1 < value
        })
        return !hasDimensionOutSide
    }
}


extension KDTree {
    
    public func elementsIn(_ intervals: [(Double, Double)]) -> [Element] {
        guard intervals.count == Element.dimensions else {
            return []
        }
        
        switch self {
        case .leaf:
            return []
        case let .node(left, value, dim, right):
            var returnValues = value.fitsIn(intervals) ? [value] : []
            let dimensionValue = value.kdDimension(dim)
            if intervals[dim].0 < dimensionValue {
                returnValues.append(contentsOf: left.elementsIn(intervals))
            }
            if intervals[dim].1 > dimensionValue {
                returnValues.append(contentsOf: right.elementsIn(intervals))
            }
            return returnValues
        }
    }
    
}
