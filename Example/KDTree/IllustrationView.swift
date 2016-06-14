//
//  IllustrationView.swift
//  KDTree
//
//  Created by Konrad Feiler on 01/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import KDTree

class IllustrationView: UIView {
    
    var pointNumber = 23 {
        didSet {
            if pointNumber != oldValue { update() }
        }
    }
    
    var isKNearest = false {
        didSet {
            if isKNearest != oldValue { update() }
        }
    }
    
    private var points: [CGPoint] = (0..<23).map({_ in CGPoint(x: CGFloat.random(start: -1, end: 1), y: CGFloat.random(start: -1, end: 1))})
    private var tree: KDTree<CGPoint>?
    private var dotSize: CGFloat = 5.0
    // swiftlint:disable variable_name_min_length
    private var cH: CGFloat { return 0.5 * 0.98 * min(self.bounds.height, self.bounds.width) }
    // swiftlint:enable variable_name_min_length

    var tappedPoint: CGPoint?
    var nearestPoints: [CGPoint] = []
    
    final var handleRadius: CGFloat {
        return 0.575*cH
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
        backgroundColor = UIColor.clear()
        
        tree = KDTree(values: points)
    }
    
    func update() {
        points =  (0..<pointNumber).map({_ in CGPoint(x: CGFloat.random(start: -1, end: 1), y: CGFloat.random(start: -1, end: 1))})
        tree = KDTree(values: points)
        self.setNeedsDisplay()
    }
    
    func pointTapped(point: CGPoint) {
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        tappedPoint = 1.0/cH * (point - c)
        xcLog.debug("c: \(c), tappedPoint: \(tappedPoint)")
        
        if let tappedPoint = tappedPoint {
            if isKNearest { nearestPoints = tree?.nearestK(5, toElement: tappedPoint) ?? [] }
            else { nearestPoints = tree?.nearest(toElement: tappedPoint).map({ [$0] }) ?? [] }
            
            //check up if it's really the closest
            var bestDistance = Double.infinity
            let nearestFromArray = self.points.reduce(CGPoint.zero, combine: { (bestPoint: CGPoint, testPoint: CGPoint) -> CGPoint in
                let testDistance = tappedPoint.squaredDistance(to: testPoint)
                if testDistance < bestDistance {
                    bestDistance = testDistance
                    return testPoint
                }
                return bestPoint
            })
            
            if nearestFromArray != nearestPoints.first {
                xcLog.debug("WARNING: nearestFromArray: \(nearestFromArray) != \(nearestPoints.first)")
                xcLog.debug("nearestFromArray.distance: \(nearestFromArray.squaredDistance(to: tappedPoint))")
                xcLog.debug("nearest: \(nearestPoints.first!.squaredDistance(to: tappedPoint))")
            }
        }
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            xcLog.error("failed to get graphics context")
            return
        }
        
        context.clear(self.bounds)
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        context.translate(x: c.x, y: c.y)
        
        for point in points {
            UIColor.black().setFill()
            context.fillEllipse(in: CGRect(x: cH*point.x-0.5*dotSize, y: cH*point.y-0.5*dotSize,
                width: dotSize, height: dotSize))
        }
        
        drawTreeInContext(context: context)

        if let tappedPoint = tappedPoint {
            UIColor.black().setStroke()
            context.moveTo(x: cH*tappedPoint.x - 5.0, y: cH*tappedPoint.y - 5.0)
            context.addLineTo(x: cH*tappedPoint.x + 5, y: cH*tappedPoint.y + 5)
            context.strokePath()
            context.moveTo(x: cH*tappedPoint.x - 5, y: cH*tappedPoint.y + 5)
            context.addLineTo(x: cH*tappedPoint.x + 5, y: cH*tappedPoint.y - 5)
            context.strokePath()
        }
        
        for nearestPoint in nearestPoints {
            UIColor.purple().setStroke()
            context.setLineWidth(1.0)
            context.strokeEllipse(in: CGRect(x: cH*nearestPoint.x-1.0*dotSize,
                y: cH*nearestPoint.y-1.0*dotSize, width: 2*dotSize, height: 2*dotSize))
            context.strokePath()
        }
        
        //ring around tappedPoint and nearest elements
        guard let tappedPoint = tappedPoint, farthestPoint = nearestPoints.last else { return }
        UIColor.yellow().setStroke()
        let distance = (farthestPoint - tappedPoint).norm
        context.setLineWidth(1.0)
        context.strokeEllipse(in: CGRect(x: cH*(tappedPoint.x-distance), y: cH*(tappedPoint.y-distance),
            width: cH*2*distance, height: cH*2*distance))
        context.strokePath()
    }
    
    private func drawTreeInContext(context: CGContext) {
        context.setLineWidth(1.0)
        tree?.investigateTree { (node, parents, depth) in
            switch node {
            case .Leaf: break
            case .Node(_, let value, let dimension, _):
                var minPoint = -self.cH
                var maxPoint = self.cH
                if dimension == 0 {
                    for parent in parents {
                        if case .Node(_, let parentValue, let parentDim, _) = parent
                            where parentDim == 1 && parentValue.y > value.y {
                            maxPoint = parentValue.y*self.cH
                            break
                        }
                    }
                    for parent in parents {
                        if case .Node(_, let parentValue, let parentDim, _) = parent
                            where parentDim == 1 && parentValue.y < value.y {
                            minPoint = parentValue.y*self.cH
                            break
                        }
                    }
                }
                else {
                    for parent in parents {
                        if case .Node(_, let parentValue, let parentDim, _) = parent
                            where parentDim == 0 &&  parentValue.x > value.x {
                            maxPoint = parentValue.x*self.cH
                            break
                        }
                    }
                    for parent in parents {
                        if case .Node(_, let parentValue, let parentDim, _) = parent
                            where parentDim == 0 &&  parentValue.x < value.x {
                            minPoint = parentValue.x*self.cH
                            break
                        }
                    }
                }
                
                if dimension == 0 {
                    UIColor.blue().setStroke()
                    context.moveTo(x: self.cH*value.x, y: minPoint)
                    context.addLineTo(x: self.cH*value.x, y: maxPoint)
                }
                else {
                    UIColor.red().setStroke()
                    context.moveTo(x: minPoint, y: self.cH*value.y)
                    context.addLineTo(x: maxPoint, y: self.cH*value.y)
                    
                }
                context.strokePath()
                
                let textP = CGPoint(x: value.x * self.cH + 5, y: value.y * self.cH + 1)
                (String(depth) as NSString).draw(at: textP,
                                                 withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 8)])
            }
        }
    }
}
