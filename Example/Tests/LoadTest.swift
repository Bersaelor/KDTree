//
//  NearestNeighbourLoadTest.swift
//  KDTree
//
//  Created by Konrad Feiler on 30/03/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import KDTree

class NearestNeighbourLoadTest: XCTestCase {
    var points: [CGPoint] = []
    var testPoints: [CGPoint] = []
    var largeTree: KDTree<CGPoint> = KDTree(values: [])
    
    override func setUp() {
        super.setUp()
        
        points = Array(0..<10000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
        testPoints = Array(0..<1000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
        largeTree = KDTree(values: self.points)
    }
    
    override func tearDown() {
        super.tearDown()
    } 

    func test01_BuildingPerformance() {
        self.measureBlock {
            let _ = KDTree(values: self.points)
        }
    }

    func test02_InsertPerformance() {
        let insertPoints = testPoints[0..<100]
        var movingTree = largeTree
        self.measureBlock {
            for point in insertPoints { movingTree = movingTree.insert(point) }
        }
        
        XCTAssertEqual(movingTree.count, points.count + insertPoints.count, "After Insertion points = start + inserted")
    }
    
    func test03_RemovePerformance() {
        var pointsLeft = points
        var pointsRemoved = [CGPoint]()
        for _ in 0..<100 {
            if let randomPoint = pointsLeft.randomElement() {
                pointsRemoved.append(randomPoint)
                pointsLeft.removeAtIndex(pointsLeft.indexOf(randomPoint)!)
            }
        }
        var movingTree = largeTree

        self.measureBlock {
            for point in pointsRemoved { movingTree = movingTree.remove(point) }
        }
        
        XCTAssertEqual(movingTree.count, points.count - pointsRemoved.count, "After Removing points = start - removed")

    }

    func test04_ReducePerformance() {
        var sum = self.points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)}
        let avgPoint = CGPoint(x: sum.x/CGFloat(self.points.count), y: sum.y/CGFloat(self.points.count))
        
        self.measureBlock {
            sum = self.largeTree.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)}
        }
        let avgPointTree = CGPoint(x: sum.x/CGFloat(self.points.count), y: sum.y/CGFloat(self.points.count))
        print("avgPoint: \(avgPointTree)")
        
        XCTAssertLessThan(avgPointTree.unsquaredDistance(CGPoint(x: 0.5 , y: 0.5)), 0.1, "Average point should be around (0.5, 0,5)")
        XCTAssertEqual(avgPointTree, avgPoint, "Average point from tree equals average from points")
    }
    
    func test04b_ComparisonArrayReduce() {
        var sum = CGPoint.zero
        self.measureBlock {
            sum = self.points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)}
        }
        let avgPoint = CGPoint(x: sum.x/CGFloat(self.points.count), y: sum.y/CGFloat(self.points.count))
        XCTAssertLessThan(avgPoint.unsquaredDistance(CGPoint(x: 0.5 , y: 0.5)), 0.1, "Average point should be around (0.5, 0,5)")
    }
    
    func test05_NearestNeighbourPerformance() {
        let searchPoints = testPoints[0..<100]
        
        let nearestPointsFromArray = searchPoints.map { (searchPoint: CGPoint) -> CGPoint in
            var bestDistance = Double.infinity
            let nearest = self.points.reduce(CGPoint.zero, combine: { (bestPoint: CGPoint, testPoint: CGPoint) -> CGPoint in
                let testDistance = searchPoint.unsquaredDistance(testPoint)
                if testDistance < bestDistance {
                    bestDistance = testDistance
                    return testPoint
                }
                return bestPoint
            })
            return nearest
        }
        
        var nearestPointsFromTree = [CGPoint]()
        self.measureBlock {
            nearestPointsFromTree = searchPoints.map { (searchPoint: CGPoint) -> CGPoint in
                return self.largeTree.nearest(toElement: searchPoint) ?? CGPoint.zero
            }
        }

        XCTAssertEqual(nearestPointsFromArray, nearestPointsFromTree, "Nearest points via Array should equal nearest points via Tree")
    }
    
    func test05b_NearestNeighbourComparisonArray() {
        let searchPoints = testPoints[0..<100]
        
        self.measureBlock {
            let _ = searchPoints.map { (searchPoint: CGPoint) -> CGPoint in
                var bestDistance = Double.infinity
                let nearest = self.points.reduce(CGPoint.zero, combine: { (bestPoint: CGPoint, testPoint: CGPoint) -> CGPoint in
                    let testDistance = searchPoint.unsquaredDistance(testPoint)
                    if testDistance < bestDistance {
                        bestDistance = testDistance
                        return testPoint
                    }
                    return bestPoint
                })
                return nearest
            }
        }
    }
}
