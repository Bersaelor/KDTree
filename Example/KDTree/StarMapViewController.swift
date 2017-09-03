//
//  StarsViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import KDTree
import MessagePack

class StarMapViewController: UIViewController {
    
    var visibleStars: KDTree<Star>?
    var allStars: KDTree<Star>?
    private let isUsingMessagePack: Bool = true

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var starMapView: StarMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "StarMap"

        let loadEncodedTree = false
        let startLoading = Date()
        DispatchQueue.global(qos: .background).async { [weak self] in
            if loadEncodedTree {
                StarHelper.loadSavedStars { (stars) in
                    DispatchQueue.main.async {
                        self?.allStars = stars
                        
                        log.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                        self?.loadingIndicator.stopAnimating()
                        
                        self?.reloadStars()
                    }
                }
            } else {
                let loader = (self?.isUsingMessagePack ?? false) ? StarHelper.loadPackedStars : StarHelper.loadCSVData
                loader { (visibleStars, stars) in
                    DispatchQueue.main.async {
                        self?.allStars = stars
                        self?.visibleStars = visibleStars
                        
                        log.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
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
            log.debug("Noting")
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func saveStars() {
        let starArray = allStars!.elements
        let name = isUsingMessagePack ? "Stars.pack" : "test.plist"
        
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filePath = NSURL(fileURLWithPath: path).appendingPathComponent(name) else { return }
        
        do {
            let startLoading = Date()
            if isUsingMessagePack {
                let packedStars = starArray.map { $0.messagePackValue() }
                let data = pack(.array(packedStars))
                try data.write(to: filePath, options: Data.WritingOptions.atomic)
                log.debug("Wrote \(data.count) byte using MessagePack as a star array")
            } else {
                try allStars?.save(to: filePath)
            }
            log.debug("Writing file to \( filePath ) took \( Date().timeIntervalSince(startLoading) )")
        } catch {
            log.debug("Error trying to save stars: \( error )")
        }
    }
}
