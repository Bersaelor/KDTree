//
//  StarHelper.swift
//
//  Created by Konrad Feiler on 28.03.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public class SwiftyHYGDB: NSObject {
    public static let maxVisibleMag: Float = 6.5
 
    static let missingValueIndex: Int = -1

    static var glIds: [String] = []
    static var properNames: [String] = []
    static var bayerFlamstedts: [String] = []
    static var spectralTypes: [String] = []
    
    private static var yearsSinceEraStart: Int {
        let dateComponents = DateComponents(year: 2000, month: 3, day: 21, hour: 1)
        guard let springEquinox = Calendar.current.date(from: dateComponents) else { return 0 }
        let components = Calendar.current.dateComponents([.year], from: springEquinox, to: Date())
        
        return components.hour ?? 0
    }

    /// Loads radial Stars from CSV file line by line using line iterator.
    /// Be advised that Stardata is not memory managed so `star.starData?.ref.release()` has to be called manually
    /// for every star when no longer needed
    ///
    /// - Parameters:
    ///   - filePath: the path of the csv encoded HYG database file (see http://www.astronexus.com/hyg )
    ///   - precess: Bool to opt into preceeding positions
    ///   - completion: returns the loaded stars
    public static func loadCSVData(from filePath: String, precess: Bool = false) -> [RadialStar]? {
        guard let fileHandle = fopen(filePath, "r") else {
            print("Failed to get file handle for \(filePath)")
            return nil
        }
        defer { fclose(fileHandle) }
        
        var indexers = SwiftyDBValueIndexers(glValues: glIds, spectralValues: spectralTypes,
                                             bfValues: bayerFlamstedts, pNValues: properNames)
        
        let yearsToAdvance = precess ? Float(yearsSinceEraStart) : nil
        let lines = lineIteratorC(file: fileHandle)
        var count = 0
        let stars = lines.dropFirst().compactMap { linePtr -> RadialStar? in
            defer { free(linePtr) }
            return RadialStar(rowPtr :linePtr, advanceByYears: yearsToAdvance, indexers: &indexers)
        }

        self.glIds = indexers.glIds.indexedValues()
        self.properNames = indexers.properNames.indexedValues()
        self.bayerFlamstedts = indexers.bayerFlamstedts.indexedValues()
        self.spectralTypes = indexers.spectralTypes.indexedValues()

        return stars
    }
    
    /// Loads Stars from CSV file line by line using line iterator.
    /// Different to the radial stars, this method returns stars organized by their x,y,z location
    /// Be advised that Stardata is not memory managed so `star.starData?.ref.release()` has to be called manually
    /// for every star when no longer needed
    ///
    /// - Parameters:
    ///   - filePath: the path of the csv encoded HYG database file (see http://www.astronexus.com/hyg )
    ///   - precess: Bool to opt into preceeding positions
    ///   - completion: returns the loaded stars
    public static func loadCSVData(from filePath: String, precess: Bool = false) -> [Star3D]? {
        guard let fileHandle = fopen(filePath, "r") else {
            print("Failed to get file handle for \(filePath)")
            return nil
        }
        defer { fclose(fileHandle) }
        
        var indexers = SwiftyDBValueIndexers(glValues: glIds, spectralValues: spectralTypes,
                                             bfValues: bayerFlamstedts, pNValues: properNames)

        let yearsToAdvance = precess ? Double(yearsSinceEraStart) : nil
        let lines = lineIteratorC(file: fileHandle)
        var count = 0
        let stars = lines.dropFirst().compactMap { linePtr -> Star3D? in
            defer { free(linePtr) }
            return Star3D(rowPtr :linePtr, advanceByYears: yearsToAdvance, indexers: &indexers)
        }
        
        self.glIds = indexers.glIds.indexedValues()
        self.properNames = indexers.properNames.indexedValues()
        self.bayerFlamstedts = indexers.bayerFlamstedts.indexedValues()
        self.spectralTypes = indexers.spectralTypes.indexedValues()
        
        return stars
    }
    
    public static func save<T: CSVWritable>(stars: [T], to path: String) throws {
        let lines = [T.headerLine] + stars.compactMap { $0.csvLine }
        let fileString = lines.joined(separator: "\n")
        try fileString.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
    }
}

extension String: IndexerValue {
    func isValid() -> Bool {
        return !isEmpty
    }
}

struct SwiftyDBValueIndexers {
    var glIds: Indexer<String> = Indexer()
    var spectralTypes: Indexer<String> = Indexer()
    var bayerFlamstedts: Indexer<String> = Indexer()
    var properNames: Indexer<String> = Indexer()
}

extension SwiftyDBValueIndexers {
    init(glValues: [String], spectralValues: [String], bfValues: [String], pNValues: [String]) {
        glIds = Indexer(existingValues: glValues)
        spectralTypes = Indexer(existingValues: spectralValues)
        bayerFlamstedts = Indexer(existingValues: bfValues)
        properNames = Indexer(existingValues: pNValues)
    }
}

public protocol CSVWritable {
    static var headerLine: String { get }
    var csvLine: String? { get }
}
