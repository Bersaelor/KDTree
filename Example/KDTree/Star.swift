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
    let right_ascension: Float
    let declination: Float
    let hip_id: Int32?
    let hd_id: Int32?
    let hr_id: Int32?
    let gl_id: String?
    let bayer_flamstedt: String?
    let properName: String?
    let distance: Double
    let pmra: Double
    let pmdec: Double
    let rv: Double?
    let mag: Double
    let absmag: Double
    let spectralType: String?
    let colorIndex: Float?
}

struct Star {
    let dbID: Int32
    let normalizedAscension: Float
    let normalizedDeclination: Float
    let starData: Box<StarData>?
    
    var starPoint: CGPoint {
        guard let data = starData?.value else { return CGPoint.zero }
        return CGPoint(x: CGFloat(data.right_ascension), y: CGFloat(data.declination))
    }
    
    init? (row: String, advanceByYears: Float? = nil) {
        let fields = row.components(separatedBy: ",")
        
        guard fields.count > 13 else {
            xcLog.error("Not enough rows in \(fields)")
            return nil
        }
        
        guard let dbID = Int32(fields[0]),
            var right_ascension = Float(fields[7]),
            var declination = Float(fields[8]),
            let dist = Double(fields[9]),
            let pmra = Double(fields[10]),
            let pmdec = Double(fields[11]),
            let mag = Double(fields[13]),
            let absmag = Double(fields[14])
            else {
                xcLog.error("Invalid Row: \(row), \n fields: \(fields)")
                return nil
        }

        xcLog.debug("(\(right_ascension), \(declination)), pm: (\(pmra), \(pmdec))")
        Star.precess(right_ascension: &right_ascension, declination: &declination, pmra: pmra, pmdec: pmdec, advanceByYears: advanceByYears)
        xcLog.debug("-> (\(right_ascension), \(declination))")

        self.dbID = dbID
        self.normalizedAscension = Star.normalizedAscension(rightAscension: right_ascension)
        self.normalizedDeclination = Star.normalizedDeclination(declination: declination)
        let starData = StarData(right_ascension: right_ascension,
                                declination: declination,
                                hip_id: Int32(fields[1]),
                                hd_id: Int32(fields[2]),
                                hr_id: Int32(fields[3]),
                                gl_id: fields[4],
                                bayer_flamstedt: fields[5],
                                properName: fields[6],
                                distance: dist, pmra: pmra, pmdec: pmdec, rv: Double(fields[12]),
                                mag: mag, absmag: absmag, spectralType: fields[14], colorIndex: Float(fields[15]))
        self.starData = Box(starData)
    }
    
    init (ascension: Float, declination: Float, dbID: Int32 = -1, starData: Box<StarData>? = nil) {
        self.dbID = dbID
        self.normalizedAscension = Star.normalizedAscension(rightAscension: ascension)
        self.normalizedDeclination = Star.normalizedDeclination(declination: declination)
        self.starData = starData
    }
    
    private static func precess(right_ascension: inout Float, declination: inout Float, pmra: Double, pmdec: Double, advanceByYears: Float?) {
        guard let advanceByYears = advanceByYears, advanceByYears > 0 else { return }
        declination = Float(Double(declination) + Double(advanceByYears) * pmdec / (3600 * 1000) )
        let underMinus90 = abs(declination + 90)
        if declination < -90 {
            declination = underMinus90 - 90
            right_ascension = (right_ascension + 12 > 24) ? right_ascension - 12 : right_ascension + 12
        }
        else if declination > 90 {
            let over90 = declination - 90
            declination = 90 - over90
            right_ascension = (right_ascension + 12 > 24) ? right_ascension - 12 : right_ascension + 12
        }
        
        right_ascension = Float(Double(right_ascension) + Double(advanceByYears) * pmra / (3600 * 1000) )
        if right_ascension < 0.0 { right_ascension += Float(ascensionRange) }
        else if right_ascension > Float(ascensionRange) { right_ascension -= Float(ascensionRange) }
    }
    
    /// High performance initializer
    init? (rowPtr: UnsafeMutablePointer<CChar>, advanceByYears: Float? = nil) {
        var index = 0

        guard let dbID: Int32 = readNumber(at: &index, stringPtr: rowPtr) else { return nil }
        
        let hip_id: Int32? = readNumber(at: &index, stringPtr: rowPtr)
        let hd_id: Int32? = readNumber(at: &index, stringPtr: rowPtr)
        let hr_id: Int32? = readNumber(at: &index, stringPtr: rowPtr)
        let gl_id = readString(at: &index, stringPtr: rowPtr)
        let bayerFlamstedt = readString(at: &index, stringPtr: rowPtr)
        let properName = readString(at: &index, stringPtr: rowPtr)
        guard var right_ascension: Float = readNumber(at: &index, stringPtr: rowPtr),
            var declination: Float = readNumber(at: &index, stringPtr: rowPtr),
            let dist: Double = readNumber(at: &index, stringPtr: rowPtr),
            let pmra: Double = readNumber(at: &index, stringPtr: rowPtr),
            let pmdec: Double = readNumber(at: &index, stringPtr: rowPtr) else { return nil }
        let rv: Double? = readNumber(at: &index, stringPtr: rowPtr)
        guard let mag: Double = readNumber(at: &index, stringPtr: rowPtr),
            let absmag: Double = readNumber(at: &index, stringPtr: rowPtr) else { return nil }
        let spectralType = readString(at: &index, stringPtr: rowPtr)
        let colorIndex: Float? = readNumber(at: &index, stringPtr: rowPtr)

        xcLog.debug("(\(right_ascension), \(declination)), pm: (\(pmra), \(pmdec))")
        Star.precess(right_ascension: &right_ascension, declination: &declination, pmra: pmra, pmdec: pmdec, advanceByYears: advanceByYears)
        xcLog.debug("-> (\(right_ascension), \(declination))")

        self.dbID = dbID
        self.normalizedAscension = Star.normalizedAscension(rightAscension: right_ascension)
        self.normalizedDeclination = Star.normalizedDeclination(declination: declination)
        let starData = StarData(right_ascension: right_ascension,
                                declination: declination,
                                hip_id: hip_id,
                                hd_id: hd_id,
                                hr_id: hr_id,
                                gl_id: gl_id,
                                bayer_flamstedt: bayerFlamstedt,
                                properName: properName,
                                distance: dist, pmra: pmra, pmdec: pmdec, rv: rv,
                                mag: mag, absmag: absmag, spectralType: spectralType, colorIndex: colorIndex)
        self.starData = Box(starData)
    }
    
    func starMoved(ascension: Float, declination: Float) -> Star {
        let normalizedAsc = self.normalizedAscension + Star.normalizedAscension(rightAscension: ascension)
        let normalizedDec = self.normalizedDeclination + Star.normalizedDeclination(declination: declination)
        return Star(ascension: Star.rightAscension(normalizedAscension: normalizedAsc),
                    declination: Star.declination(normalizedDeclination: normalizedDec),
                    dbID: self.dbID, starData: self.starData)
    }
}

let ascensionRange: CGFloat = 24.0
let declinationRange: CGFloat = 180

extension Star {
    static func normalizedAscension(rightAscension: Float) -> Float {
        return rightAscension/Float(ascensionRange)
    }
    static func normalizedDeclination(declination: Float) -> Float {
        return (declination + 90)/Float(declinationRange)
    }
    
    static func rightAscension(normalizedAscension: Float) -> Float {
        return Float(ascensionRange) * normalizedAscension
    }
    static func declination(normalizedDeclination: Float) -> Float {
        return normalizedDeclination * Float(declinationRange) - 90
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
        return dimension == 0 ? Double(self.normalizedAscension) : Double(self.normalizedDeclination)
    }
    
    public func squaredDistance(to otherPoint: Star) -> Double {
        let x = self.normalizedAscension - otherPoint.normalizedAscension
        let y = self.normalizedDeclination - otherPoint.normalizedDeclination
        return Double(x*x + y*y)
    }
}

extension Star: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        let distanceString = starData?.value.distance ?? Double.infinity
        let magString = starData?.value.mag ?? Double.infinity
        return "🌠: ".appending(starData?.value.properName ?? "N.A.")
            .appending(", Hd(\(starData?.value.hd_id ?? -1)) + HR(\(starData?.value.hr_id ?? -1))")
            .appending("Gliese(\(starData?.value.gl_id ?? "")), BF(\(starData?.value.bayer_flamstedt ?? "")):")
            .appending("\(starData?.value.right_ascension ?? 100), \(starData?.value.declination ?? 100),"
            .appending(" \( distanceString ) mag: \(magString)"))
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
    static var cFormatString: [Int8] { get }
    static var initialValue: Self { get }
}

extension Int32: HasCFormatterString {
    static let cFormatString: [Int8] = [37, 100] // %d
    static let initialValue: Int32 = -1
}

extension Float: HasCFormatterString {
    static let cFormatString: [Int8] = [37, 102] // %f
    static let initialValue: Float = 0.0
}

extension Double: HasCFormatterString {
    static let cFormatString: [Int8] = [37, 108, 102] // %lf
    static let initialValue: Double = 0.0
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
            scanned = vsscanf(newCPtr, T.cFormatString, getVaList(args))
        })
        return scanned > 0 ? value : nil
    }
    return nil
}
