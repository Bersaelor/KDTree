//
//  CodableTests.swift
//  KDTree_Example
//
//  Created by Konrad Feiler on 26.08.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import KDTree

extension CGPoint: Codable {}

class PerformanceTests: XCTestCase {
    var points: [CGPoint] = []
    var testPoints: [CGPoint] = []
    var largeTree: KDTree<CGPoint> = KDTree(values: [])
    
    override func setUp() {
        super.setUp()
        
        points = (0..<1000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
        largeTree = KDTree(values: self.points)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test01_Encoding() {
        
    }
}

