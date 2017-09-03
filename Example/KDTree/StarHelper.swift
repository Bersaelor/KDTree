//
//  StarHelper.swift
//  KDTree
//
//  Created by Konrad Feiler on 28.03.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import KDTree
import MessagePack

class StarHelper: NSObject {
    static let maxVisibleMag = 6.5
    
    private static var yearsSinceEraStart: Int {
        let dateComponents = DateComponents(year: 2000, month: 3, day: 21, hour: 1)
        guard let springEquinox = Calendar.current.date(from: dateComponents) else { return 0 }
        let components = Calendar.current.dateComponents([.year], from: springEquinox, to: Date())
        
        return components.hour ?? 0
    }

    static func loadCSVData(completion: (KDTree<Star>?, KDTree<Star>?) -> Void) {
        var startLoading = Date()
        
        guard let filePath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv"), let fileHandle = fopen(filePath, "r") else {
            completion(nil, nil)
            return }
        defer { fclose(fileHandle) }
        
        let yearsToAdvance = Float(yearsSinceEraStart)
        let lines = lineIteratorC(file: fileHandle)
        let stars = lines.dropFirst().flatMap { linePtr -> Star? in
            defer { free(linePtr) }
            let star = Star(rowPtr :linePtr, advanceByYears: yearsToAdvance)
            return star
        }
        
        let visibleStars = stars.filter { $0.starData?.value.mag ?? Double.infinity < StarHelper.maxVisibleMag }
        log.debug("Time to load \(stars.count) stars: \(Date().timeIntervalSince(startLoading))s")
        startLoading = Date()
        let visibleStarsTree = KDTree(values: visibleStars)
        log.debug("Time to create (visible) Tree: \(Date().timeIntervalSince(startLoading))s")
        let starsTree = KDTree(values: stars)
        completion(visibleStarsTree, starsTree)
    }
    
    static func loadPackedStars(completion: (KDTree<Star>?, KDTree<Star>?) -> Void) {
        var startLoading = Date()
        
        guard let filePath = Bundle.main.path(forResource: "Stars", ofType:  "pack") else {
            completion(nil, nil)
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            log.debug("Packed data with size: \(data.count) byte")
            
            let unpacked = try unpack(data).value
            let stars = unpacked.arrayValue!.map { Star(value: $0) }
            
            let visibleStars = Array(stars[0...1]) // stars.filter { $0.starData?.value.mag ?? Double.infinity < StarHelper.maxVisibleMag }
            log.debug("Time to load \(stars.count) stars: \(Date().timeIntervalSince(startLoading))s")
            startLoading = Date()
            let visibleStarsTree = KDTree(values: visibleStars)
            log.debug("Time to create (visible) Tree: \(Date().timeIntervalSince(startLoading))s")
            let starsTree = KDTree(values: stars)
            completion(visibleStarsTree, starsTree)
        } catch {
            fatalError("Failed with \(error)")
        }
    }
    
    static func loadSavedStars(completion: (KDTree<Star>?) -> Void) {
        let startLoading = Date()
        guard let filePath = Bundle.main.path(forResource: "storedTree", ofType:  "plist") else {
            log.error("Failed loading file: storedTree")
            completion(nil)
            return
        }
        
        do {
            let visibleStar: KDTree<Star> = try KDTree(contentsOf: URL(fileURLWithPath: filePath))
            log.debug("Time to load Tree from file: \(Date().timeIntervalSince(startLoading))s")
            completion(visibleStar)
        } catch {
            log.error("Error loading file: \( error )")
            completion(nil)
        }
    }
    
    static func loadForwardStars(starTree: KDTree<Star>, currentCenter: CGPoint, radii: CGSize, completion: @escaping ([Star]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let stars = StarHelper.stars(from: starTree, around: Float(currentCenter.x), declination: Float(currentCenter.y),
                                         deltaAsc: Float(radii.width), deltaDec: Float(radii.height))
            DispatchQueue.main.async {
                completion(stars)
            }
        }
    }
    
    static func stars(from stars: KDTree<Star>, around ascension: Float, declination: Float, deltaAsc: Float, deltaDec: Float) -> [Star] {
        let verticalRange = (Double(Star.normalizedDeclination(declination: declination - deltaDec)),
                             Double(Star.normalizedDeclination(declination: declination + deltaDec)))
        let startRangeSearch = Date()
        var starsVisible = stars.elementsIn([
            (Double(Star.normalizedAscension(rightAscension: ascension - deltaAsc)),
             Double(Star.normalizedAscension(rightAscension: ascension + deltaAsc))), verticalRange])

        log.verbose("found \(starsVisible.count) stars in first search")
        
        //add the points on the other side of the x-axis in case part of the screen is below
        let overlap = ascension - deltaAsc
        if overlap < 0 {
            starsVisible += stars.elementsIn([
                (Double(Star.normalizedAscension(rightAscension: Float(ascensionRange) + overlap)),
                 Double(Star.normalizedAscension(rightAscension: Float(ascensionRange)))), verticalRange])
        } else if ascension + deltaAsc > Float(ascensionRange) {
            let over24h = ascension + deltaAsc - Float(ascensionRange)
            starsVisible += stars.elementsIn([
                (Double(Star.normalizedAscension(rightAscension: 0)),
                 Double(Star.normalizedAscension(rightAscension: over24h))), verticalRange])
        }
        log.debug("Finished RangeSearch with \(starsVisible.count) stars,"
            + " after \(Date().timeIntervalSince(startRangeSearch))s")

        return starsVisible
    }
    
    static func selectNearestStar(to point: CGPoint, starMapView: StarMapView, stars: KDTree<Star>) {
        let tappedPosition = starMapView.skyPosition(for: point)
        let searchStar = Star(ascension: Float(tappedPosition.x), declination: Float(tappedPosition.y))
        
        log.debug("tappedPosition: \(tappedPosition)")
        let startNN = Date()
        var nearestStar = stars.nearest(to: searchStar)
        let nearestDistanceSqd = nearestStar?.squaredDistance(to: searchStar) ?? 10.0
        if sqrt(nearestDistanceSqd) > Double(searchStar.normalizedAscension) { // tap close to or below ascension = 0
            let searchStarModulo = searchStar.starMoved(ascension: 24.0, declination: 0.0)
            if let leftSideNearest = stars.nearest(to: searchStarModulo),
                leftSideNearest.squaredDistance(to: searchStarModulo) < nearestDistanceSqd {
                nearestStar = leftSideNearest.starMoved(ascension: -24.0, declination: 0.0)
            }
        }
        
        log.debug("Found nearest star \(nearestStar?.dbID ?? -1) in \(Date().timeIntervalSince(startNN))s")
        starMapView.tappedStar = nearestStar
    }
}
