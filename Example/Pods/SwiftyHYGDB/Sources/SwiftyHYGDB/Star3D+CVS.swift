//
//  Star3D+CSV.swift
//  Pods-SwiftyHYGDB_Example
//
//  Created by Konrad Feiler on 10.09.17.
//

import Foundation

extension Star3D: CSVWritable {
    public static let headerLine = "id,hip,hd,hr,gl,bf,proper,ra,dec,dist,rv,mag,absmag,spect,ci,x,y,z"

    public var csvLine: String? {
        guard let starData = self.starData?.value else { return nil }
        var result = starData.csvLine
        result.append((x.compressedString).appending(","))
        result.append((y.compressedString).appending(","))
        result.append((z.compressedString).appending(","))
        return result
    }
}

/// High performance initializer
extension Star3D {
    init? (rowPtr: UnsafeMutablePointer<CChar>, advanceByYears: Double? = nil, indexers: inout SwiftyDBValueIndexers) {
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
        guard var x: Float = readNumber(at: &index, stringPtr: rowPtr),
            var y: Float = readNumber(at: &index, stringPtr: rowPtr),
            var z: Float = readNumber(at: &index, stringPtr: rowPtr) else { return nil }

        if let pmra = pmra, let pmdec = pmdec, let advanceByYears = advanceByYears,
            let vx: Double = readNumber(at: &index, stringPtr: rowPtr),
            let vy: Double = readNumber(at: &index, stringPtr: rowPtr),
            let vz: Double = readNumber(at: &index, stringPtr: rowPtr) {
            
            RadialStar.precess(right_ascension: &right_ascension, declination: &declination,
                               pmra: pmra, pmdec: pmdec, advanceByYears: Float(advanceByYears))
            x += Float(advanceByYears * vx)
            y += Float(advanceByYears * vy)
            z += Float(advanceByYears * vz)
        }
        
        self.dbID = dbID
        self.x = x
        self.y = y
        self.z = z
        
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
