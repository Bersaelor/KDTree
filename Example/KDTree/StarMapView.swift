//
//  StarMapView.swift
//  KDTree
//
//  Created by Konrad Feiler on 26/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

class StarMapView: View {

    var tappedPoint: CGPoint?

    var centerPoint = CGPoint.zero
    var radius: CGFloat = 3.0
    
    var tappedStar: Star? = nil {
        didSet { xPlatformNeedsDisplay() }
    }
    
    var stars: [Star]? {
        didSet {
            xcLog.debug("Now showing \(self.stars?.count ?? 0)")
            xPlatformNeedsDisplay()
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

    }
    
    static let minSize: CGFloat = 1.0
    static let maxSize: CGFloat = 10.0
    
    func starPosition(for point: CGPoint) -> CGPoint {
        let relativeToCenter = point - CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radiusInPix = 0.5 * self.bounds.width / radius
        return 1.0/radiusInPix * relativeToCenter + centerPoint
    }
    
    override func draw(_ rect: CGRect) {
        #if os(OSX)
            guard let context = NSGraphicsContext.current()?.cgContext else { return }
        #else
            guard let context = UIGraphicsGetCurrentContext() else { return }
        #endif

        context.clear(self.bounds)

        Color.black.setFill()
        context.fillEllipse(in: rect)
        
        //recenter in middle
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        context.translateBy(x: c.x, y: c.y)
        let radiusInPix = 0.5 * self.bounds.width / radius
        
        let linearDotFactor = (StarMapView.minSize - StarMapView.maxSize)/32.5
        let absoluteAddition = 26.0/32.5 * StarMapView.minSize + 6.5/32.5 * StarMapView.maxSize
        
        xcLog.debug("linearDotFactor: \(linearDotFactor), absoluteAddition: \(absoluteAddition)")

        Color.white.setFill()
        for star in self.stars ?? [] {
            let starPosition = CGPoint(x: CGFloat(star.right_ascension), y: CGFloat(star.declination))
            let mag = CGFloat(star.starData?.value.mag ?? 0.0)
            let dotSize: CGFloat = linearDotFactor * mag + absoluteAddition
//            xcLog.debug("mag: \(mag) and DotSize \(dotSize)")
            let relativePosition = radiusInPix*(starPosition - centerPoint) - dotSize * CGPoint(x: 0.5, y: 0.5)
//            xcLog.debug("Drawing star \(star.starData?.value.properName ?? "Unnamed")"
//                + " at \(relativePosition) with magnitude \(star.starData?.value.mag ?? 0.0)")
            let rect = CGRect(origin: relativePosition, size: CGSize(width: dotSize, height: dotSize))
            context.fillEllipse(in: rect)
        }
        
        #if os(OSX)
            let verticalAdjustment = 1.0
        #else
            let verticalAdjustment = -1.0
        #endif
        
        if let tappedStar = tappedStar {
            let starPosition = CGPoint(x: CGFloat(tappedStar.right_ascension), y: CGFloat(tappedStar.declination))
            let circleSize: CGFloat = 15
            let relativePosition: CGPoint = radiusInPix*(starPosition - centerPoint) - circleSize * CGPoint(x: 0.5, y: 0.5)
            let rect: CGRect = CGRect(origin: relativePosition, size: CGSize(width: circleSize, height: circleSize))
            Color.orange.setStroke()
            context.strokeEllipse(in: rect)
            guard let starData = tappedStar.starData?.value else { return }
            let glieseName: String? = starData.gl_id.flatMap { (id: Int32) -> String in  return "Gliese\(id)" }
            let hdName: String? = starData.hd_id.flatMap { (id: Int32) -> String in  return "HD\(id)" }
            let hrName: String? = starData.hr_id.flatMap { (id: Int32) -> String in  return "HR\(id)" }
            let idName: String = "HYG\(tappedStar.dbID)"
            let textString: String = starData.properName
                ?? glieseName ?? starData.bayer_flamstedt ?? hdName ?? hrName ?? idName
            let isLeftOfCenter = relativePosition.x < 0.0
            let textInnerCorner: CGPoint = radiusInPix*(starPosition - centerPoint)
                +  circleSize *  CGPoint(x: isLeftOfCenter ? 0.52 : -0.52, y: verticalAdjustment * 0.55)
            let textOuterCorner = textInnerCorner + CGPoint(x: isLeftOfCenter ? 200 : -200, y: verticalAdjustment * 14.0)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = isLeftOfCenter ? .left : .right
            let attributes = [NSFontAttributeName: Font.systemFont(ofSize: 12.0),
                              NSForegroundColorAttributeName: Color.orange,
                              NSParagraphStyleAttributeName: paragraphStyle]
            (textString as NSString).draw(in: CGRect(pointA: textInnerCorner, pointB: textOuterCorner), withAttributes: attributes)
        }
    }

}
