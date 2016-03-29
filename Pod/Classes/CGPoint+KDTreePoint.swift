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
        return [{ a in Double(a.x) },
                { a in Double(a.y) }]
    }

    public func distance(otherPoint: CGPoint) -> Double {
        let x = self.x - otherPoint.x
        let y = self.y - otherPoint.y
        return Double(x*x + y*y)
    }

}
