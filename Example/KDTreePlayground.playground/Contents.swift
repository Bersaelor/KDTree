//: Playground - noun: a place where people can play

import UIKit
import KDTree

struct GridP {
    let point: CGPoint
}

func == (lhs: GridP, rhs: GridP) -> Bool {
    return lhs.point == rhs.point
}

extension GridP: Equatable {}

extension GridP: KDTreePoint {
    static var dimensions = 2
    
    func kdDimension(_ dimension: Int) -> Double {
        return dimension == 0 ? Double(self.point.x) : Double(self.point.y)
    }
    
    func squaredDistance(to otherPoint: GridP) -> Double {
        return self.point.squaredDistance(to: point)
    }
}

var points = [GridP]()
for x in 0...2 {
    for y in 0...2 {
        points.append(GridP(point: CGPoint(x: x, y: y)))
    }
}
print("\(points.count) added")

let tree = KDTree(values: points)

print("tree count: \(tree.count)")
print("tree: \(tree)")

tree.investigateTree { (node, _, _) in
    switch node {
    case .leaf:
        return
    case let .node(left, value, level, right):
        print("Node[\(depth)]: \(value)")
    }
}

var numErrors = 0
for point in points {
    if !tree.contains(point) {
        print("Missing grid point: \(point), nearest was: \(tree.nearest(toElement: point))")
        numErrors += 1
    }
}

print("Point \(points[0]) has nearest Point: \(tree.nearest(toElement: points[0]))")
print("Point \(points[4]) has nearest Point: \(tree.nearest(toElement: points[0]))")

print("numErrors : \(numErrors)")
