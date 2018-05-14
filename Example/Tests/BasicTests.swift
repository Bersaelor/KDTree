// https://github.com/Quick/Quick

import XCTest
@testable import KDTree

class BasicTests: XCTestCase {
    let points: [CGPoint] = (0..<1000).map { _ in CGPoint(x: CGFloat.random(), y: CGFloat.random()) }
    let testPoint = CGPoint(x: 2, y: 2)
    let testPoint2 = CGPoint(x: 5, y: 5)
    var kdTree: KDTree<CGPoint> = KDTree(values: [])
    var kdTreePlus: KDTree<CGPoint> = KDTree(values: [])
    
    let tenPoints = Array(1...10).map { CGPoint(x: $0, y: $0) }
    var tenTree: KDTree<CGPoint> = KDTree(values: [])

    override func setUp() {
        super.setUp()
        
        kdTree = KDTree(values: points)
        kdTreePlus = kdTree.inserting(testPoint)
        tenTree = KDTree(values: tenPoints)
    }
    
    func test01_emptyTree() {
        let emptyTree = KDTree<CGPoint>(values: [])

        XCTAssertTrue(emptyTree.isEmpty)
    }

    func test01_CGPointTree() {
        
        XCTAssertFalse(kdTree.isEmpty)
        
        XCTAssertEqual(kdTree.count, points.count)
        
        XCTAssertEqual(kdTree.elements.count, points.count, "tree should have as many elements as points")

        XCTAssertEqual(kdTreePlus.count, points.count + 1, "insert should increment")

        XCTAssertEqual(kdTreePlus.removing(testPoint).count, points.count, "remove should decrement")

        XCTAssertEqual(kdTree, KDTree(values: points.reversed()), "equals KDTree from reverse elements")

        XCTAssertNotEqual(kdTreePlus, kdTree, "should not be equal kdTreePlus")
        
        XCTAssertEqual(kdTreePlus, kdTreePlus.removing(testPoint2), "removing point that isn't contained should keep equal")

        XCTAssertTrue(kdTreePlus.contains(testPoint), "should contain inserted point")
    }

    func test02_RemovingManyPoints() {
        var smallerPoints = points
        var smallerTree = kdTree
        for _ in 0..<50 {
            let n = Int(arc4random_uniform(UInt32(smallerPoints.count)))
            let pointToBeRemoved = smallerPoints[n]
            smallerPoints.remove(at: n)
            smallerTree = smallerTree.removing(pointToBeRemoved)
        }
        smallerPoints = smallerPoints.sorted(by: { $0.x < $1.x })
        
        XCTAssertEqual(smallerPoints, smallerTree.elements.sorted(by: { $0.x < $1.x }), "remove many should still have correct count")

        XCTAssertGreaterThan(kdTree.depth, 2, "should be deeper then 2")
    }
    
    func test03_Filter() {
        XCTAssertEqual(tenTree.filter({ $0.x > 5 }).count, 5, "filter x > 5 contains 5")
    }
    
    func test04_Reduce() {
        let sum = tenTree.reduce(0) { $0 + Int($1.x) }
        
        XCTAssertEqual(sum, 55, "filter x > 5 contains 5")
    }
    
    func test05_ArrayMap() {
        let filteredTree: KDTree<CGPoint> = tenTree.filter { $0.x > 5 }
        let filterAndMap: [CGFloat] = filteredTree.map { $0.x + $0.y }
        let mapAndFilter = tenTree.map({ $0.x + $0.y }).filter({ $0 > 10 })

        XCTAssertEqual(mapAndFilter, filterAndMap, "array map to equal tree map")
    }
    
    func test05_FilterAndMap() {
        let filterAndMap = tenTree.filter({ $0.norm > 5 }).map({ CGRect(x: $0.x, y: $0.y, width: 0.0, height: 0.0)
            .insetBy(dx: -0.5, dy: -0.5) })
        let mapAndFilter = tenTree.map({ CGRect(x: $0.x, y: $0.y, width: 0.0, height: 0.0)
            .insetBy(dx: -0.5, dy: -0.5) }).filter({ $0.origin.norm > 4.5 })
        
        XCTAssertEqual(mapAndFilter, filterAndMap, "filtered map to Tree of Rects equals mapped filter")
    }
    
    func test06_SequenceIteration() {
        var sum: CGFloat = 0
        for element in tenTree {
            sum += element.x
        }
        
        XCTAssertEqual(sum, 55, accuracy: 0.01, "Can be iterated as a sequence")
    }

    func test07_ForEach() {
        var sum = 0.0
        tenPoints.forEach { sum += sqrt(Double($0.x*$0.x + $0.y*$0.y)) }
        let avg = sum / Double(tenPoints.count)
        
        XCTAssertEqual(avg, 7.78, accuracy: 0.01)
    }
}
