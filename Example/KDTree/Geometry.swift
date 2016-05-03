//
//  Geometry.swift
//  iCProVision
//
//  Created by Konrad Feiler on 25/01/16.
//  Copyright © 2016 Mathheartcode UG. All rights reserved.
//

#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

extension CGPoint {
    var shortDecimalDescription: String {
        return String(format: "(%.3f, %.3f)", self.x, self.y)
    }
    
    static func random() -> CGPoint {
        return CGPoint(x: CGFloat.random(start: -1, end: 1), y: CGFloat.random(start: -1, end: 1))
    }
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func -= (inout left: CGPoint, right: CGPoint) {
    left = left - right
}

public func norm(point: CGPoint) -> CGFloat {
    return sqrt(point.x * point.x + point.y * point.y)
}

public func maximumNorm(point: CGPoint) -> CGFloat {
    return max(abs(point.x), abs(point.y))
}

public func * (scalar: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: scalar * right.x, y: scalar * right.y)
}

public func *= (inout left: CGPoint, right: CGFloat) {
    left = right * left
}

extension CGPoint {
    public var angle: CGFloat {
        let normedVec = 1.0/norm(self) * self
        return atan(normedVec.y / normedVec.x) + CGFloat(self.x < 0 ? M_PI : 0.0)
    }
    
    public static func angledVec(angle: CGFloat) -> CGPoint {
        return CGPoint(x: cos(angle), y: sin(angle))
    }
}
