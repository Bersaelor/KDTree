//
//  Star+CSV.swift
//  Pods-SwiftyHYGDB_Example
//
//  Created by Konrad Feiler on 10.09.17.
//

import Foundation

extension RadialStar: CSVWritable {
    public static let headerLine = "id,hip,hd,hr,gl,bf,proper,ra,dec,dist,rv,mag,absmag,spect,ci"

    public var csvLine: String? {
        guard let starData = self.starData?.value else { return nil }
        return starData.csvLine
    }
}

/// High performance initializer
extension RadialStar {
    init? (rowPtr: UnsafeMutablePointer<CChar>, advanceByYears: Float? = nil, indexers: inout SwiftyDBValueIndexers) {
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
            let dist: Double = readNumber(at: &index, stringPtr: rowPtr) else { return nil }
        let pmra: Double? = advanceByYears != nil ? readNumber(at: &index, stringPtr: rowPtr) : nil
        let pmdec: Double? = advanceByYears != nil ? readNumber(at: &index, stringPtr: rowPtr) : nil
        let rv: Float? = readNumber(at: &index, stringPtr: rowPtr)
        guard let mag: Float = readNumber(at: &index, stringPtr: rowPtr),
            let absmag: Float = readNumber(at: &index, stringPtr: rowPtr) else { return nil }
        let spectralType = readString(at: &index, stringPtr: rowPtr)
        let colorIndex: Float? = readNumber(at: &index, stringPtr: rowPtr)
        
        if let pmra = pmra, let pmdec = pmdec, let advanceByYears = advanceByYears {
            RadialStar.precess(right_ascension: &right_ascension, declination: &declination, pmra: pmra, pmdec: pmdec, advanceByYears: advanceByYears)
        }
        
        self.normalizedAscension = RadialStar.normalize(rightAscension: right_ascension)
        self.normalizedDeclination = RadialStar.normalize(declination: declination)

        let starData = StarData(right_ascension: right_ascension,
                                declination: declination,
                                db_id: dbID,
                                hip_id: hip_id,
                                hd_id: hd_id,
                                hr_id: hr_id,
                                gl_id: indexers.glIds.index(for: gl_id),
                                bayer_flamstedt: indexers.bayerFlamstedts.index(for: bayerFlamstedt),
                                properName: indexers.properNames.index(for: properName),
                                distance: dist, rv: rv,
                                mag: mag, absmag: absmag,
                                spectralType: indexers.spectralTypes.index(for: spectralType),
                                colorIndex: colorIndex)
        self.starData = Box(starData)
    }
}

// MARK: CSV Helper Methods

func indexOfCommaOrEnd(at index: Int, stringPtr: UnsafeMutablePointer<Int8>) -> Int {
    var newIndex = index
    while stringPtr[newIndex] != 0 && stringPtr[newIndex] != 44 { newIndex += 1 }
    if stringPtr[newIndex] != 0 { //if not at end of file, jump over comma
        newIndex += 1
    }
    return newIndex
}

func readString(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8>) -> String? {
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

protocol HasCFormatterString {
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

func readNumber<T: HasCFormatterString>(at index: inout Int, stringPtr: UnsafeMutablePointer<Int8> ) -> T? {
    let startIndex = index
    index = indexOfCommaOrEnd(at: index, stringPtr: stringPtr)
    
    if index - startIndex > 1 {
        var value: T = T.initialValue
        let newCPtr = stringPtr.advanced(by: startIndex)
        var scanned: Int32 = -1
        withUnsafeMutablePointer(to: &value, { valuePtr in
            let args: [CVarArg] = [valuePtr]
            scanned = withVaList(args, { (vaListPtr) -> Int32 in
                return vsscanf(newCPtr, T.cFormatString, vaListPtr)
            })
        })
        return scanned > 0 ? value : nil
    }
    return nil
}
