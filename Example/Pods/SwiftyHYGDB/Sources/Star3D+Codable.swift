//
//  Star3D+Codable.swift
//  SwiftyHYGDB
//
//  Created by Konrad Feiler on 15.09.17.
//

import Foundation

extension Star3D: Codable {
    private enum CodingKeys: String, CodingKey {
        case dbID                   = "d"
        case x                      = "x"
        case y                      = "y"
        case z                      = "z"
        case starData               = "s"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dbID        = try container.decode(Int32.self, forKey: .dbID)
        x           = try container.decode(Float.self, forKey: .x)
        y           = try container.decode(Float.self, forKey: .y)
        z           = try container.decode(Float.self, forKey: .z)
        let starValue: StarData  = try container.decode(StarData.self, forKey: .starData)
        starData = Box(starValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let value = starData?.value else {
            print("Failed to decode starData's value for star \(dbID)")
            return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dbID, forKey: .dbID)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
        try container.encode(value, forKey: .starData)
    }
}
