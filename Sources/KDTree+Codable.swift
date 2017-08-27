//
//  KDTree+Codable.swift
//  KDTree-iOS
//
//  Created by Konrad Feiler on 26.08.17.
//

import Foundation


//===----------------------------------------------------------------------===//
// Optional/Collection Type Conformances
//===----------------------------------------------------------------------===//
fileprivate func assertTypeIsEncodable<T>(_ type: T.Type, in wrappingType: Any.Type) {
    guard T.self is Encodable.Type else {
        if T.self == Encodable.self || T.self == Codable.self {
            preconditionFailure("\(wrappingType) does not conform to Encodable because Encodable does not conform to itself. You must use a concrete type to encode or decode.")
        } else {
            preconditionFailure("\(wrappingType) does not conform to Encodable because \(T.self) does not conform to Encodable.")
        }
    }
}
fileprivate func assertTypeIsDecodable<T>(_ type: T.Type, in wrappingType: Any.Type) {
    guard T.self is Decodable.Type else {
        if T.self == Decodable.self || T.self == Codable.self {
            preconditionFailure("\(wrappingType) does not conform to Decodable because Decodable does not conform to itself. You must use a concrete type to encode or decode.")
        } else {
            preconditionFailure("\(wrappingType) does not conform to Decodable because \(T.self) does not conform to Decodable.")
        }
    }
}

// Temporary resolution for SR-5206.
//
// The following two extension on Encodable and Decodable are used below to provide static type information where we don't have any yet.
// The wrapped contents of the below generic types have to expose their Encodable/Decodable conformance via an existential cast/their metatype.
// Since those are dynamic types without static type guarantees, we cannot call generic methods taking those arguments, e.g.
//
//   try container.encode((someElement as! Encodable))
//
// One way around this is to get elements to encode into `superEncoder`s and decode from `superDecoder`s because those interfaces are available via the existentials/metatypes.
// However, this direct encoding/decoding never gives containers a chance to intercept and do something custom on types.
//
// If we instead expose this custom private functionality of writing to/reading from containers directly, the containers do get this chance.
// FIXME: Remove when conditional conformance is available.
extension Encodable {
    fileprivate func __encode(to container: inout SingleValueEncodingContainer) throws { try container.encode(self) }
    fileprivate func __encode(to container: inout UnkeyedEncodingContainer)     throws { try container.encode(self) }
    fileprivate func __encode<Key>(to container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws { try container.encode(self, forKey: key) }
}
// FIXME: Remove when conditional conformance is available.
extension Decodable {
    // Since we cannot call these __init, we'll give the parameter a '__'.
    fileprivate init(__from container: SingleValueDecodingContainer)   throws { self = try container.decode(Self.self) }
    fileprivate init(__from container: inout UnkeyedDecodingContainer) throws { self = try container.decode(Self.self) }
    fileprivate init<Key>(__from container: KeyedDecodingContainer<Key>, forKey key: Key) throws { self = try container.decode(Self.self, forKey: key) }
}

// FIXME: Uncomment when conditional conformance is available.
extension KDTree : Encodable /* where Element : Encodable */ {
    public func encode(to encoder: Encoder) throws {
        assertTypeIsEncodable(Element.self, in: type(of: self))
        
        var container = encoder.singleValueContainer()
        switch self {
        case .leaf: try container.encodeNil()
        case let .node(left, value, dim, right):
            try (value as! Encodable).__encode(to: &container)
        }
    }
}
extension KDTree : Decodable /* where Element : Decodable */ {
    public init(from decoder: Decoder) throws {
        // Initialize self here so we can get type(of: self).
        self = .leaf
        assertTypeIsDecodable(Element.self, in: type(of: self))
        let container = try decoder.singleValueContainer()

        if !container.decodeNil() {
            let metaType = (Element.self as! Decodable.Type)
            let element = try metaType.init(__from: container)
            self = .node(left: .leaf, value: element as! Element, dimension: 0, right: .leaf)
        }
    }
}

