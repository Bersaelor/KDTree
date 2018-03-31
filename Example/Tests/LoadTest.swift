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
    var nearestPointsFromArray: [CGPoint] = []
    let accuracy = 20 * CGFloat.ulpOfOne
    
    override func setUp() {
        super.setUp()
        
        points = (0..<10000).map { _ in CGPoint(x: CGFloat.random(), y: CGFloat.random()) }
        testPoints = (0..<500).map { _ in CGPoint(x: CGFloat.random(), y: CGFloat.random()) }
        largeTree = KDTree(values: self.points)
        
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

    func test01_BuildingPerformance() {
        self.measure {
            _ = KDTree(values: self.points)
        }
    }

    func test02_InsertPerformance() {
        let insertPoints = testPoints[0..<100]
        var movingTree = largeTree
        self.measure {
            for point in insertPoints { movingTree = movingTree.inserting(point) }
        }
        
        XCTAssertEqual(movingTree.count, points.count + insertPoints.count, "After Insertion points = start + inserted")
    }
    
    func test03_RemovePerformance() {
        var pointsLeft = points
        var pointsRemoved = [CGPoint]()
        for _ in 0..<1000 {
            if let randomPoint = pointsLeft.randomElement() {
                pointsRemoved.append(randomPoint)
                if let index = pointsLeft.index(of: randomPoint) {
                    pointsLeft.remove(at: index)
                }
            }
        }
        var movingTree = largeTree

        self.measure {
            for point in pointsRemoved { movingTree = movingTree.removing(point) }
        }
        
        XCTAssertEqual(movingTree.count, points.count - pointsRemoved.count, "After Removing points = start - removed")
    }

    func test04_ReducePerformance() {
        let avgPoint = self.points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x/CGFloat(self.points.count),
                                                                  y: $0.y + $1.y/CGFloat(self.points.count))
        }
        var avgPointTree = CGPoint.zero
        self.measure {
            avgPointTree = self.largeTree.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x/CGFloat(self.points.count),
                                                                         y: $0.y + $1.y/CGFloat(self.points.count))
            }
        }
        print("avgPoint: \(avgPointTree)")
        
        XCTAssertLessThan(avgPointTree.squaredDistance(to: CGPoint(x: 0.5, y: 0.5)), 0.1, "Average point should be around (0.5, 0,5)")
        
        XCTAssertEqual(avgPointTree.x, avgPoint.x, accuracy: accuracy, "Average point from tree equals average from points")
        XCTAssertEqual(avgPointTree.y, avgPoint.y, accuracy: accuracy, "Average point from tree equals average from points")
    }
    
//    func test04b_ComparisonArrayReduce() {
//        var sum = CGPoint.zero
//        self.measure {
//            sum = self.points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y)}
//        }
//        let avgPoint = CGPoint(x: sum.x/CGFloat(self.points.count), y: sum.y/CGFloat(self.points.count))
//        XCTAssertLessThan(avgPoint.squaredDistance(to: CGPoint(x: 0.5, y: 0.5)), 0.1, "Average point should be around (0.5, 0,5)")
//    }
    
    func test05_NearestNeighbourPerformance() {
        var nearestPointsFromTree = [CGPoint]()
        self.measure {
            nearestPointsFromTree = self.testPoints.map { (searchPoint: CGPoint) -> CGPoint in
                return self.largeTree.nearest(to: searchPoint) ?? CGPoint.zero
            }
        }

        XCTAssertEqual(nearestPointsFromArray, nearestPointsFromTree, "Nearest points via Array should equal nearest points via Tree")
    }
    
//    func test05b_NearestNeighbourComparisonArray() {
//        let searchPoints = testPoints
//        
//        self.measure {
//            let _ = searchPoints.map { (searchPoint: CGPoint) -> CGPoint in
//                var bestDistance = Double.infinity
//                let nearest = self.points.reduce(CGPoint.zero) { (bestPoint: CGPoint, testPoint: CGPoint) -> CGPoint in
//                    let testDistance = searchPoint.squaredDistance(to: testPoint)
//                    if testDistance < bestDistance {
//                        bestDistance = testDistance
//                        return testPoint
//                    }
//                    return bestPoint
//                }
//                return nearest
//            }
//        }
//    }
    
    func test05_k5NearestNeighbour() {
        let nearest5PointsFromArray = testPoints.map { (searchPoint: CGPoint) -> [CGPoint] in
            let nearest = self.points.reduce([CGPoint]()) { (bestPoints: [CGPoint], testPoint: CGPoint) -> [CGPoint] in
                guard bestPoints.count >= 5 else {
                    let newBestPoints = bestPoints + [testPoint]
                    return newBestPoints.sorted { searchPoint.squaredDistance(to: $0) < searchPoint.squaredDistance(to: $1) }
                }
                
                let testDistance = searchPoint.squaredDistance(to: testPoint)
                if let index = bestPoints.index(where: { testDistance < searchPoint.squaredDistance(to: $0) }) {
                    var newBestPoints = bestPoints
                    newBestPoints.removeLast()
                    newBestPoints.insert(testPoint, at: index)
                    return newBestPoints
                }
                return bestPoints
            }
            return nearest
        }

        var nearest5PointsFromTree = [[CGPoint]]()
        self.measure {
            nearest5PointsFromTree = self.testPoints.map { (searchPoint: CGPoint) -> [CGPoint] in
                return self.largeTree.nearestK(5, to: searchPoint)
            }
        }
        
        nearest5PointsFromArray.enumerated().forEach { (index, pointsFromArray) in
            let nearestFromTree = nearest5PointsFromTree[index]
            XCTAssertEqual(nearestFromTree, pointsFromArray, "Nearest points via Array should equal nearest points via Tree")
        }
    }
    
    func test06_ContainsTest() {

        let randomContainedPoints = (0...100).map { _ -> CGPoint in
            // swiftlint:disable:next force_unwrapping
            return points.randomElement()!
        }
        
        var containedPoints = 0
        for point in randomContainedPoints where !largeTree.contains(point) {
            containedPoints += 1
        }
        
        XCTAssertEqual(0, containedPoints, "All original points should be contained in the tree")
    }
    
    func test07_SelfShouldBeNearestTest() {
        
        let randomContainedPoints = (0...100).map { _ -> CGPoint in
            // swiftlint:disable:next force_unwrapping
            return points.randomElement()!
        }
        
        var containedPoints = 0
        for point in randomContainedPoints where point != largeTree.nearest(to: point) {
            containedPoints += 1
        }
        
        XCTAssertEqual(0, containedPoints, "All original points should be their own nearest points")
    }
}
