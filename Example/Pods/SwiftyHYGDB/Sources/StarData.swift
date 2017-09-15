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
    public let pmra: Double
    public let pmdec: Double
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
        case pmra            = "pr"
        case pmdec           = "pd"
        case rv              = "v"
        case mag             = "m"
        case absmag          = "a"
        case spectralType    = "s"
        case colorIndex      = "c"
    }
}
