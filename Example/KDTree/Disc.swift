//
//  Disc.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import KDTree

struct Disc {
    let center: CGPoint
    let radius: CGFloat
    
    static func randomCircle() -> Disc {
        return Disc(center: CGPoint.random(),
                    radius: CGFloat.random(start: 0.01, end: 0.1))
    }
    
    var rect: CGRect {
        return CGRect(x: center.x-radius, y: center.y-radius, width: 2*radius, height: 2*radius)
    }
}

func == (lhs: Disc, rhs: Disc) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}

extension Disc: Equatable {}

extension Disc: KDTreePoint {
    static var kdDimensionFunctions: [Disc -> Double] {
        return [{ Double($0.center.x) },
                { Double($0.center.y) }]
    }
    
    func squaredDistance(otherPoint: Disc) -> Double {
//        let addedRadii = Double(self.radius + otherPoint.radius)
//        return min(0.0, self.center.squaredDistance(otherPoint.center) - addedRadii*addedRadii)
        return self.center.squaredDistance(otherPoint.center)
    }
    
}