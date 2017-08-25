//
//  Disc.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#if os(macOS)
    import Cocoa
    public typealias Color = NSColor
    public typealias Font = NSFont
#else
    import UIKit
    public typealias Color = UIColor
    public typealias Font = UIFont
#endif

import KDTree

extension CGFloat {
    static func random(_ start: CGFloat = 0.0, end: CGFloat = 1.0) -> CGFloat {
        return (end-start)*CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + start
    }
}

struct Disc {
    let center: CGPoint
    let radius: CGFloat
    let color: Color
    
    var rect: CGRect {
        return CGRect(x: center.x-radius, y: center.y-radius, width: 2*radius, height: 2*radius)
    }
}

func == (lhs: Disc, rhs: Disc) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}

extension Disc: Equatable {}

extension Disc: KDTreePoint {
    static var dimensions = 2
    
    func kdDimension(_ dimension: Int) -> Double {
        return dimension == 0 ? Double(self.center.x) : Double(self.center.y)
    }
    
    func squaredDistance(to otherPoint: Disc) -> Double {
        return self.center.squaredDistance(to: otherPoint.center)
    }
}
