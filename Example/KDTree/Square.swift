//
//  Square.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import KDTree

struct Square {
    let center: CGPoint
    let radius: CGFloat
    let color: UIColor
    
    var rect: CGRect {
        return CGRect(x: center.x-radius, y: center.y-radius, width: 2*radius, height: 2*radius)
    }
}

func == (lhs: Square, rhs: Square) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}

extension Square: Equatable {}

extension Square: KDTreePoint {
    static var kdDimensionFunctions: [Square -> Double] {
        return [{ Double($0.center.x) },
                { Double($0.center.y) }]
    }
    
    func squaredDistance(otherPoint: Square) -> Double {
        return self.center.squaredDistance(otherPoint.center)
    }
    
}
