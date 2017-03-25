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
    let hip_id: Int?
    let hd_id: Int?
    let hr_id: Int?
    let gl_id: Int?
    let bayer_flamstedt: String
    let properName: String
    let distance: Double
    let pmra: Double
    let pmdec: Double
    let rv: Double
    let mag: Double
    let absmag: Double
    let spect: String
    let ci: String
}

struct Star {
    let dbID: Int
    let right_ascension: Float
    let declination: Float
    let starData: Box<StarData>
    
    init? (row: String) {
        let fields = row.replacingOccurrences(of: "\"", with: "").components(separatedBy: ",")
        
        guard fields.count > 13 else {
            xcLog.error("Not enough rows in \(fields)")
            return nil
        }
        guard let dbID = Int(fields[0]),
            let right_ascension = Float(fields[7]),
            let declination = Float(fields[8]),
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

        self.dbID = dbID
        self.right_ascension = right_ascension
        self.declination = declination
        self.starData = Box(StarData(hip_id: Int(fields[1]),
                                     hd_id: Int(fields[2]),
                                     hr_id: Int(fields[3]),
                                     gl_id: Int(fields[4]),
                                     bayer_flamstedt: fields[5],
                                     properName: fields[6],
                                     distance: dist, pmra: pmra, pmdec: pmdec, rv: rv,
                                     mag: mag, absmag: absmag, spect: fields[14], ci: fields[15]))
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
