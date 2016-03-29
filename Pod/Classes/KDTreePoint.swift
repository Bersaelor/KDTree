//
//  KDTreeGrowing.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import Foundation

public protocol KDTreePoint: Equatable {
    static var kdDimensionFunctions: [Self -> Double] { get }
    func distance(otherPoint: Self) -> Double
}
