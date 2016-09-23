//
//  KDTreeGrowing.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import Foundation

public protocol KDTreePoint: Equatable {
    static var dimensions: Int { get }
    func kdDimension(_ dimension: Int) -> Double
    func squaredDistance(to otherPoint: Self) -> Double
}
