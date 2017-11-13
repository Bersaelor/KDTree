// https://github.com/Quick/Quick

import XCTest
@testable import KDTree

class NearestNeighbourTest: XCTestCase {
    var tenPoints: [CGPoint] = []
    var tenTree: KDTree<CGPoint> = KDTree(values: [])
    var nearestPointsFromArray: [CGPoint] = []
    
    override func setUp() {
        super.setUp()
        tenPoints = Array(1...10).map { CGPoint(x: $0, y: $0) }
        tenTree = KDTree(values: tenPoints)
    }
    
    func test01_nearestNeighbour_for_pointA() {
        let point = CGPoint(x: 4.3, y: 4.5)

        XCTAssertNotNil(tenTree.nearest(to: point))
        XCTAssertEqual(tenTree.nearest(to: point), CGPoint(x: 4.0, y: 4.0))
    }
    
    func test02_nearestNeighbour_for_pointB() {
        let point = CGPoint(x: 5.2, y: 5.5)
        
        XCTAssertNotNil(tenTree.nearest(to: point))
        XCTAssertEqual(tenTree.nearest(to: point), CGPoint(x: 5.0, y: 5.0))
    }

    func test03_nearestNeighbour_for_pointC() {
        let point = CGPoint(x: 4.9, y: 4.5)
        
        XCTAssertNotNil(tenTree.nearest(to: point))
        XCTAssertEqual(tenTree.nearest(to: point), CGPoint(x: 5.0, y: 5.0))
    }

    func test04_SpecialCase() {
        // GIVEN: Special set of points
        let points = [CGPoint(x: -0.5, y: 0),
                      CGPoint(x: -0.1, y: -1),
                      CGPoint(x: 0.0, y: -1.0),
                      CGPoint(x: 0.1, y: 0.5),
                      CGPoint(x: 1.0, y: 0.0)]
        // WHEN: creating a tree
        let tree = KDTree(values: points)
        // THEN:
        XCTAssertEqual(tree.nearest(to: CGPoint(x: -0.1, y: 0.5)), points[3], "search should bubble over after finding firstBest")
    }
    
    func test05_WholeSubTree() {
        // GIVEN:
        let points = [CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: -1, y: 1)]
        // WHEN: creating a tree
        let tree = KDTree(values: points)
        // THEN:
        XCTAssertEqual(tree.nearestK(3, to: CGPoint(x: 1, y: 1)), points, "3 nearest points should be all 3")
    }
}
