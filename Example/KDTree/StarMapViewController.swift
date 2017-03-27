//
//  StarsViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import KDTree

class StarMapViewController: UIViewController {
    
    var stars: KDTree<Star>?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var starMapView: StarMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "StarMap"

        let startLoading = Date()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadCSVData { stars in
                DispatchQueue.main.async {
                    xcLog.debug("Completed loading stars: \(Date().timeIntervalSince(startLoading))s")
                    self?.stars = stars
                    
                    xcLog.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                    self?.loadingIndicator.stopAnimating()
                    
//                    if let stars = stars {
//                        var firstTen = [String]()
//                        for star in stars {
//                            guard firstTen.count < 10 else { break }
//                            firstTen.append("\(star)\n")
//                        }
//                        xcLog.debug("10 stars: \(firstTen.reduce("", { $0 + $1 }))")
//                    }
                    
                    self?.loadForwardStars()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction
    func userTappedMap(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.starMapView)
        let tappedPosition = starMapView.starPosition(for: point)
        let searchStar = Star(ascension: Float(tappedPosition.x), declination: Float(tappedPosition.y))

        xcLog.debug("tappedPosition: \(tappedPosition)")
        let startNN = Date()
        var nearestStar = stars?.nearest(toElement: searchStar)
        let nearestDistanceSqd = nearestStar?.squaredDistance(to: searchStar) ?? 10.0
        if sqrt(nearestDistanceSqd) > Double(searchStar.right_ascension) { // tap close to or below ascension = 0
            let searchStarModulo = searchStar.starMovedOn(ascension: 24.0, declination: 0.0)
            if let leftSideNearest = stars?.nearest(toElement: searchStarModulo),
                leftSideNearest.squaredDistance(to: searchStarModulo) < nearestDistanceSqd {
                nearestStar = leftSideNearest.starMovedOn(ascension: -24.0, declination: 0.0)
            }
        }
        
        xcLog.debug("Found nearest star \(nearestStar?.dbID) in \(Date().timeIntervalSince(startNN))s")
        self.starMapView.tappedStar = nearestStar
    }
        
    fileprivate func loadForwardStars() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let stars = self?.stars,
                let currentCenter = self?.starMapView.centerPoint,
                let currentRadius = self?.starMapView.radius {
                
                let startRangeSearch = Date()
                
                var starsVisible = stars.elementsIn([
                    (Double(currentCenter.x - currentRadius), Double(currentCenter.x + currentRadius)),
                    (Double(currentCenter.y - currentRadius), Double(currentCenter.y + currentRadius))])

                //add the points on the other side of the y-axis in case part of the screen is below
                if currentCenter.x < currentRadius {
                    let leftIntervals: [(Double, Double)] = [
                        (Double( 24.0 + currentCenter.x - currentRadius), Double(24.0 + currentCenter.x + currentRadius)),
                        (Double(currentCenter.y - currentRadius), Double(currentCenter.y + currentRadius))]
                    starsVisible += stars.elementsIn(leftIntervals).map({ (star: Star) -> Star in
                        return star.starMovedOn(ascension: -24.0, declination: 0.0)
                    })
                }
                xcLog.debug("Finished RangeSearch with \(starsVisible.count) stars, after \(Date().timeIntervalSince(startRangeSearch))s")
                
                DispatchQueue.main.async {
                    self?.starMapView?.stars = starsVisible
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadCSVData(completion: (KDTree<Star>?) -> Void) {
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
    
    deinit {
        stars?.forEach({ (star: Star) in
            star.starData?.ref.release()
        })
    }

}
