//
//  AllPointsinRadiusTests.swift
//  KDTree_Example
//
//  Created by Konrad Feiler on 28.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import KDTree

class AllPointsinRadiusTests: XCTestCase {
    var points: [CGPoint] = []
    var testPoints: [CGPoint] = []
    var largeTree: KDTree<CGPoint> = KDTree(values: [])
    var nearestPointsFromArray: [CGPoint] = []
    var radii: [CGFloat] = []
    var pointsBruteForce: [[CGPoint]] = []
    var pointsUsingAlgorithm: [[CGPoint]] = []

    override func setUp() {
        super.setUp()
        
        points = (0..<10000).map { _ in CGPoint(x: CGFloat.random(), y: CGFloat.random()) }
        testPoints = (0..<100).map { _ in CGPoint(x: CGFloat.random(), y: CGFloat.random()) }
        largeTree = KDTree(values: self.points)
        radii = testPoints.map { _ in CGFloat.random(0.01, end: 0.2) }
        nearestPointsFromArray = testPoints.map { (searchPoint: CGPoint) -> CGPoint in
            var bestDistance = Double.infinity
            let nearest = self.points.reduce(CGPoint.zero) { (bestPoint: CGPoint, testPoint: CGPoint) -> CGPoint in
                let testDistance = searchPoint.squaredDistance(to: testPoint)
                if testDistance < bestDistance {
                    bestDistance = testDistance
                    return testPoint
                }
                return bestPoint
            }
            return nearest
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test0_ZeroDistance() {
        let pointsInDist = largeTree.allPoints(within: 0.0, of: CGPoint(x: 0.5, y: 0.5))
        XCTAssertTrue(pointsInDist.isEmpty, "Expected no points with zero distance")
    }
    
    func test1_FullTree() {
        let pointsInDist = largeTree.allPoints(within: 1.0, of: CGPoint(x: 0.5, y: 0.5))
        XCTAssertEqual(pointsInDist.count, points.count, "Expected all points within distance of 1")
    }
    
    func test2_BaseLineFindAllPoints() {
        self.measure {
            pointsBruteForce = testPoints.enumerated().map { (offset, center) -> [CGPoint] in
                let dSquared = Double(radii[offset] * radii[offset])
                return points.filter({ center.squaredDistance(to: $0) < dSquared })
            }
        }
    }

    func test3_FindAllPoints() {
        self.measure {
            pointsUsingAlgorithm = testPoints.enumerated().map { (offset, center) -> [CGPoint] in
                return largeTree.allPoints(within: Double(radii[offset]), of: center)
            }
        }
    }

    func test4_ResultsEqualBruteForce() {
        for (offset, bruteForcePoints) in pointsBruteForce.enumerated() {
            let sortedBruteForcePoints = bruteForcePoints.sorted(by: { $0.x < $1.x })
            let sortedPoints = pointsUsingAlgorithm[offset].sorted(by: { $0.x < $1.x })
            XCTAssertEqual(sortedPoints, sortedBruteForcePoints)
        }
    }
    
}
