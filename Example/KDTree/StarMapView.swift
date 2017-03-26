//
//  StarMapView.swift
//  KDTree
//
//  Created by Konrad Feiler on 26/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class StarMapView: UIView {

    var tappedPoint: CGPoint?

    var centerPoint = CGPoint.zero
    var radius: CGFloat = 5.0
    
    var stars: [Star]? {
        didSet {
            xcLog.debug("Now showing \(self.stars?.count ?? 0)")
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = UIColor.black
        
    }
    
    static let minSize: CGFloat = 0.5
    static let maxSize: CGFloat = 10.0
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            xcLog.error("failed to get graphics context")
            return
        }
        
        context.clear(self.bounds)
        
        //recenter in middle
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        context.translateBy(x: c.x, y: c.y)
        let radiusInPix = 0.5 * self.bounds.width / radius
        
        let linearDotFactor = (StarMapView.minSize - StarMapView.maxSize)/32.5
        let absoluteAddition = 26.0/32.5 * StarMapView.minSize + 6.5/32.5 * StarMapView.maxSize
        
        xcLog.debug("linearDotFactor: \(linearDotFactor), absoluteAddition: \(absoluteAddition)")

        UIColor.white.setFill()
        for star in self.stars ?? [] {
            let starPosition = CGPoint(x: CGFloat(star.right_ascension), y: CGFloat(star.declination))
            let mag = CGFloat(star.starData?.value.mag ?? 0.0)
            let dotSize: CGFloat = linearDotFactor * mag + absoluteAddition
//            xcLog.debug("mag: \(mag) and DotSize \(dotSize)")
            let relativePosition = radiusInPix*(starPosition - centerPoint) - dotSize * CGPoint(x: 0.5, y: 0.5)
//            xcLog.debug("Drawing star \(star.starData?.value.properName ?? "Unnamed")"
//                + " at \(relativePosition) with magnitude \(star.starData?.value.mag ?? 0.0)")
            context.move(to: relativePosition)
            let rect = CGRect(origin: relativePosition, size: CGSize(width: dotSize, height: dotSize))
            context.fillEllipse(in: rect)
        }

    }

}
