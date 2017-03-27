//
//  Star.swift
//  KDTree
//
//  Created by Konrad Feiler on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import KDTree

// swiftlint:disable variable_name

struct StarData {
    let hip_id: Int32?
    let hd_id: Int32?
    let hr_id: Int32?
    let gl_id: Int32?
    let bayer_flamstedt: String?
    let properName: String?
    let distance: Double
    let pmra: Double
    let pmdec: Double
    let rv: Double?
    let mag: Double
    let absmag: Double
    let spectralType: String?
    let colorIndex: String?
}

struct Star {
    let dbID: Int32
    let right_ascension: Float
    let declination: Float
    let starData: Box<StarData>?
    
    init? (row: String) {
        let fields = row.components(separatedBy: ",")
        
        guard fields.count > 13 else {
            xcLog.error("Not enough rows in \(fields)")
            return nil
        }
        
        guard let dbID = Int32(fields[0]),
            let right_ascension = Float(fields[7]),
            let declination = Float(fields[8]),
            let dist = Double(fields[9]),
            let pmra = Double(fields[10]),
            let pmdec = Double(fields[11]),
            let mag = Double(fields[13]),
            let absmag = Double(fields[14])
            else {
                xcLog.error("Invalid Row: \(row), \n fields: \(fields)")
                return nil
        }

        self.dbID = dbID
        self.right_ascension = right_ascension
        self.declination = declination
        let starData = StarData(hip_id: Int32(fields[1]),
                                hd_id: Int32(fields[2]),
                                hr_id: Int32(fields[3]),
                                gl_id: Int32(fields[4]),
                                bayer_flamstedt: fields[5],
                                properName: fields[6],
                                distance: dist, pmra: pmra, pmdec: pmdec, rv: Double(fields[12]),
                                mag: mag, absmag: absmag, spectralType: fields[14], colorIndex: fields[15])
        self.starData = Box(starData)
    }
    
    init (ascension: Float, declination: Float, dbID: Int32 = -1, starData: Box<StarData>? = nil) {
        self.dbID = dbID
        self.right_ascension = Float(ascension)
        self.declination = Float(declination)
        self.starData = starData
    }
    
    /// High performance initializer
    init? (rowPtr: UnsafeMutablePointer<CChar>) {
        var index = 0

        guard let dbID = readInt32(at: &index, stringPtr: rowPtr) else { return nil }
        
        let hip_id = readInt32(at: &index, stringPtr: rowPtr)
        let hd_id = readInt32(at: &index, stringPtr: rowPtr)
        let hr_id = readInt32(at: &index, stringPtr: rowPtr)
        let gl_id = readInt32(at: &index, stringPtr: rowPtr)
        let bayerFlamstedt = readString(at: &index, stringPtr: rowPtr)
        let properName = readString(at: &index, stringPtr: rowPtr)
        guard let right_ascension = readFloat(at: &index, stringPtr: rowPtr),
            let declination = readFloat(at: &index, stringPtr: rowPtr),
            let dist = readDouble(at: &index, stringPtr: rowPtr),
            let pmra = readDouble(at: &index, stringPtr: rowPtr),
            let pmdec = readDouble(at: &index, stringPtr: rowPtr) else { return nil }
        let rv = readDouble(at: &index, stringPtr: rowPtr)
        guard let mag = readDouble(at: &index, stringPtr: rowPtr),
            let absmag = readDouble(at: &index, stringPtr: rowPtr), mag < 7 else { return nil }
        let spectralType = readString(at: &index, stringPtr: rowPtr)
        let colorIndex = readString(at: &index, stringPtr: rowPtr)

        self.dbID = dbID
        self.right_ascension = right_ascension
        self.declination = declination
        let starData = StarData(hip_id: hip_id,
                                hd_id: hd_id,
                                hr_id: hr_id,
                                gl_id: gl_id,
                                bayer_flamstedt: bayerFlamstedt,
                                properName: properName,
                                distance: dist, pmra: pmra, pmdec: pmdec, rv: rv,
                                mag: mag, absmag: absmag, spectralType: spectralType, colorIndex: colorIndex)
        self.starData = Box(starData)
    }
    
    func starMovedOn(ascension: Float, declination: Float) -> Star {
        return Star(ascension: self.right_ascension + ascension,
                    declination: self.declination + declination,
                    dbID: self.dbID, starData: self.starData)
    }
}

// swiftlint:enable variable_name

func == (lhs: Star, rhs: Star) -> Bool {
    return lhs.dbID == rhs.dbID
}

extension Star: Equatable {}

extension Star: KDTreePoint {
    public static var dimensions = 2
    
    public func kdDimension(_ dimension: Int) -> Double {
        return dimension == 0 ? Double(self.right_ascension) : Double(self.declination)
    }
    
    public func squaredDistance(to otherPoint: Star) -> Double {
        let x = self.right_ascension - otherPoint.right_ascension
        let y = self.declination - otherPoint.declination
        return Double(x*x + y*y)
    }
}

extension Star: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "🌠: " + (starData?.value.properName ?? "N.A.")
            + ": \(right_ascension), \(declination), \(starData?.value.distance)" + " mag: \(starData?.value.mag)"
    }
}

// MARK: CSV Helper Methods

fileprivate func indexOfCommaOrEnd(at index: Int, stringPtr: UnsafeMutablePointer<Int8>) -> Int {
    var newIndex = index
    while stringPtr[newIndex] != 0 && stringPtr[newIndex] != 44 { newIndex += 1 }
    if stringPtr[newIndex] != 0 { //if not at end of file, jump over comma
        newIndex += 1
    }
    return newIndex
}

fileprivate func readString(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8>) -> String? {
    let startIndex = index
    index = indexOfCommaOrEnd(at: index, stringPtr: stringPtr)
    
    if index - startIndex > 1 {
        let mutableStringPtr = UnsafeMutablePointer<Int8>(mutating: stringPtr)
        stringPtr[index-1] = 0
        defer { stringPtr[index-1] = 44 }
        let newCPtr = mutableStringPtr.advanced(by: startIndex)
        return String(utf8String: newCPtr)
    }
    return nil
}

fileprivate protocol HasCFormatterString {
    static var cFormatString: String { get }
    static var initialValue: Self { get }
}

extension Int32: HasCFormatterString {
    static var cFormatString: String { return "d" }
    static var initialValue: Int32 { return -1 }
}

extension Float: HasCFormatterString {
    static var cFormatString: String { return "f" }
    static var initialValue: Float { return 0.0 }
}

extension Double: HasCFormatterString {
    static var cFormatString: String { return "lf" }
    static var initialValue: Double { return 0.0 }
}

fileprivate let intFormatPtr: [Int8] = [37, 100]
fileprivate let floatFormatPtr: [Int8] = [37, 102]
fileprivate let doubleFormatPtr: [Int8] = [37, 108, 102]

fileprivate func readInt32(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8>) -> Int32? {
    let startIndex = index
    index = indexOfCommaOrEnd(at: index, stringPtr: stringPtr)
    
    if index - startIndex > 1 {
        var value: Int32 = -1
        let newCPtr = stringPtr.advanced(by: startIndex)
        var scanned: Int32 = -1
        withUnsafeMutablePointer(to: &value, { valuePtr in
            let args: [CVarArg] = [valuePtr]
            scanned = vsscanf(newCPtr, intFormatPtr, getVaList(args))
        })
        return scanned > 0 ? value : nil
    }
    return nil
}

fileprivate func readFloat(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8>) -> Float? {
    let startIndex = index
    index = indexOfCommaOrEnd(at: index, stringPtr: stringPtr)
    
    if index - startIndex > 1 {
        var value: Float = 0
        let newCPtr = stringPtr.advanced(by: startIndex)
        var scanned: Int32 = -1
        withUnsafeMutablePointer(to: &value, { valuePtr in
            let args: [CVarArg] = [valuePtr]
            scanned = vsscanf(newCPtr, floatFormatPtr, getVaList(args))
        })
        return scanned > 0 ? value : nil
    }
    return nil
}

fileprivate func readDouble(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8>) -> Double? {
    let startIndex = index
    index = indexOfCommaOrEnd(at: index, stringPtr: stringPtr)
    
    if index - startIndex > 1 {
        var value: Double = 0
        let newCPtr = stringPtr.advanced(by: startIndex)
        var scanned: Int32 = -1
        withUnsafeMutablePointer(to: &value, { valuePtr in
            let args: [CVarArg] = [valuePtr]
            scanned = vsscanf(newCPtr, doubleFormatPtr, getVaList(args))
        })
        return scanned > 0 ? value : nil
    }
    return nil
}

fileprivate func readNumber<T: HasCFormatterString>(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8> ) -> T? {
    let startIndex = index
    index = indexOfCommaOrEnd(at: index, stringPtr: stringPtr)
    
    if index - startIndex > 1 {
        var value: T = T.initialValue
        let newCPtr = stringPtr.advanced(by: startIndex)
        var scanned: Int32 = -1
        withUnsafeMutablePointer(to: &value, { valuePtr in
            let args: [CVarArg] = [valuePtr]
            scanned = vsscanf(newCPtr, "%\(index - startIndex)\(T.cFormatString)", getVaList(args))
        })
        return scanned > 0 ? value : nil
    }
    return nil
}
