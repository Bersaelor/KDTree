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
    public let hip_id: Int32?
    public let hd_id: Int32?
    public let hr_id: Int32?
    public let gl_id: String?
    public let bayer_flamstedt: String?
    public let properName: String?
    public let distance: Double
    public let rv: Double?
    public let mag: Double
    public let absmag: Double
    public let spectralType: String?
    public let colorIndex: Float?

    enum CodingKeys: String, CodingKey {
        case right_ascension = "r"
        case declination     = "d"
        case hip_id          = "hi"
        case hd_id           = "hd"
        case hr_id           = "hr"
        case gl_id           = "gl"
        case bayer_flamstedt = "b"
        case properName      = "p"
        case distance        = "i"
        case rv              = "v"
        case mag             = "m"
        case absmag          = "a"
        case spectralType    = "s"
        case colorIndex      = "c"
    }
}

extension StarData {
    public var csvLine: String {
        var result = (hip_id?.description ?? "").appending(",")
        result.append((hd_id?.description ?? "").appending(","))
        result.append((hr_id?.description ?? "").appending(","))
        result.append((gl_id?.description ?? "").appending(","))
        result.append((bayer_flamstedt ?? "").appending(","))
        result.append((properName ?? "").appending(","))
        result.append(right_ascension.compressedString.appending(","))
        result.append(declination.compressedString.appending(","))
        result.append(distance.compressedString.appending(","))
        result.append((rv?.compressedString ?? "").appending(","))
        result.append(mag.compressedString.appending(","))
        result.append(absmag.compressedString.appending(","))
        result.append((spectralType ?? "").appending(","))
        result.append((colorIndex?.compressedString ?? "").appending(","))
        return result
    }
}
