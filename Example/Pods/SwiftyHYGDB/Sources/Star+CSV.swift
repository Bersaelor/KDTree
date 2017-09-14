//
//  Star+CSV.swift
//  Pods-SwiftyHYGDB_Example
//
//  Created by Konrad Feiler on 10.09.17.
//

import Foundation

extension Star {
    var csvLine: String? {
        guard let starData = self.starData?.value else { return nil }
        var result = "\(dbID),"
        result.append((starData.hip_id?.description ?? "").appending(","))
        result.append((starData.hd_id?.description ?? "").appending(","))
        result.append((starData.hr_id?.description ?? "").appending(","))
        result.append((starData.gl_id?.description ?? "").appending(","))
        result.append((starData.bayer_flamstedt ?? "").appending(","))
        result.append((starData.properName ?? "").appending(","))
        result.append(starData.right_ascension.compressedString.appending(","))
        result.append(starData.declination.compressedString.appending(","))
        result.append(starData.distance.compressedString.appending(","))
        result.append(starData.pmra.compressedString.appending(","))
        result.append(starData.pmdec.compressedString.appending(","))
        result.append((starData.rv?.compressedString ?? "").appending(","))
        result.append(starData.mag.compressedString.appending(","))
        result.append(starData.absmag.compressedString.appending(","))
        result.append((starData.spectralType ?? "").appending(","))
        result.append(starData.colorIndex?.compressedString ?? "")
        return result
    }
}

/// High performance initializer
extension Star {
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
        
        Star.precess(right_ascension: &right_ascension, declination: &declination, pmra: pmra, pmdec: pmdec, advanceByYears: advanceByYears)
        
        self.dbID = dbID
        self.normalizedAscension = Star.normalize(rightAscension: right_ascension)
        self.normalizedDeclination = Star.normalize(declination: declination)
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
}

// MARK: CSV Helper Methods

private func indexOfCommaOrEnd(at index: Int, stringPtr: UnsafeMutablePointer<Int8>) -> Int {
    var newIndex = index
    while stringPtr[newIndex] != 0 && stringPtr[newIndex] != 44 { newIndex += 1 }
    if stringPtr[newIndex] != 0 { //if not at end of file, jump over comma
        newIndex += 1
    }
    return newIndex
}

private func readString(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8>) -> String? {
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

private protocol HasCFormatterString {
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

private func readNumber<T: HasCFormatterString>(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8> ) -> T? {
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
