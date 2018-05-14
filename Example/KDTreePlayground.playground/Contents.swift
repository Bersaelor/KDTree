//: Playground - noun: a place where people can play

import UIKit
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
        return self.point.squaredDistance(to: point)
    }
}

var points = [GridP]()
for x in 0...10 {
    for y in 0...10 {
        points.append(GridP(point: CGPoint(x: x, y: y)))
    }
}
print("\(points.count) added")
let criteria: (GridP) -> Bool = { $0.point.x > 2 }
let tree = KDTree(values: points)
var somePoints = [GridP]()
for point in tree {
    guard somePoints.count < 10 else { break }
    if criteria(point) { somePoints.append(point) }
}
