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

enum Color {
    case blue
    case red
    case grey(value: Double)
}

extension Color: Codable {
    enum MyCodingError: Error {
        case decoding(String)
    }
    
    private enum CodingKeys: String, CodingKey {
        case blue
        case red
        case grey
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try? values.decode(Double.self, forKey: .grey) {
            self = .grey(value: value)
            return
        } else if let _ = try? values.decode(Int.self, forKey: .blue) {
            self = .blue
            return
        } else if let _ = try? values.decode(Int.self, forKey: .red) {
            self = .red
            return
        }
        throw MyCodingError.decoding("Whoops! \(dump(values))")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .blue:
            try container.encode(0, forKey: CodingKeys.blue)
        case .red:
            try container.encode(0, forKey: CodingKeys.red)
        case .grey(let value):
            try container.encode(value, forKey: CodingKeys.grey)
        }
    }
}

let encoder = JSONEncoder()
//encoder.outputFormatting = .prettyPrinted

let titleColor = Color.blue
let bodyColor = Color.grey(value: 0.5)
let colors = [titleColor, bodyColor]
let data = try encoder.encode(colors)
let json = String.init(data: data, encoding: .utf8)
print(data)
print(json ?? "?")

let decoder = JSONDecoder()
let decodedArray = try decoder.decode([Color].self, from: data)
print(decodedArray)

do {
} catch {
    print(error)
}


