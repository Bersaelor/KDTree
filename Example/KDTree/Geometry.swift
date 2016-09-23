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
        return CGPoint(x: CGFloat.random(-1, end: 1), y: CGFloat.random(-1, end: 1))
    }
    
    var norm: CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    var maximumNorm: CGFloat {
        return max(abs(self.x), abs(self.y))
    }
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

public func * (scalar: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: scalar * right.x, y: scalar * right.y)
}

public func *= (left: inout CGPoint, right: CGFloat) {
    left = right * left
}

extension CGPoint {
    public var angle: CGFloat {
        let normedVec = 1.0/self.norm * self
        return atan(normedVec.y / normedVec.x) + CGFloat(self.x < 0 ? M_PI : 0.0)
    }
    
    public static func angledVec(_ angle: CGFloat) -> CGPoint {
        return CGPoint(x: cos(angle), y: sin(angle))
    }
}
