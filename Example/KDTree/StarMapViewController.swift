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
            StarHelper.loadCSVData(onlyVisible: true) { stars in
                DispatchQueue.main.async {
                    xcLog.debug("Completed loading stars: \(Date().timeIntervalSince(startLoading))s")
                    self?.stars = stars
                    
                    xcLog.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                    self?.loadingIndicator.stopAnimating()
                    
                    if let stars = stars, let starMapView = self?.starMapView {
                        StarHelper.loadForwardStars(starTree: stars, currentCenter: starMapView.centerPoint,
                                                    radii: starMapView.currentRadii()) { (starsVisible) in
                            starMapView.stars = starsVisible
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction
    func userTappedMap(recognizer: UITapGestureRecognizer) {
        if let stars = stars {
            let point = recognizer.location(in: self.starMapView)
            StarHelper.selectNearestStar(to: point, starMapView: self.starMapView, stars: stars)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        stars?.forEach({ (star: Star) in
            star.starData?.ref.release()
        })
    }

}
