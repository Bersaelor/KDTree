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
    var radius: CGFloat = 0.125
    
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
    
    static let ascensionRange: CGFloat = 24.0
    static let declinationRange: CGFloat = 180
    
    static let minSize: CGFloat = 1.0
    static let maxSize: CGFloat = 12.0
    
    func currentRadii() -> CGSize {
        let aspectRatio = self.bounds.size.width / self.bounds.size.height
        return CGSize(width: radius * StarMapView.ascensionRange, height: radius / aspectRatio * StarMapView.declinationRange)
    }
    
    func starPosition(for point: CGPoint) -> CGPoint {
        let relativeToCenter = point - CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radiusInPxH = 0.5 * self.bounds.width / (radius * StarMapView.ascensionRange)
        let radiusInPxV = 0.5 * self.bounds.width / (radius * StarMapView.declinationRange)
        return CGPoint(x: 1.0/radiusInPxH, y: 1.0/radiusInPxV) * relativeToCenter
    }
    
    private func pixelPosition(for positionInSpace: CGPoint, radii: CGPoint, dotSize: CGFloat) -> CGPoint {
        let starCenter = radii*(positionInSpace - centerPoint)
        return starCenter - dotSize * CGPoint(x: 0.5, y: 0.5)
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
        let radiusInPxH = 0.5 * self.bounds.width / (radius * StarMapView.ascensionRange)
        let radiusInPxV = 0.5 * self.bounds.width / (radius * StarMapView.declinationRange)
        let pixelRadii = CGPoint(x: radiusInPxH, y: radiusInPxV)

        let linearDotFactor = (StarMapView.minSize - StarMapView.maxSize)/32.5
        let absoluteAddition = 26.0/32.5 * StarMapView.minSize + 6.5/32.5 * StarMapView.maxSize
        
        for star in self.stars ?? [] {
            let mag = CGFloat(star.starData?.value.mag ?? 0.0)
            let dotSize: CGFloat = linearDotFactor * mag + absoluteAddition
//            xcLog.debug("mag: \(mag) and DotSize \(dotSize)")
            let relativePosition = pixelPosition(for: star.starPoint, radii: pixelRadii, dotSize: dotSize)
            let rect = CGRect(origin: relativePosition, size: CGSize(width: dotSize, height: dotSize))
            self.setStarColor(for: star)
            context.fillEllipse(in: rect)
        }
        
        if let tappedStar = tappedStar {
            let circleSize: CGFloat = 15
            let relativePosition = pixelPosition(for: tappedStar.starPoint, radii: pixelRadii, dotSize: circleSize)
            let rect: CGRect = CGRect(origin: relativePosition, size: CGSize(width: circleSize, height: circleSize))
            Color.orange.setStroke()
            context.strokeEllipse(in: rect)
            
            if let colorIndex = tappedStar.starData?.value.colorIndex {
                xcLog.debug("tappedStar: \(tappedStar), \n"
                    + "color for colorIndex(\(colorIndex)): \(self.bv2ToRGB(for: CGFloat(colorIndex)))")
            }
            
            self.drawStarText(for: tappedStar, position: relativePosition, circleSize: circleSize)
        }
    }
    
    private func setStarColor(for star: Star) {
        if let colorIndex = star.starData?.value.colorIndex {
            bv2ToRGB(for: CGFloat(colorIndex), spectralType: star.starData?.value.spectralType).setFill()
        } else {
            Color.white.setFill()
        }
    }
    
    private func drawStarText(for star: Star, position: CGPoint, circleSize: CGFloat) {
        #if os(OSX)
            let verticalAdjustment = 1.0
        #else
            let verticalAdjustment = -1.0
        #endif
        
        guard let starData = star.starData?.value else { return }
        let glieseName: String? = starData.gl_id
        let hdName: String? = starData.hd_id.flatMap { (id: Int32) -> String in  return "HD\(id)" }
        let hrName: String? = starData.hr_id.flatMap { (id: Int32) -> String in  return "HR\(id)" }
        let idName: String = "HYG\(star.dbID)"
        let textString: String = starData.properName
            ?? glieseName ?? starData.bayer_flamstedt ?? hdName ?? hrName ?? idName
        let isLeftOfCenter = position.x < 0.0
        let textInnerCorner = position + circleSize * CGPoint(x: isLeftOfCenter ? 0.9 : 0.05, y: verticalAdjustment * 1.05)
        let textOuterCorner = textInnerCorner + CGPoint(x: isLeftOfCenter ? 200 : -200, y: verticalAdjustment * 14.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = isLeftOfCenter ? .left : .right
        let attributes = [NSFontAttributeName: Font.systemFont(ofSize: 12.0),
                          NSForegroundColorAttributeName: Color.orange,
                          NSParagraphStyleAttributeName: paragraphStyle]
        (textString as NSString).draw(in: CGRect(pointA: textInnerCorner, pointB: textOuterCorner), withAttributes: attributes)
    }

    
    /// RGB <0,1> <- BV <-0.4,+2.0> [-]
    private func bv2ToRGB(for bv: CGFloat, spectralType: String? = nil, logging: Bool = false) -> Color {

        if let spectralType = spectralType {
            if spectralType.hasPrefix("M6") {
                var r: CGFloat = 1.0; var g: CGFloat = 0.765; var b: CGFloat = 0.44
                
                #if os(OSX)
                    return NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0)
                #else
                    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
                #endif
            }
            else if spectralType.hasPrefix("M8") {
                var r: CGFloat = 1.0; var g: CGFloat = 0.776; var b: CGFloat = 0.43
                
                #if os(OSX)
                    return NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0)
                #else
                    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
                #endif
            }
        }
        
        var bv = bv
        var t: CGFloat = 0
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        if bv < -0.4 { bv = -0.4}
        if bv > 2.0 { bv = 2.0}
        
        switch bv {
        case -0.4 ... 0.0:
            t = (bv+0.40)/(0.00+0.40)
            r = 0.61+(0.11*t)+(0.1*t*t)
        case 0.0 ... 0.4:
            t = (bv-0.00)/(0.40-0.00)
            r = 0.83+(0.17*t)
        case 0.4 ... 2.1:
            t = (bv-0.40)/(2.10-0.40)
            r = 1.00
        default: break
        }
        
        switch bv {
        case -0.4 ... 0.0:
            t = (bv+0.40)/(0.00+0.40)
            g = 0.70 + (0.07*t)+(0.1*t*t)
        case 0.0 ... 0.4:
            t = (bv-0.00)/(0.40-0.00)
            g = 0.87 + (0.11*t)
        case 0.4 ... 1.6:
            t = (bv-0.40)/(1.60-0.40)
            g = 0.98 - (0.16*t)
        case 1.6 ... 2.0:
            t = (bv-1.60)/(2.00-1.60)
            g = 0.82         - (0.5*t*t)
        default: break
        }
        
        switch bv {
        case -0.4 ... 0.4:
            t = (bv+0.40)/(0.40+0.40)
            b = 1.0
        case 0.4 ... 1.5:
            t = (bv-0.40)/(1.50-0.40)
            b = 1.00 - (0.47*t)+(0.1*t*t)
        case 1.5 ... 1.94:
            t = (bv-1.50)/(1.94-1.50)
            b = 0.63         - (0.6*t*t)
        default: break
        }
        
        #if os(OSX)
            return NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0)
        #else
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        #endif
    }
}
