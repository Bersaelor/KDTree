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
    func kdDimension(dimension: Int) -> Double
    func squaredDistance(otherPoint: Self) -> Double
}
