//
//  CodableTests.swift
//  KDTree_Example
//
//  Created by Konrad Feiler on 26.08.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import KDTree

class PerformanceTests: XCTestCase {
    var points: [CGPoint] = []
    var testPoints: [CGPoint] = []
    var largeTree: KDTree<CGPoint> = KDTree(values: [])
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    override func setUp() {
        super.setUp()
        
        points = (0..<1000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
        largeTree = KDTree(values: self.points)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test01_EmptyTreeEncoding() {
        let emptyTree: KDTree<CGPoint> = KDTree(values: [])

        do {
            let data = try encoder.encode(emptyTree)
            let json = String.init(data: data, encoding: .utf8)
            print(data)
            print(json ?? "?")
            
            let decodedTree = try decoder.decode(KDTree<CGPoint>.self, from: data)
            print(decodedTree)
            XCTAssertEqual(decodedTree.isEmpty, true, "Decoded Tree should be empty")
        } catch {
            XCTAssertNotNil(error, "Expected Top-level (T.self) encoded as null JSON fragment: \(error)")
        }
    }
    
    func test02_SingleValueTreeEncoding() {
        let tree: KDTree<CGPoint> = KDTree(values: [CGPoint.zero])
        
        do {
            let data = try encoder.encode(tree)
            let json = String.init(data: data, encoding: .utf8)
            print(data)
            print(json ?? "?")
            
            let decodedTree = try decoder.decode(KDTree<CGPoint>.self, from: data)
            print(decodedTree)
            XCTAssertEqual(decodedTree.isEmpty, false, "Decoded Tree should not be empty")
            XCTAssertEqual(decodedTree.contains(CGPoint.zero), true, "Decoded Tree should contain (0,0)")
        } catch {
            XCTFail("Error while coding single value tree \( error )")
        }
    }
    
    func test03_BigTreeEncoding() {
        do {
            let data = try encoder.encode(largeTree)
            let json = String.init(data: data, encoding: .utf8)
            print(data)
            print(json ?? "?")
            
            let decodedTree = try decoder.decode(KDTree<CGPoint>.self, from: data)
            print(decodedTree)
            XCTAssertEqual(largeTree.count, decodedTree.count, "Decoded Tree have equal amount of data as original tree")
            
            let missingPoints = largeTree.reduce(0) { (res, point) -> Int in
                return res + (decodedTree.contains(point) ? 0 : 1)
            }
            XCTAssertEqual(missingPoints, 0, "Decoded Tree should have all original points")

            let unexpectedPoints = decodedTree.reduce(0, { (res, point) -> Int in
                return res + (largeTree.contains(point) ? 0 : 1)
            })
            XCTAssertEqual(unexpectedPoints, 0, "Decoded Tree should not have any extra points")
        } catch {
            XCTFail("Error while coding empty tree \( error )")
        }
    }
}
