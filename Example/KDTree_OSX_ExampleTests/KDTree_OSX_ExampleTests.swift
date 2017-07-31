//
//  KDTree_OSX_ExampleTests.swift
//  KDTree_OSX_ExampleTests
//
//  Created by Konrad Feiler on 03/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import KDTree

class KDTreeOSXExampleTests: XCTestCase {
    var points: [CGPoint] = []
    
    override func setUp() {
        super.setUp()
        
        points = (0..<10000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test01_BuildingPerformance() {
        self.measure {
            _ = KDTree(values: self.points)
        }
    }

}
