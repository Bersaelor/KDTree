import XCTest
@testable import KDTree

// This is the test file used when running `swift test` from the root repo
// Eventually I will merge as much as possible of the `Tests/KDTreeTests` folder with `Example/Tests`
// as they really should work both on linux and macos

// test data

#if os(Linux) || CYGWIN
public func arc4random() -> UInt32 {
    return UInt32(random())
}
#endif


extension CGPoint {
    static func random() -> CGPoint {
        return CGPoint(x: CGFloat.random(-1, end: 1), y: CGFloat.random(-1, end: 1))
    }
    
    var norm: CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
}

extension CGFloat {
    static func random(_ start: CGFloat = 0.0, end: CGFloat = 1.0) -> CGFloat {
        return (end-start)*CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + start
    }
}

struct STPoint: Equatable {
    let x: CGFloat
    let y: CGFloat
    let z: CGFloat
    let t: CGFloat
}

extension STPoint: KDTreePoint {
    internal static var dimensions = 4
    
    internal func kdDimension(_ dimension: Int) -> Double {
        switch dimension {
        case 0:
            return Double(self.x)
        case 1:
            return Double(self.y)
        case 2:
            return Double(self.z)
        default:
            return Double(self.t)
        }
    }
    
    static var kdDimensionFunctions: [(STPoint) -> Double] {
        return [{ Double($0.x) },
                { Double($0.y) },
                { Double($0.z) },
                { Double($0.z) }]
    }
    
    func squaredDistance(to otherPoint: STPoint) -> Double {
        let x = self.x - otherPoint.x
        let y = self.y - otherPoint.y
        let z = self.z - otherPoint.z
        let t = self.t - otherPoint.t
        return Double(x*x + y*y + z*z + t*t)
    }
}

// MARK: Tests

class KDTreeTests: XCTestCase {
    var points: [CGPoint] = []
    var largeTree: KDTree<CGPoint> = KDTree(values: [])
    let rangeIntervals: [(Double, Double)] = [(0.2, 0.3), (0.45, 0.75)]
    
    var spaceTimePoints: [STPoint] = []
    var spaceTimeTree: KDTree<STPoint> = KDTree(values: [])
    let spaceTimeIntervals: [(Double, Double)] = [(0.2, 0.4), (0.45, 0.75), (0.15, 0.85), (0.1, 0.9)]
    
    override func setUp() {
        super.setUp()
        
        points = Array(0..<1000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
        largeTree = KDTree(values: self.points)
        
        spaceTimePoints = Array(0..<100).map({_ in STPoint(x: CGFloat.random(), y: CGFloat.random(),
                                                           z: CGFloat.random(), t: CGFloat.random())})
        spaceTimeTree = KDTree(values: self.spaceTimePoints)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test00_tenPointTree() {
        let tenPoints = Array(1...10).map { CGPoint(x: $0, y: $0) }
        let tenTree = KDTree(values: tenPoints)
        XCTAssertEqual((tenTree.filter({$0.x > 5}) as [CGPoint]).count, 5, "filter x > 5 contains 5")
        
        let sum = tenTree.reduce(0) { $0 + Int($1.x)}
        XCTAssertEqual(sum, 55, "sum should be 55")
        
        let filteredTree: KDTree<CGPoint> = tenTree.filter({$0.x > 5})
        let filterAndMap: [CGFloat] = filteredTree.map({ $0.x + $0.y })
        let mapAndFilter = tenTree.map({ $0.x + $0.y }).filter({$0 > 10})
        XCTAssertEqual(mapAndFilter, filterAndMap, "array map to equal tree map")
        
        var sum2 = 0.0
        tenPoints.forEach { sum2 += sqrt(Double($0.x*$0.x + $0.y*$0.y)) }
        let avg = sum2 / Double(tenPoints.count)
        XCTAssertEqual(avg, 7.78, accuracy: 0.01, "Average norm by forEach")
        
        let closeTo5 = tenTree.nearest(to: CGPoint(x: 4.9, y: 4.9))
        XCTAssertEqual(closeTo5, CGPoint(x: 5.0, y: 5.0))
        
        let four = tenTree.nearest(to: CGPoint(x: 4.9, y: 4.9), where: { $0.x != 5.0 })
        XCTAssertEqual(four, CGPoint(x: 4.0, y: 4.0))
        
        let two = tenTree.nearestK(2, to: CGPoint(x: 4.9, y: 4.9), where: { $0.x != 5.0 })
        XCTAssertEqual(two, [CGPoint(x: 4.0, y: 4.0), CGPoint(x: 6.0, y: 6.0)])
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
        self.measure {
            pointsInRangeTree = self.largeTree.elementsIn(self.rangeIntervals)
        }
        print("pointsInRangeArray.count: \(pointsInRangeArray.count)")
        XCTAssertEqual(pointsInRangeArray.sorted { $0.x <= $1.x }, pointsInRangeTree.sorted { $0.x <= $1.x },
                       "Points in Range via Tree should equal Points via Array")
    }
    
    func test01b_RangeSearchArrayComparison() {
        let minX = self.rangeIntervals[0].0
        let maxX = self.rangeIntervals[0].1
        let minY = self.rangeIntervals[1].0
        let maxY = self.rangeIntervals[1].1
        self.measure {
            _ = self.points.filter { (point: CGPoint) -> Bool in
                return minX <= Double(point.x) && maxX > Double(point.x) && minY <= Double(point.y) && maxY > Double(point.y)
            }
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
        self.measure {
            pointsInRangeTree = self.spaceTimeTree.elementsIn(self.spaceTimeIntervals)
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
        self.measure {
            _ = self.spaceTimePoints.filter { (point: STPoint) -> Bool in
                return minX <= Double(point.x) && maxX >= Double(point.x) && minY <= Double(point.y) && maxY >= Double(point.y)
                    && minZ <= Double(point.z) && maxZ >= Double(point.z) && minT <= Double(point.t) && maxT >= Double(point.t)
            }
        }
    }

    static var allTests = [
        ("test00_tenPointTree", test00_tenPointTree),
        ("test01_RangeSearchPerformance", test01_RangeSearchPerformance),
        ("test01b_RangeSearchArrayComparison", test01b_RangeSearchArrayComparison),
        ("test02_STRangeSearchPerformance", test02_STRangeSearchPerformance),
        ("test02b_STRangeSearchArrayComparison", test02b_STRangeSearchArrayComparison)
    ]
}
