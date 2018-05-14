//
//  StarMapView.swift
//  KDTree
//
//  Created by Konrad Feiler on 26/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif
import SwiftyHYGDB

class StarMapView: View {

    var tappedPoint: CGPoint?
    var centerPoint = CGPoint(x: 12.0, y: 0.0) {
        didSet {
            if centerPoint.x > RadialStar.ascensionRange {
                centerPoint = CGPoint(x: centerPoint.x - RadialStar.ascensionRange, y: centerPoint.y)
            } else if centerPoint.x < 0 {
                centerPoint = CGPoint(x: centerPoint.x + RadialStar.ascensionRange, y: centerPoint.y)
            }
            if centerPoint.y > maxDeclination {
                centerPoint = CGPoint(x: centerPoint.x, y: maxDeclination)
            } else if centerPoint.y < -maxDeclination {
                centerPoint = CGPoint(x: centerPoint.x, y: -maxDeclination)
            }
        }
    }
    
    var radius: CGFloat = 0.15 {
        didSet {
            radius = min(maxRadius, max(minRadius, radius))
            recalculatePixelRadii()
            clipCenterDeclination()
        }
    }
    
    private var maxDeclination: CGFloat {
        let minY = CGFloat(10)
        let minDec = CGFloat(-91)
        return (minY - bounds.midY) / pixelRadii.y - minDec
    }
    
    private func clipCenterDeclination() {
        if centerPoint.y > maxDeclination {
            centerPoint = CGPoint(x: centerPoint.x, y: maxDeclination)
        } else if centerPoint.y < -maxDeclination {
            centerPoint = CGPoint(x: centerPoint.x, y: -maxDeclination)
        }
    }    
    private let minRadius: CGFloat = 0.02
    private let maxRadius: CGFloat = 0.3
    
    var pixelRadii = CGPoint.zero
    var verticalScreenRadius: CGFloat = 0.0
    
    private func recalculatePixelRadii() {
        let radiusInPxH = 0.5 * self.bounds.width / (radius * RadialStar.ascensionRange)
        let radiusInPxV = 0.5 * self.bounds.width / (radius * RadialStar.declinationRange)
        pixelRadii = CGPoint(x: radiusInPxH, y: radiusInPxV)
        verticalScreenRadius = self.bounds.midX / pixelRadii.x
    }
    
    var magnification: CGFloat {
        let delta = 1 - (radius - minRadius) / (maxRadius - minRadius)
        // delta goes from 0 for highest magnification to 1 for lowest
        return 0.8 + 2.5 * delta * delta
    }
    
    var tappedStar: RadialStar? = nil {
        didSet { xPlatformNeedsDisplay() }
    }
    
    var stars: [RadialStar]? {
        didSet { xPlatformNeedsDisplay() }
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
        #if os(macOS)
            layer?.backgroundColor = Color.black.cgColor
            recalculatePixelRadii()
        #else
            backgroundColor = .black
        #endif
    }
        
    static let vegaSize: Double = 4.0
    
    #if os(macOS)
    override func resizeSubviews(withOldSize: NSSize) {
        super.resizeSubviews(withOldSize: withOldSize)
        recalculatePixelRadii()
    }
    #else
    override func layoutSubviews() {
        super.layoutSubviews()
        recalculatePixelRadii()
    }
    #endif

    func currentRadii() -> CGSize {
        let aspectRatio = self.bounds.size.width / self.bounds.size.height
        return CGSize(width: radius * RadialStar.ascensionRange, height: radius / aspectRatio * RadialStar.declinationRange)
    }
    
    func skyPosition(for pointInViewCoordinates: CGPoint) -> CGPoint {
        let relativeToCenter = pointInViewCoordinates - CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        var point = -1.0 * CGPoint(x: 1.0/pixelRadii.x, y: 1.0/pixelRadii.y) * relativeToCenter + centerPoint
        if point.x < 0.0 { point = CGPoint(x: point.x + RadialStar.ascensionRange, y: point.y) }
        if point.x > RadialStar.ascensionRange { point = CGPoint(x: point.x - RadialStar.ascensionRange, y: point.y) }
        return point
    }
    
    private func pixelPosition(for positionInSky: CGPoint, radii: CGPoint, dotSize: CGFloat) -> CGPoint {
        let below0h = positionInSky.x + verticalScreenRadius > RadialStar.ascensionRange && centerPoint.x < verticalScreenRadius
        let over24h = positionInSky.x - verticalScreenRadius < 0 && centerPoint.x + verticalScreenRadius > RadialStar.ascensionRange
        let adjVec = CGPoint(x: below0h ? RadialStar.ascensionRange : over24h ? -RadialStar.ascensionRange : 0, y: 0)
        let starCenter = radii*(centerPoint - (positionInSky - adjVec))
        return starCenter - dotSize * CGPoint(x: 0.5, y: 0.5)
    }
    
    override func draw(_ rect: CGRect) {
        let startDraw = Date()

        #if os(macOS)
            guard let context = NSGraphicsContext.current?.cgContext else { return }
        #else
            guard let context = UIGraphicsGetCurrentContext() else { return }
        #endif

        context.clear(rect)
        
        //recenter in middle
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        context.translateBy(x: c.x, y: c.y)
        
        drawStars(context: context)
        
        drawAxis(context: context)
        
        if let tappedStar = tappedStar {
            drawTapped(context: context, star: tappedStar)
        }
        
        log.verbose("Finished Drawing in \(Date().timeIntervalSince(startDraw))s")
    }
    
    private func setStarColor(for star: RadialStar) {
        if let colorIndex = star.starData?.value.colorIndex {
            bv2ToRGB(for: CGFloat(colorIndex), spectralType: star.starData?.value.getSpectralType()).setFill()
        } else {
            Color.white.setFill()
        }
    }
    
    private func drawStars(context: CGContext) {
        let rootValue: Float = 1.0/(2.4 * 1.085)

        for star in self.stars ?? [] {
            if star.starData?.value.db_id == 0 {
                let paragraphStyleLbl = NSMutableParagraphStyle()
                paragraphStyleLbl.alignment = .center
                let size = 12.0 * sqrt(magnification)
                let attributesLbl = [NSAttributedStringKey.font: Font.systemFont(ofSize: CGFloat(size)),
                                     NSAttributedStringKey.paragraphStyle: paragraphStyleLbl]
                let relativePosition = pixelPosition(for: star.starPoint, radii: pixelRadii, dotSize: 0.0)
                ("☀️" as NSString).draw(in: CGRect(pointA: relativePosition + CGPoint(x: size, y: size),
                                                       pointB: relativePosition - CGPoint(x: size, y: size)),
                                            withAttributes: attributesLbl)
            } else {
                let mag = star.starData?.value.mag ?? 0.0
                let dotSize = CGFloat(StarMapView.vegaSize) * magnification / CGFloat(exp(mag * rootValue))
                let relativePosition = pixelPosition(for: star.starPoint, radii: pixelRadii, dotSize: dotSize)
                let rect = CGRect(origin: relativePosition, size: CGSize(width: dotSize, height: dotSize))
                setStarColor(for: star)
                context.fillEllipse(in: rect)
            }
        }
    }
    
    private func drawAxis(context: CGContext) {
        let color = Color.lightGray
        let border: CGFloat = 25
        let origin = CGPoint(x: self.bounds.midX - border, y: self.bounds.midY - border)
        let fiveDegreePoint = origin - CGPoint(x: 0.0, y: 5.0 * pixelRadii.y)
        let oneHourPoint = origin - CGPoint(x: pixelRadii.x, y: 0.0)

        color.setStroke()
        context.move(to: fiveDegreePoint)
        context.addLine(to: origin + CGPoint(x: 0, y: 2))
        context.strokePath()
        context.move(to: origin + CGPoint(x: 2, y: 0))
        context.addLine(to: oneHourPoint)
        context.setLineWidth(1.0)
        context.strokePath()
        
        //1h Label
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        let attributes = [NSAttributedStringKey.font: Font.systemFont(ofSize: 8),
                          NSAttributedStringKey.foregroundColor: color,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle]
        ("1h" as NSString).draw(in: CGRect(pointA: oneHourPoint, pointB: oneHourPoint + CGPoint(x: -20, y: 8)),
                                withAttributes: attributes)
        // 5° label
        let paragraphStyleDeg = NSMutableParagraphStyle()
        paragraphStyleDeg.alignment = .left
        let attributesDeg = [NSAttributedStringKey.font: Font.systemFont(ofSize: 8),
                             NSAttributedStringKey.foregroundColor: color,
                             NSAttributedStringKey.paragraphStyle: paragraphStyleDeg]
        ("5°" as NSString).draw(in: CGRect(pointA: fiveDegreePoint - CGPoint(x: -2, y: -5),
                                            pointB: fiveDegreePoint - CGPoint(x: -20, y: 5)),
                                 withAttributes: attributesDeg)
        // position label
        let paragraphStyleLbl = NSMutableParagraphStyle()
        paragraphStyleLbl.alignment = .center
        let attributesLbl = [NSAttributedStringKey.font: Font.systemFont(ofSize: 8.0),
                             NSAttributedStringKey.foregroundColor: color,
                             NSAttributedStringKey.paragraphStyle: paragraphStyleLbl]
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let tappedCoo = skyPosition(for: origin + c)
        let lbl = String(format: "%.1fh,%.1f°", 0.1*round(10*tappedCoo.x), 0.1*round(10*tappedCoo.y))
        (lbl as NSString).draw(in: CGRect(pointA: origin - CGPoint(x: -25 + 1, y: -12),
                                          pointB: origin - CGPoint(x: 25 + 1, y: -2)),
                               withAttributes: attributesLbl)
    }
    
    private func drawTapped(context: CGContext, star: RadialStar) {
        let circleSize: CGFloat = 15
        let relativePosition = pixelPosition(for: star.starPoint, radii: pixelRadii, dotSize: circleSize)
        let rect: CGRect = CGRect(origin: relativePosition, size: CGSize(width: circleSize, height: circleSize))
        Color.orange.setStroke()
        context.setLineWidth(1.0)
        context.strokeEllipse(in: rect)
        
        let mag = star.starData?.value.mag ?? 0.0
        let rootValue: Float = 1.0/(2.4 * 1.085)
        let dotSize = CGFloat(StarMapView.vegaSize) * magnification / CGFloat(exp(mag * rootValue))
        log.verbose("F(\(mag) = \(dotSize))")
        if let colorIndex = star.starData?.value.colorIndex {
            log.verbose("tappedStar: \(star), \n"
                + "color for colorIndex(\(colorIndex)): \(self.bv2ToRGB(for: CGFloat(colorIndex)))")
        }
        
        drawStarText(for: star, position: relativePosition, circleSize: circleSize)
    }
    
    private func drawStarText(for star: RadialStar, position: CGPoint, circleSize: CGFloat) {
        let verticalAdjustment = 1.0
        
        guard let starData = star.starData?.value else { return }
        let glieseName: String? = starData.getGlId()
        let hdName: String? = starData.hd_id != -1 ? "HD\(starData.hd_id)" : nil
        let hrName: String? = starData.hr_id != -1 ? "HD\(starData.hr_id)" : nil
        let idName: String = "HYG\(starData.db_id)"
        var textString: String = starData.getProperName()
            ?? starData.getBayerFlamstedt() ?? glieseName ?? hdName ?? hrName ?? idName
        textString += String(format: " (%.1fpc)", 3.262*starData.distance)
        let isLeftOfCenter = position.x < 0.0
        let textInnerCorner = position + circleSize * CGPoint(x: isLeftOfCenter ? 0.9 : 0.05, y: verticalAdjustment * 1.05)
        let textOuterCorner = textInnerCorner + CGPoint(x: isLeftOfCenter ? 200 : -200, y: verticalAdjustment * 14.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = isLeftOfCenter ? .left : .right
        let attributes = [NSAttributedStringKey.font: Font.systemFont(ofSize: 12.0),
                          NSAttributedStringKey.foregroundColor: Color.orange,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle]
        (textString as NSString).draw(in: CGRect(pointA: textInnerCorner, pointB: textOuterCorner), withAttributes: attributes)
    }

    /// RGB <0,1> <- BV <-0.4,+2.0> [-]
    private func bv2ToRGB(for bv: CGFloat, spectralType: String? = nil) -> Color {
        if let spectralType = spectralType {
            if spectralType.hasPrefix("M6") {
                let r: CGFloat = 1.0; let g: CGFloat = 0.765; let b: CGFloat = 0.44
                return Color(red: r, green: g, blue: b, alpha: 1.0)
            }
            else if spectralType.hasPrefix("M8") {
                let r: CGFloat = 1.0; let g: CGFloat = 0.776; let b: CGFloat = 0.43
                return Color(red: r, green: g, blue: b, alpha: 1.0)
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
        
        return Color(red: r, green: g, blue: b, alpha: 1.0)
    }
}
