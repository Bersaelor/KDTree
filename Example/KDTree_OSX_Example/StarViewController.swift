//
//  StarViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 28.03.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

import KDTree

class StarViewController: NSViewController {

    var stars: KDTree<Star>?
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var starMapView: StarMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "StarMap"
        loadingIndicator.controlTint = NSControlTint.blueControlTint
        
        //do not load csv during tests
        guard ProcessInfo.processInfo.environment["IN_TESTING"] == nil else {
            return
        }
        
        let startLoading = Date()
        DispatchQueue.global(qos: .background).async { [weak self] in
            StarHelper.loadCSVData { (_, stars) in
                DispatchQueue.main.async {
                    xcLog.debug("Completed loading stars: \(Date().timeIntervalSince(startLoading))s")
                    self?.stars = stars
                    xcLog.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                    self?.loadingIndicator.stopAnimation(nil)
                    self?.reloadStars()
                }
            }
        }
    }
    
    func reloadStars() {
        if let stars = stars, let starMapView = self.starMapView {
            StarHelper.loadForwardStars(starTree: stars,
                                        currentCenter: starMapView.centerPoint,
                                        radii: starMapView.currentRadii()) { (starsVisible) in
                                            starMapView.stars = starsVisible
            }
        }
    }
    
    @IBAction func starMapClicked(_ recognizer: NSClickGestureRecognizer) {
        if let stars = stars {
            let point = recognizer.location(in: recognizer.view)
            StarHelper.selectNearestStar(to: point, starMapView: self.starMapView, stars: stars)
        }
    }

    deinit {
        stars?.forEach({ (star: Star) in
            star.starData?.ref.release()
        })
    }
}
