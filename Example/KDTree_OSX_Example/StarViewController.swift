//
//  StarViewController.swift
//  KDTree
//
// Copyright (c) 2020 mathHeartCode UG(haftungsbeschränkt) <konrad@mathheartcode.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

import KDTree
import SwiftyHYGDB

class StarViewController: NSViewController {

    var stars: KDTree<RadialStar>?
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
            StarHelper.loadStarTree(named: "allStars", completion: { (stars) in
                log.debug("Completed loading stars: \(Date().timeIntervalSince(startLoading))s")
                self?.stars = stars
                log.debug("Finished loading \(stars?.count ?? -1) stars, after \(Date().timeIntervalSince(startLoading))s")
                DispatchQueue.main.async {
                    self?.loadingIndicator.stopAnimation(nil)
                    self?.reloadStars()
                }
            })
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
        stars?.forEach({ (star: RadialStar) in
            star.starData?.ref.release()
        })
    }
}
