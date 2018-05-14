//
//  ContainsTest.swift
//  KDTree
//
//  Created by Konrad Feiler on 23.08.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import KDTree

struct GridP: Equatable {
    let point: CGPoint
}

extension GridP: KDTreePoint {
    static var dimensions = 2
    
    func kdDimension(_ dimension: Int) -> Double {
        return dimension == 0 ? Double(self.point.x) : Double(self.point.y)
    }
    
    func squaredDistance(to otherPoint: GridP) -> Double {
        return self.point.squaredDistance(to: otherPoint.point)
    }
}

class GridTest: XCTestCase {
    
    var points: [GridP] = []
    var tree: KDTree<GridP> = KDTree(values: [])

    override func setUp() {
        super.setUp()
        
        let size = 10
        for x in 0...size {
            for y in 0...size {
                points.append(GridP(point: CGPoint(x: x, y: y)))
            }
        }

        tree = KDTree(values: points)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPointsContained() {
        var containedPoints = 0
        for point in points where !tree.contains(point) {
            containedPoints += 1
        }
        
        XCTAssertEqual(0, containedPoints, "All original points should be contained in the tree")
    }
  
  func testPointsDeleted() {
    
    var pointsNotDeleted = 0
    for point in points {
      if tree.removing(point).count == tree.count {
        pointsNotDeleted += 1
      }
    }
    
    XCTAssertEqual(0, pointsNotDeleted, "All original points should be be deleted in the tree")
  }
  
    func testSelfShouldBeNearest() {
        var notNearestCount = 0

        for point in points where point != tree.nearest(to: point) {
            print("Point \(point) should be nearest to itself, is nearest to \(String(describing: tree.nearest(to: point) ))")
            notNearestCount += 1
        }

        XCTAssertEqual(0, notNearestCount, "All original points should be their own nearest points")
    }
}
