//
//  StarsViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import KDTree
import SwiftyHYGDB

class StarMapViewController: UIViewController {
    
    var visibleStars: KDTree<RadialStar>?
    var allStars: KDTree<RadialStar>?
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var starMapView: StarMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadEncodedTree = false
        let startLoading = Date()
        DispatchQueue.global(qos: .background).async { [weak self] in
            if loadEncodedTree {
                StarHelper.loadStarsFromPList(named: "visibleStars") { (stars) in
                    DispatchQueue.main.async {
                        self?.visibleStars = stars
                        log.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                        self?.loadingIndicator.stopAnimating()
                        self?.reloadStars()
                        self?.loadAllStars()
                    }
                }
            } else {
                StarHelper.loadStarTree(named: "visibleStars") { (stars) in
                    DispatchQueue.main.async {
                        self?.visibleStars = stars
                        log.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                        self?.loadingIndicator.stopAnimating()
                        self?.reloadStars()
                        self?.loadAllStars()
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
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: infoButton)]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.tintColor = .blue
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func loadAllStars() {
        StarHelper.loadStarTree(named: "allStars") { [weak self] (stars) in
            DispatchQueue.main.async {
                self?.allStars = stars
                self?.reloadStars()
            }
        }
    }
    
    deinit {
        allStars?.forEach({ (star: RadialStar) in
            star.starData?.ref.release()
        })
        visibleStars?.forEach({ (star: RadialStar) in
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
        guard let starTree = starMapView.magnification > minMagnificationForAllStars
            ? (allStars ?? visibleStars) : visibleStars else { return }
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
                let adjVec = starMapView.radius / (0.5 * starMapView.bounds.width)
                    * CGPoint(x: RadialStar.ascensionRange, y: RadialStar.declinationRange)
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
}
