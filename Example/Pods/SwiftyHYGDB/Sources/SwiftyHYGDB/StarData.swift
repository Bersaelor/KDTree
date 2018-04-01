//
//  StarData.swift
//  SwiftyHYGDB
//
//  Created by Konrad Feiler on 11.09.17.
//

import Foundation

// swiftlint:disable variable_name

public struct StarData: Codable {
    public let right_ascension: Float
    public let declination: Float
    public let spectralType: Int16
    public let gl_id: Int16
    public let bayer_flamstedt: Int16
    public let properName: Int16
    public let db_id: Int32
    public let hip_id: Int32
    public let hd_id: Int32
    public let hr_id: Int32
    public let rv: Float
    public let mag: Float
    public let absmag: Float
    public let colorIndex: Float

    public let distance: Double

    enum CodingKeys: String, CodingKey {
        case right_ascension = "r"
        case declination     = "d"
        case db_id           = "i"
        case hip_id          = "hi"
        case hd_id           = "hd"
        case hr_id           = "hr"
        case gl_id           = "gl"
        case bayer_flamstedt = "b"
        case properName      = "p"
        case distance        = "e"
        case rv              = "v"
        case mag             = "m"
        case absmag          = "a"
        case spectralType    = "s"
        case colorIndex      = "c"
    }
}

extension StarData {
    init(right_ascension: Float, declination: Float,
         db_id: Int32,
         hip_id: Int32?,
         hd_id: Int32?,
         hr_id: Int32?,
         gl_id: Int16,
         bayer_flamstedt: Int16,
         properName: Int16,
         distance: Double,
         rv: Float?,
         mag: Float, absmag: Float,
         spectralType: Int16, colorIndex: Float?) {
        
        self.right_ascension = right_ascension
        self.declination = declination
        self.db_id = db_id
        self.hip_id = hip_id ?? -1
        self.hd_id = hd_id ?? -1
        self.hr_id = hr_id ?? -1
        self.gl_id = gl_id
        self.bayer_flamstedt = bayer_flamstedt
        self.properName = properName
        self.distance = distance
        self.rv = rv ?? 0
        self.mag = mag
        self.absmag = absmag
        self.spectralType = spectralType
        self.colorIndex = colorIndex ?? 0
    }
}

extension StarData {
    public func getGlId() -> String? {
        return gl_id != SwiftyHYGDB.missingValueIndex ? SwiftyHYGDB.glIds[Int(gl_id)] : nil
    }
    
    public func getBayerFlamstedt() -> String? {
        return bayer_flamstedt != SwiftyHYGDB.missingValueIndex ? SwiftyHYGDB.bayerFlamstedts[Int(bayer_flamstedt)] : nil
    }
    
    public func getProperName() -> String? {
        return properName != SwiftyHYGDB.missingValueIndex ? SwiftyHYGDB.properNames[Int(properName)] : nil
    }
    
    public func getSpectralType() -> String? {
        return spectralType >= 0 ? SwiftyHYGDB.spectralTypes[Int(spectralType)] : nil
    }
}

extension StarData {
    public var csvLine: String {
        var result = (db_id.description).appending(",")
        result.append((hip_id != -1 ? hip_id.description : "").appending(","))
        result.append((hd_id != -1 ? hd_id.description : "").appending(","))
        result.append((hr_id != -1 ? hr_id.description : "").appending(","))
        result.append((getGlId() ?? "").appending(","))
        result.append((getBayerFlamstedt() ?? "").appending(","))
        result.append((getProperName() ?? "").appending(","))
        result.append(right_ascension.compressedString.appending(","))
        result.append(declination.compressedString.appending(","))
        result.append(distance.compressedString.appending(","))
        result.append((rv.compressedString).appending(","))
        result.append(mag.compressedString.appending(","))
        result.append(absmag.compressedString.appending(","))
        result.append((getSpectralType() ?? "").appending(","))
        result.append((colorIndex.compressedString).appending(","))
        return result
    }
}
