//
//  StarHelper.swift
//  KDTree
//
//  Created by Konrad Feiler on 28.03.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import KDTree
import SwiftyHYGDB

class StarHelper: NSObject {
    static let maxVisibleMag = 6.5

    static func loadStarTree(named fileName: String, completion: @escaping (KDTree<Star>?) -> Void) {
        let startLoading = Date()
        
        guard let starsPath = Bundle.main.path(forResource: fileName, ofType:  "csv") else {
            log.error("Failed loading file: hygdata_v3")
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            guard let stars = SwiftyHYGDB.loadCSVData(from: starsPath) else {
                completion(nil)
                return
            }
            print("Time to load \(stars.count) stars: \(Date().timeIntervalSince(startLoading))s from \(fileName)")
            let startTreeBuilding = Date()
            let tree = KDTree(values: stars)
            print("Time build tree: \(Date().timeIntervalSince(startTreeBuilding)),"
                .appending(" complete time: \(Date().timeIntervalSince(startLoading))s"))
            completion(tree)
        }
    }
    
    static func loadStarsFromPList(completion: (KDTree<Star>?) -> Void) {
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
        let verticalRange = (Double(Star.normalize(declination: declination - deltaDec)),
                             Double(Star.normalize(declination: declination + deltaDec)))
        let startRangeSearch = Date()
        var starsVisible = stars.elementsIn([
            (Double(Star.normalize(rightAscension: ascension - deltaAsc)),
             Double(Star.normalize(rightAscension: ascension + deltaAsc))), verticalRange])

        log.verbose("found \(starsVisible.count) stars in first search")
        
        //add the points on the other side of the x-axis in case part of the screen is below
        let overlap = ascension - deltaAsc
        if overlap < 0 {
            starsVisible += stars.elementsIn([
                (Double(Star.normalize(rightAscension: Float(Star.ascensionRange) + overlap)),
                 Double(Star.normalize(rightAscension: Float(Star.ascensionRange)))), verticalRange])
        } else if ascension + deltaAsc > Float(Star.ascensionRange) {
            let over24h = ascension + deltaAsc - Float(Star.ascensionRange)
            starsVisible += stars.elementsIn([
                (Double(Star.normalize(rightAscension: 0)),
                 Double(Star.normalize(rightAscension: over24h))), verticalRange])
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
