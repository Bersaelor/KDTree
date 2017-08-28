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
    
    var visibleStars: KDTree<Star>?
    var allStars: KDTree<Star>?
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var starMapView: StarMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "StarMap"

        let loadFromFile = true
        let startLoading = Date()
        DispatchQueue.global(qos: .background).async { [weak self] in
            if !loadFromFile {
                StarHelper.loadCSVData { (visibleStars, stars) in
                    DispatchQueue.main.async {
                        xcLog.debug("Completed loading stars: \(Date().timeIntervalSince(startLoading))s")
                        self?.allStars = stars
                        self?.visibleStars = visibleStars
                        
                        xcLog.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                        self?.loadingIndicator.stopAnimating()
                        
                        self?.reloadStars()
                    }
                }
            } else {
                StarHelper.loadSavedStars { (stars) in
                    DispatchQueue.main.async {
                        xcLog.debug("Completed loading stars: \(Date().timeIntervalSince(startLoading))s")
                        self?.allStars = stars
                        
                        xcLog.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                        self?.loadingIndicator.stopAnimating()
                        
                        self?.reloadStars()
                    }
                }
            }
        }
        
        let pinchGR = UIPinchGestureRecognizer(target: self,
                                               action: #selector(StarMapViewController.handlePinch(gestureRecognizer:)))
        let panGR = UIPanGestureRecognizer(target: self,
                                           action: #selector(StarMapViewController.handlePan(gestureRecognizer:)))
        starMapView.addGestureRecognizer(pinchGR)
        starMapView.addGestureRecognizer(panGR)
        
        let infoButton = UIButton(type: UIButtonType.infoDark)
        infoButton.addTarget(self, action: #selector(openInfo), for: UIControlEvents.touchUpInside)
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveStars))
        navigationItem.rightBarButtonItems = [saveButton, UIBarButtonItem(customView: infoButton)]
    }
    
    deinit {
        allStars?.forEach({ (star: Star) in
            star.starData?.ref.release()
        })
    }
    
    @IBAction
    func userTappedMap(recognizer: UITapGestureRecognizer) {
        guard let starTree = starMapView.magnification > minMagnificationForAllStars ? allStars : visibleStars else { return }
        let point = recognizer.location(in: self.starMapView)
        StarHelper.selectNearestStar(to: point, starMapView: self.starMapView, stars: starTree)
    }

    @objc func handlePinch(gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            startRadius = starMapView.radius
        case .failed, .ended:
            break
        default:
            if let startRadius = startRadius {
                starMapView.radius = startRadius / gestureRecognizer.scale
                reloadStars()
            }
        }
    }
    private var startRadius: CGFloat?
    private var startCenter: CGPoint?
    private var minMagnificationForAllStars: CGFloat = 2.2
    private var isLoadingMapStars = false
    
    private func reloadStars() {
        guard let starTree = starMapView.magnification > minMagnificationForAllStars ? allStars : visibleStars else { return }
        guard !isLoadingMapStars else { return }
        isLoadingMapStars = true
        StarHelper.loadForwardStars(starTree: starTree, currentCenter: starMapView.centerPoint,
                                    radii: starMapView.currentRadii()) { (starsVisible) in
                                        DispatchQueue.main.async {
                                            self.starMapView.stars = starsVisible
                                            self.isLoadingMapStars = false
                                        }
        }
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {     
        switch gestureRecognizer.state {
        case .began:
            startCenter = starMapView.centerPoint
        case .failed, .ended:
            break
        default:
            if let startCenter = startCenter {
                let adjVec = starMapView.radius / (0.5 * starMapView.bounds.width) * CGPoint(x: ascensionRange, y: declinationRange)
                starMapView.centerPoint = startCenter + adjVec * gestureRecognizer.translation(in: starMapView)
                reloadStars()
            }
        }
    }
    
    @objc func openInfo() {
        let alert = UIAlertController(title: nil,
                                      message: "Cylindrical projection of the starry sky for the year 2000,"
                                        .appending(" measured by right ascension and declination coordinates."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { _ in
            xcLog.debug("Noting")
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func saveStars() {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent("test.plist") else { return }
        
        do {
            let startLoading = Date()
            try allStars?.save(to: filePath)
            xcLog.debug("Writing file to \( filePath ) took \( Date().timeIntervalSince(startLoading) )")
        } catch {
            xcLog.debug("Error trying to save stars: \( error )")
        }
    }
}
