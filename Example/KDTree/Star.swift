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

struct Star {
    let db_id: Int
    let hip_id: Int?
    let hd_id: Int?
    let hr_id: Int?
    let gl_id: Int?
    let bayer_flamstedt: String
    let properName: String
    let right_ascension: Double
    let declination: Double
    let distance: Double
    let pmra: Double
    let pmdec: Double
    let rv: Double
    let mag: Double
    let absmag: Double
    let spect: String
    let ci: String
    
    init? (row: String) {
        let fields = row.replacingOccurrences(of: "\"", with: "").components(separatedBy: ",")
        
        guard fields.count > 13 else {
            xcLog.error("Not enough rows in \(fields)")
            return nil
        }
        guard let db_id = Int(fields[0]),
            let right_ascension = Double(fields[7]),
            let declination = Double(fields[8]),
            let dist = Double(fields[9]),
            let pmra = Double(fields[10]),
            let pmdec = Double(fields[11]),
            let rv = Double(fields[12]),
            let mag = Double(fields[13]),
            let absmag = Double(fields[14])
            else {
                xcLog.error("Invalid Row: \(row), \n fields: \(fields)")
                return nil
        }
        
        self.db_id = db_id
        self.hip_id = Int(fields[1])
        self.hd_id = Int(fields[2])
        self.hr_id = Int(fields[3])
        self.gl_id = Int(fields[4])
        self.bayer_flamstedt = fields[5]
        self.properName = fields[6]
        self.right_ascension = right_ascension
        self.declination = declination
        self.distance = dist
        self.pmra = pmra
        self.pmdec = pmdec
        self.rv = rv
        self.mag = mag
        self.absmag = absmag
        self.spect = fields[14]
        self.ci = fields[15]

    }
}

// swiftlint:enable variable_name

func == (lhs: Star, rhs: Star) -> Bool {
    return lhs.db_id == rhs.db_id
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
