//
//  Star+Codable.swift
//
//  Created by Konrad Feiler on 28.08.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

extension RadialStar: Codable {
    private enum CodingKeys: String, CodingKey {
        case normalizedAscension    = "nA"
        case normalizedDeclination  = "nD"
        case starData               = "s"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        normalizedAscension     = try container.decode(Float.self, forKey: .normalizedAscension)
        normalizedDeclination   = try container.decode(Float.self, forKey: .normalizedDeclination)
        let starValue: StarData  = try container.decode(StarData.self, forKey: .starData)
        starData = Box(starValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard let value = starData?.value else {
            print("Failed to decode starData's value for star")
            return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(normalizedAscension, forKey: .normalizedAscension)
        try container.encode(normalizedDeclination, forKey: .normalizedDeclination)
        try container.encode(value, forKey: .starData)
    }
}
