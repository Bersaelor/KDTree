//
//  CGPoint+KDTreeGrowing.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

#if os(iOS) || os(tvOS) || os(watchOS)
    import CoreGraphics
#elseif os(macOS)
    import CoreGraphics
#endif
import Foundation

extension CGPoint: KDTreePoint {
    public static var dimensions = 2
    
    public func kdDimension(_ dimension: Int) -> Double {
        return dimension == 0 ? Double(self.x) : Double(self.y)
    }

    public func squaredDistance(to otherPoint: CGPoint) -> Double {
        let x = self.x - otherPoint.x
        let y = self.y - otherPoint.y
        return Double(x*x + y*y)
    }
}
