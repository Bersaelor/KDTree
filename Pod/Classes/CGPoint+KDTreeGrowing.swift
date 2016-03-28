//
//  CGPoint+KDTreeGrowing.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import UIKit

extension CGPoint: KDTreeGrowing {
    public static func kdTreeMetric(a: CGPoint, b: CGPoint) -> Double {
        let x = a.x - b.x
        let y = a.y - b.y
        return Double(x*x + y*y)
    }
    
    public static var kdDimensionFunctions: [CGPoint -> Double] {
        return [{ a in Double(a.x) },
                { a in Double(a.y) }]
    }

}
