//
//  CodableTests.swift
//  KDTree_Example
//
//  Created by Konrad Feiler on 26.08.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import KDTree

class CodableTests: XCTestCase {
    var points: [CGPoint] = []
    var testPoints: [CGPoint] = []
    var largeTree: KDTree<CGPoint> = KDTree(values: [])
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    override func setUp() {
        super.setUp()
        
        points = (0..<1000).map { _ in CGPoint(x: CGFloat.random(), y: CGFloat.random()) }
        largeTree = KDTree(values: self.points)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test01_EmptyTreeEncoding() {
        let emptyTree: KDTree<CGPoint> = KDTree(values: [])

        do {
            let data = try encoder.encode(emptyTree)
            let json = String(data: data, encoding: .utf8)
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
//            let json = String.init(data: data, encoding: .utf8)
//            print(json ?? "?")
            
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
            print("encoded data has size \(data.count)")
            
            let decodedTree = try decoder.decode(KDTree<CGPoint>.self, from: data)
            XCTAssertEqual(largeTree.count, decodedTree.count, "Decoded Tree have equal amount of data as original tree")

            /* Encoded and decoded tree aren't exactly equal due to floating point encoding of NSNumber/JSONSerialization */
            /* Uncomment the following lines to check that the error is ~ 10^-34 */
//            let decodedValues = decodedTree.elements
//            largeTree.elements.enumerated().forEach { (offset, element) in
//                if element != decodedValues[offset] {
//                    print("Original: \(element), decoded: \(decodedValues[offset]) not equal!")
//                    print("Distance: \(element.squaredDistance(to: decodedValues[offset]))")
//                }
//            }
            
            let missingPoints = largeTree.reduce(0) { (res, point) -> Int in
                if let nearest = decodedTree.nearest(to: point), nearest.squaredDistance(to: point) > Double(CGFloat.ulpOfOne) {
                    print("point \(point) is missing, distance: \( nearest.squaredDistance(to: point) )")
                    return res + 1
                }
                return res
            }
            XCTAssertEqual(missingPoints, 0, "Decoded Tree should have all original points")

            let unexpectedPoints = decodedTree.reduce(0) { (res, point) -> Int in
                if let nearest = largeTree.nearest(to: point), nearest.squaredDistance(to: point) > Double(CGFloat.ulpOfOne) {
                    print("point \(point) is missing, distance: \( nearest.squaredDistance(to: point) )")
                    return res + 1
                }
                return res
            }
            XCTAssertEqual(unexpectedPoints, 0, "Decoded Tree should not have any extra points")
        } catch {
            XCTFail("Error while coding empty tree \( error )")
        }
    }
    
    func test04_saveAndLoadFile() {
        do {
            guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
                let filePath = NSURL(fileURLWithPath: path).appendingPathComponent("test.plist") else {
                    XCTFail(" Failed to create test.json file")
                    return
            }
            
            do {
                try largeTree.save(to: filePath)
                let decodedTree: KDTree<CGPoint> = try KDTree(contentsOf: filePath)
                XCTAssertEqual(largeTree.count, decodedTree.count, "Decoded Tree have equal amount of data as original tree")

                let missingPoints = largeTree.reduce(0) { (res, point) -> Int in
                    if let nearest = decodedTree.nearest(to: point), nearest.squaredDistance(to: point) > Double.ulpOfOne {
                        print("point \(point) is missing, distance: \( nearest.squaredDistance(to: point) )")
                        return res + 1
                    }
                    return res
                }
                XCTAssertEqual(missingPoints, 0, "Decoded Tree should have all original points")
            } catch {
                XCTFail("Error while coding empty tree \( error )")
            }
        }
    }
}
