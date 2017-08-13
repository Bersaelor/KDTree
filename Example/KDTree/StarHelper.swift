//
//  StarHelper.swift
//  KDTree
//
//  Created by Konrad Feiler on 28.03.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import KDTree

class StarHelper: NSObject {
    static let maxVisibleMag = 6.5

    static func loadCSVData(onlyVisible: Bool = false, completion: (KDTree<Star>?) -> Void) {
        var startLoading = Date()
        
        guard let filePath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv"), let fileHandle = fopen(filePath, "r") else {
            completion(nil)
            return }
        defer { fclose(fileHandle) }
        
        let lines = lineIteratorC(file: fileHandle)
        let stars = lines.dropFirst().flatMap { linePtr -> Star? in
            defer { free(linePtr) }
            let star = Star(rowPtr :linePtr)
            if onlyVisible && star?.starData?.value.mag ?? Double.infinity > maxVisibleMag { return nil }
            return star
        }
        xcLog.debug("Time to load \(stars.count) stars: \(Date().timeIntervalSince(startLoading))s")
        startLoading = Date()
        let starTree = KDTree(values: stars)
        xcLog.debug("Time to create Tree: \(Date().timeIntervalSince(startLoading))s")
        completion(starTree)
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

        xcLog.debug("found \(starsVisible.count) stars in first search")
        
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
        xcLog.debug("Finished RangeSearch with \(starsVisible.count) stars,"
            + " after \(Date().timeIntervalSince(startRangeSearch))s")

        return starsVisible
    }
    
    static func selectNearestStar(to point: CGPoint, starMapView: StarMapView, stars: KDTree<Star>) {
        let tappedPosition = starMapView.skyPosition(for: point)
        let searchStar = Star(ascension: Float(tappedPosition.x), declination: Float(tappedPosition.y))
        
        xcLog.debug("tappedPosition: \(tappedPosition)")
        let startNN = Date()
        var nearestStar = stars.nearest(toElement: searchStar)
        let nearestDistanceSqd = nearestStar?.squaredDistance(to: searchStar) ?? 10.0
        if sqrt(nearestDistanceSqd) > Double(searchStar.normalizedAscension) { // tap close to or below ascension = 0
            let searchStarModulo = searchStar.starMoved(ascension: 24.0, declination: 0.0)
            if let leftSideNearest = stars.nearest(toElement: searchStarModulo),
                leftSideNearest.squaredDistance(to: searchStarModulo) < nearestDistanceSqd {
                nearestStar = leftSideNearest.starMoved(ascension: -24.0, declination: 0.0)
            }
        }
        
        xcLog.debug("Found nearest star \(nearestStar?.dbID ?? -1) in \(Date().timeIntervalSince(startNN))s")
        starMapView.tappedStar = nearestStar
    }
}
