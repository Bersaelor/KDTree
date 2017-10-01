//
//  Point3D.swift
//  SwiftyHYGDB
//
//  Created by Konrad Feiler on 17.09.17.
//

import Foundation

public struct Point3D {
    public var x,y,z: Float
}

extension Point3D {
    public static var zero: Point3D {
        return Point3D(x: 0, y: 0, z: 0)
    }
}

public func + (left: Point3D, right: Point3D) -> Point3D {
    return Point3D(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}

public func += (left: inout Point3D, right: Point3D) {
    // swiftlint:disable:next shorthand_operator
    left = left + right
}

public func - (left: Point3D, right: Point3D) -> Point3D {
    return Point3D(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}

public func -= (left: inout Point3D, right: Point3D) {
    // swiftlint:disable:next shorthand_operator
    left = left - right
}

public func * (left: Point3D, right: Point3D) -> Point3D {
    return Point3D(x: left.x * right.x, y: left.y * right.y, z: left.z * right.z)
}

public func * (scalar: Float, right: Point3D) -> Point3D {
    return Point3D(x: scalar * right.x, y: scalar * right.y, z: scalar * right.z)
}

public func *= (left: inout Point3D, right: Float) {
    left = right * left
}
