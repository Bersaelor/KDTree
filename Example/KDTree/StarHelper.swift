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

    static func loadCSVData(completion: (KDTree<Star>?) -> Void) {
        var startLoading = Date()
        
        guard let filePath = Bundle.main.path(forResource: "hygdata_v3", ofType:  "csv"), let fileHandle = fopen(filePath, "r") else {
            completion(nil)
            return }
        defer { fclose(fileHandle) }
        
        let lines = lineIteratorC(file: fileHandle)
        let stars = lines.dropFirst().flatMap { linePtr -> Star? in
            defer { free(linePtr) }
            return Star(rowPtr :linePtr)
        }
        xcLog.debug("Time to load stars: \(Date().timeIntervalSince(startLoading))s")
        startLoading = Date()
        let starTree = KDTree(values: stars)
        xcLog.debug("Time to create Tree: \(Date().timeIntervalSince(startLoading))s")
        completion(starTree)
    }
    
    static func loadForwardStars(stars: KDTree<Star>, currentCenter: CGPoint, radii: CGSize, completion: @escaping ([Star]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let startRangeSearch = Date()
            
            var starsVisible = stars.elementsIn([
                (Double(currentCenter.x - radii.width), Double(currentCenter.x + radii.width)),
                (Double(currentCenter.y - radii.height), Double(currentCenter.y + radii.height))])
            
            //add the points on the other side of the y-axis in case part of the screen is below
            if currentCenter.x < radii.width {
                let leftIntervals: [(Double, Double)] = [
                    (Double( 24.0 + currentCenter.x - radii.width), Double(24.0 + currentCenter.x + radii.width)),
                    (Double(currentCenter.y - radii.height), Double(currentCenter.y + radii.height))]
                starsVisible += stars.elementsIn(leftIntervals).map({ (star: Star) -> Star in
                    return star.starMoved(ascension: -24.0, declination: 0.0)
                })
            }
            xcLog.debug("Finished RangeSearch with \(starsVisible.count) stars, after \(Date().timeIntervalSince(startRangeSearch))s")
            
            DispatchQueue.main.async {
                completion(starsVisible)
            }
        }
    }
    
    static func selectNearestStar(to point: CGPoint, starMapView: StarMapView, stars: KDTree<Star>) {
        let tappedPosition = starMapView.starPosition(for: point)
        let searchStar = Star(ascension: Float(tappedPosition.x), declination: Float(tappedPosition.y))
        
        xcLog.debug("tappedPosition: \(tappedPosition)")
        let startNN = Date()
        var nearestStar = stars.nearest(toElement: searchStar)
        let nearestDistanceSqd = nearestStar?.squaredDistance(to: searchStar) ?? 10.0
        if sqrt(nearestDistanceSqd) > Double(searchStar.right_ascension) { // tap close to or below ascension = 0
            let searchStarModulo = searchStar.starMoved(ascension: 24.0, declination: 0.0)
            if let leftSideNearest = stars.nearest(toElement: searchStarModulo),
                leftSideNearest.squaredDistance(to: searchStarModulo) < nearestDistanceSqd {
                nearestStar = leftSideNearest.starMoved(ascension: -24.0, declination: 0.0)
            }
        }
        
        xcLog.debug("Found nearest star \(String(describing: nearestStar?.dbID)) in \(Date().timeIntervalSince(startNN))s")
        starMapView.tappedStar = nearestStar
    }
}
