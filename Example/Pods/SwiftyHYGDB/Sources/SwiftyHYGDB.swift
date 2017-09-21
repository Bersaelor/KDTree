//
//  StarHelper.swift
//
//  Created by Konrad Feiler on 28.03.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

public class SwiftyHYGDB: NSObject {
    public static let maxVisibleMag = 6.5
    
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
        
        let yearsToAdvance = precess ? Float(yearsSinceEraStart) : nil
        let lines = lineIteratorC(file: fileHandle)
        var count = 0
        let stars = lines.dropFirst().flatMap { linePtr -> RadialStar? in
            defer { free(linePtr) }
            return RadialStar(rowPtr :linePtr, advanceByYears: yearsToAdvance)
        }
        
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
        
        let yearsToAdvance = precess ? Double(yearsSinceEraStart) : nil
        let lines = lineIteratorC(file: fileHandle)
        var count = 0
        let stars = lines.dropFirst().flatMap { linePtr -> Star3D? in
            defer { free(linePtr) }
            return Star3D(rowPtr :linePtr, advanceByYears: yearsToAdvance)
        }
        
        return stars
    }
    
    public static func save<T: CSVWritable>(stars: [T], to path: URL) throws {
        let lines = [T.headerLine] + stars.flatMap({ $0.csvLine })
        let fileString = lines.joined(separator: "\n")
        try fileString.write(to: path, atomically: true, encoding: .utf8)
    }

}

public protocol CSVWritable {
    static var headerLine: String { get }
    var csvLine: String? { get }
}
