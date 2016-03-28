//
//  KDTreeGrowing.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import Foundation

public protocol KDTreeGrowing: Equatable {
    static func kdTreeMetric(a: Self, b: Self) -> Double
    static var kdDimensionFunctions: [Self -> Double] { get }
}
