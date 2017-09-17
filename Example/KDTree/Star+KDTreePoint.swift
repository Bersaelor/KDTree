//
//  Star.swift
//  KDTree
//
//  Created by Konrad Feiler on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import KDTree
import SwiftyHYGDB

extension RadialStar: KDTreePoint {
    public static var dimensions = 2
    
    public func kdDimension(_ dimension: Int) -> Double {
        return dimension == 0 ? Double(self.normalizedAscension) : Double(self.normalizedDeclination)
    }
    
    public func squaredDistance(to otherPoint: RadialStar) -> Double {
        let x = self.normalizedAscension - otherPoint.normalizedAscension
        let y = self.normalizedDeclination - otherPoint.normalizedDeclination
        return Double(x*x + y*y)
    }
}
