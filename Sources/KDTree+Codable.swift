//
//  KDTree+Codable.swift
//
// Copyright (c) 2020 mathHeartCode UG(haftungsbeschränkt) <konrad@mathheartcode.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

private struct NodeBox<Element: KDTreePoint> {
    let left: KDTree<Element>
    let value: Element
    let dimension: Int
    let right: KDTree<Element>
    
    enum CodingKeys: String, CodingKey {
        case left       = "l"
        case value      = "v"
        case dimension  = "d"
        case right      = "r"
    }
    
    init(left: KDTree<Element>, value: Element, dimension: Int, right: KDTree<Element>) {
        self.left = left
        self.value = value
        self.dimension = dimension
        self.right = right
    }
}

extension NodeBox: Decodable where Element: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        left        = try container.decode(KDTree<Element>.self, forKey: .left)
        value       = try container.decode(Element.self, forKey: .value)
        dimension   = try container.decode(Int.self, forKey: .dimension)
        right       = try container.decode(KDTree<Element>.self, forKey: .right)
    }
}

extension NodeBox: Encodable where Element: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(left, forKey: CodingKeys.left)
        try container.encode(value, forKey: CodingKeys.value)
        try container.encode(dimension, forKey: .dimension)
        try container.encode(right, forKey: .right)
    }
}

extension KDTree: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .leaf: try container.encodeNil()
        case let .node(left, value, dim, right):
            let box = NodeBox(left: left, value: value, dimension: dim, right: right)
            try container.encode(box)
        }
    }
}

extension KDTree: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        // Initialize self here so we can get type(of: self).
        self = .leaf
        let container = try decoder.singleValueContainer()

        if !container.decodeNil() {
            let box = try container.decode(NodeBox<Element>.self)
            self = .node(left: box.left, value: box.value, dimension: box.dimension, right: box.right)
        }
    }
}
#if !os(WASI)
extension KDTree where Element: Encodable {
    
    public func save(to path: URL) throws {
#if os(Linux)
    let data = try JSONEncoder().encode(self)
#else
    let data = try PropertyListEncoder().encode(self)
#endif
        try data.write(to: path, options: Data.WritingOptions.atomic)
    }
}

extension KDTree where Element: Decodable {
    
    public init(contentsOf path: URL) throws {
        let data = try Data(contentsOf: path)
#if os(Linux)
    self = try JSONDecoder().decode(KDTree<Element>.self, from: data)
#else
    self = try PropertyListDecoder().decode(KDTree<Element>.self, from: data)
#endif
    }
}
#endif
