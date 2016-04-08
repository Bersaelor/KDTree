//
//  RangeSearchTests.swift
//  KDTree
//
//  Created by Konrad Feiler on 06/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import KDTree

struct STPoint {
    let x: CGFloat
    let y: CGFloat
    let z: CGFloat
    let t: CGFloat
}

func == (lhs: STPoint, rhs: STPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.t == rhs.t
}

extension STPoint: Equatable {}

extension STPoint: KDTreePoint {
    static var kdDimensionFunctions: [STPoint -> Double] {
        return [{ Double($0.x) },
                { Double($0.y) },
                { Double($0.z) },
                { Double($0.z) }]
    }
    
    func squaredDistance(otherPoint: STPoint) -> Double {
        let x = self.x - otherPoint.x
        let y = self.y - otherPoint.y
        let z = self.z - otherPoint.z
        let t = self.t - otherPoint.t
        return Double(x*x + y*y + z*z + t*t)
    }
}

class RangeSearchTests: XCTestCase {
    var points: [CGPoint] = []
    var largeTree: KDTree<CGPoint> = KDTree(values: [])
    let rangeIntervals: [(Double, Double)] = [(0.2, 0.3), (0.45, 0.75)]

    var spaceTimePoints: [STPoint] = []
    var spaceTimeTree: KDTree<STPoint> = KDTree(values: [])
    let spaceTimeIntervals: [(Double, Double)] = [(0.2, 0.4), (0.45, 0.75), (0.15, 0.85), (0.1, 0.9)]

    override func setUp() {
        super.setUp()
        
        points = Array(0..<10000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
        largeTree = KDTree(values: self.points)
        
        spaceTimePoints = Array(0..<300).map({_ in STPoint(x: CGFloat.random(), y: CGFloat.random(), z: CGFloat.random(), t: CGFloat.random())})
        spaceTimeTree = KDTree(values: self.spaceTimePoints)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test01_RangeSearchPerformance() {
        let minX = self.rangeIntervals[0].0
        let maxX = self.rangeIntervals[0].1
        let minY = self.rangeIntervals[1].0
        let maxY = self.rangeIntervals[1].1
        let pointsInRangeArray = self.points.filter({ (point: CGPoint) -> Bool in
            return minX <= Double(point.x) && maxX > Double(point.x) && minY <= Double(point.y) && maxY > Double(point.y)
        })
        
        var pointsInRangeTree: [CGPoint] = []
        self.measureBlock {
            pointsInRangeTree = self.largeTree.elementsInRange(self.rangeIntervals)
        }
        print("pointsInRangeArray.count: \(pointsInRangeArray.count)")
        XCTAssertEqual(pointsInRangeArray.sort({ $0.x <= $1.x }), pointsInRangeTree.sort({ $0.x <= $1.x }), "Points in Range via Tree should equal Points via Array")
    }
    
    func test01b_RangeSearchArrayComparison() {
        let minX = self.rangeIntervals[0].0
        let maxX = self.rangeIntervals[0].1
        let minY = self.rangeIntervals[1].0
        let maxY = self.rangeIntervals[1].1
        self.measureBlock {
            let _ = self.points.filter({ (point: CGPoint) -> Bool in
                return minX <= Double(point.x) && maxX > Double(point.x) && minY <= Double(point.y) && maxY > Double(point.y)
            })
        }
    }
    
    func test02_STRangeSearchPerformance() {
        let minX = self.spaceTimeIntervals[0].0
        let maxX = self.spaceTimeIntervals[0].1
        let minY = self.spaceTimeIntervals[1].0
        let maxY = self.spaceTimeIntervals[1].1
        let minZ = self.spaceTimeIntervals[2].0
        let maxZ = self.spaceTimeIntervals[2].1
        let minT = self.spaceTimeIntervals[3].0
        let maxT = self.spaceTimeIntervals[3].1
        let pointsInRangeArray = self.spaceTimePoints.filter({ (point: STPoint) -> Bool in
            return minX <= Double(point.x) && maxX >= Double(point.x) && minY <= Double(point.y) && maxY >= Double(point.y)
                && minZ <= Double(point.z) && maxZ >= Double(point.z) && minT <= Double(point.t) && maxT >= Double(point.t)
        })
        
        var pointsInRangeTree: [STPoint] = []
        self.measureBlock {
            pointsInRangeTree = self.spaceTimeTree.elementsInRange(self.spaceTimeIntervals)
        }
        print("pointsInRangeArray: \(pointsInRangeArray.count)")
        XCTAssertEqual(pointsInRangeArray.count, pointsInRangeTree.count, "Points in Range via Tree should equal Points via Array")
    }
    
    func test02b_STRangeSearchArrayComparison() {
        let minX = self.spaceTimeIntervals[0].0
        let maxX = self.spaceTimeIntervals[0].1
        let minY = self.spaceTimeIntervals[1].0
        let maxY = self.spaceTimeIntervals[1].1
        let minZ = self.spaceTimeIntervals[2].0
        let maxZ = self.spaceTimeIntervals[2].1
        let minT = self.spaceTimeIntervals[3].0
        let maxT = self.spaceTimeIntervals[3].1
        self.measureBlock {
            let _ = self.spaceTimePoints.filter({ (point: STPoint) -> Bool in
                return minX <= Double(point.x) && maxX >= Double(point.x) && minY <= Double(point.y) && maxY >= Double(point.y)
                    && minZ <= Double(point.z) && maxZ >= Double(point.z) && minT <= Double(point.t) && maxT >= Double(point.t)
            })
        }
    }
    
}
