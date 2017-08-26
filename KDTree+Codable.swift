//
//  KDTree+Codable.swift
//  KDTree-iOS
//
//  Created by Konrad Feiler on 26.08.17.
//

import Foundation

extension KDTree where Element: Codable {
    enum KDTreeCodingError: Error {
        case decoding(String)
    }
    
    private enum CodingKeys: String, CodingKey {
        case l
        case n
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let _ = try? values.decode(Int.self, forKey: .l) {
            self = .leaf
            return
        } else if let value = try? values.decode(Int.self, forKey: .red) {
            self = .red
            return
        }
        throw KDTreeCodingError.decoding("Failed to decode KDTree: \(dump(values))")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .leaf:
            try container.encode(0, forKey: CodingKeys.l)
        case let .node(left, value, dim, right):
            try container.encode(value, forKey: CodingKeys.grey)
        }
    }
}
