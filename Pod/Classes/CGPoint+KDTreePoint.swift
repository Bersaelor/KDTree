//
//  CGPoint+KDTreeGrowing.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import UIKit

extension CGPoint: KDTreePoint {
    public static var kdDimensionFunctions: [CGPoint -> Double] {
        return [{ Double($0.x) },
                { Double($0.y) }]
    }

    public func squaredDistance(otherPoint: CGPoint) -> Double {
        let x = self.x - otherPoint.x
        let y = self.y - otherPoint.y
        return Double(x*x + y*y)
    }

}
