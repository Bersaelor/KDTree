import XCTest
import KDTree

class KDTreeTest: XCTestCase {
    
    func testNearestK_LookUpDistantSubTreesIfResultArrayNotFull()
    {
        let points = [CGPoint(x: 1,y: 1), CGPoint(x: 0,y: 1), CGPoint(x: -1,y: 1)]
        let tree = KDTree(values: points)
        let n = tree.nearestK(3, toElement: CGPoint(x: 1, y: 1))
        
        XCTAssertEqual(n, [CGPoint(x: 1,y: 1), CGPoint(x: 0,y: 1), CGPoint(x: -1,y: 1)])
    }
    
}
