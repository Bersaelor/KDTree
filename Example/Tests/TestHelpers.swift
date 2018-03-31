//
//  TestHelpers.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import KDTree

#if os(Linux) || CYGWIN
    public func arc4random() -> UInt32 {
        return UInt32(random())
    }
#endif

extension CGFloat {
    static func random(_ start: CGFloat = 0.0, end: CGFloat = 1.0) -> CGFloat {
        return (end - start)*CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + start
    }
}

extension CGPoint {
    var norm: Double {
        return sqrt(Double(self.x*self.x + self.y*self.y))
    }
}

extension CGRect: KDTreePoint {
    public static var dimensions = 2
    
    public func kdDimension(_ dimension: Int) -> Double {
        return dimension == 0 ? Double(self.midX) : Double(self.midY)
    }
    
    public func squaredDistance(to otherPoint: CGRect) -> Double {
        let x = self.midX - otherPoint.midX
        let y = self.midY - otherPoint.midY
        return Double(x*x + y*y)
    }
}

extension Array {
    func randomElement() -> Element? {
        guard !self.isEmpty else { return nil }        
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}
