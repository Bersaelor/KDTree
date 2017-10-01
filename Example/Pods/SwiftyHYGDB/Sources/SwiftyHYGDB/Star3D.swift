//
//  Star.swift
//
//  Created by Konrad Feiler on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public struct Star3D {
    public let dbID: Int32
    public let x: Float
    public let y: Float
    public let z: Float
    public let starData: Box<StarData>?
}

extension Star3D {
    
    init? (row: String, advanceByYears: Double? = nil, indexers: inout SwiftyDBValueIndexers) {
        let fields = row.components(separatedBy: ",")
        
        guard fields.count > 13 else {
            print("Not enough rows in \(fields)")
            return nil
        }
        
        guard let dbID = Int32(fields[0]),
            var right_ascension = Float(fields[7]),
            var declination = Float(fields[8]),
            let dist = Double(fields[9]),
            let mag = Float(fields[13]),
            let absmag = Float(fields[14]),
            var x = Float(fields[16]),
            var y = Float(fields[17]),
            var z = Float(fields[18])
            else {
                print("Invalid Row: \(row), \n fields: \(fields)")
                return nil
        }
        
        if let advanceByYears = advanceByYears, let pmra = Double(fields[10]), let pmdec = Double(fields[11]),
            let vx = Double(fields[19]), let vy = Double(fields[20]), let vz = Double(fields[21])
        {
            RadialStar.precess(right_ascension: &right_ascension, declination: &declination, pmra: pmra, pmdec: pmdec, advanceByYears: Float(advanceByYears))
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
                                      hip_id: Int32(fields[1]),
                                      hd_id: Int32(fields[2]),
                                      hr_id: Int32(fields[3]),
                                      gl_id: indexers.glIds.index(for: fields[4]),
                                      bayer_flamstedt: indexers.glIds.index(for: fields[5]),
                                      properName: indexers.glIds.index(for: fields[6]),
                                      distance: dist, rv: Float(fields[12]),
                                      mag: mag, absmag: absmag,
                                      spectralType: indexers.glIds.index(for: fields[14]),
                                      colorIndex: Float(fields[15]))
        self.starData = Box(starData)
    }
    
    /// Convenience initializer when values are known. Can be used to create a test-star to search
    /// for close other stars
    ///
    /// - Parameters:
    ///   - dbID: dbID in the HYG database, optional
    ///   - starData: full star data, optional
    public init (x: Float, y: Float, z: Float, dbID: Int32 = -1, starData: Box<StarData>? = nil) {
        self.dbID = dbID
        self.x = x
        self.y = y
        self.z = z
        self.starData = starData
    }
    
    public func starMoved(x: Float, y: Float, z: Float) -> Star3D {
        let newX = self.x + x
        let newY = self.y + y
        let newZ = self.z + z
        return Star3D(dbID: self.dbID, x: newX, y: newY, z: newZ, starData: self.starData)
    }
    
    public var starPoint: Point3D {
        return Point3D(x: self.x, y: self.y, z: self.z)
    }
}

// swiftlint:enable variable_name

public func == (lhs: Star3D, rhs: Star3D) -> Bool {
    return lhs.dbID == rhs.dbID
}

extension Star3D: Equatable {}

extension Star3D: CustomDebugStringConvertible {
    public var debugDescription: String {
        let distanceString = starData?.value.distance ?? Double.infinity
        let magString = starData?.value.mag ?? Float.infinity
        return "🌠: ".appending(starData?.value.getProperName() ?? "N.A.")
            .appending(", Hd(\(starData?.value.hd_id ?? -1)) + HR(\(starData?.value.hr_id ?? -1))")
            .appending("Gliese(\(starData?.value.getGlId() ?? "")), BF(\(starData?.value.getBayerFlamstedt() ?? "")):")
            .appending("\(starData?.value.right_ascension ?? 100), \(starData?.value.declination ?? 100),"
                .appending(" \( distanceString ) mag: \(magString)"))
    }
}
