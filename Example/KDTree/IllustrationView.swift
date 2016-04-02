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
    
    private var points: [CGPoint] = Array(0..<23).map({_ in CGPoint(x: CGFloat.random(start: -1, end: 1), y: CGFloat.random(start: -1, end: 1))})
    private var tree: KDTree<CGPoint>?
    private var dotSize: CGFloat = 5.0
    private var cH: CGFloat { return 0.5 * 0.98 * min(self.bounds.height, self.bounds.width) }
    
    var tappedPoint: CGPoint?
    var nearestPoint: CGPoint?
    
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
        backgroundColor = UIColor.clearColor()
        
        tree = KDTree(values: points)
    }
    
    func update() {
        points =  Array(0..<pointNumber).map({_ in CGPoint(x: CGFloat.random(start: -1, end: 1), y: CGFloat.random(start: -1, end: 1))})
        tree = KDTree(values: points)
        self.setNeedsDisplay()
    }
    
    func pointTapped(point: CGPoint) {
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        tappedPoint = 1.0/cH * (point - c)
        xcLog.debug("c: \(c), tappedPoint: \(tappedPoint)")
        
        if let tappedPoint = tappedPoint {
            nearestPoint = tree?.nearest(toElement: tappedPoint)
            
            //check up if it's really the closest
            var bestDistance = Double.infinity
            let nearestFromArray = self.points.reduce(CGPoint.zero, combine: { (bestPoint: CGPoint, testPoint: CGPoint) -> CGPoint in
                let testDistance = tappedPoint.kdDistance(testPoint)
                if testDistance < bestDistance {
                    bestDistance = testDistance
                    return testPoint
                }
                return bestPoint
            })
            
            if nearestFromArray != nearestPoint {
                xcLog.debug("WARNING: nearestFromArray: \(nearestFromArray) != \(nearestPoint)")
                xcLog.debug("nearestFromArray.distance: \(nearestFromArray.kdDistance(tappedPoint))")
                xcLog.debug("nearest: \(nearestPoint!.kdDistance(tappedPoint))")
                
                xcLog.debug("---")
            }
        }
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            xcLog.error("failed to get graphics context")
            return
        }
        
        CGContextClearRect(context, self.bounds)
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        CGContextTranslateCTM(context, c.x, c.y)
        
        for point in points {
            UIColor.blackColor().setFill()
            CGContextFillEllipseInRect(context, CGRect(x: cH*point.x-0.5*dotSize, y: cH*point.y-0.5*dotSize, width: dotSize, height: dotSize))
        }
        
        drawTreeInContext(context)

        if let tappedPoint = tappedPoint {
            UIColor.blackColor().setStroke()
            CGContextMoveToPoint(context, cH*tappedPoint.x - 5.0, cH*tappedPoint.y - 5.0)
            CGContextAddLineToPoint(context, cH*tappedPoint.x + 5, cH*tappedPoint.y + 5)
            CGContextStrokePath(context)
            CGContextMoveToPoint(context, cH*tappedPoint.x - 5, cH*tappedPoint.y + 5)
            CGContextAddLineToPoint(context, cH*tappedPoint.x + 5, cH*tappedPoint.y - 5)
            CGContextStrokePath(context)
        }
        
        if let nearestPoint = nearestPoint {
            UIColor.purpleColor().setStroke()
            CGContextSetLineWidth(context, 1.0)
            CGContextStrokeEllipseInRect(context, CGRect(x: cH*nearestPoint.x-1.5*dotSize,
                y: cH*nearestPoint.y-1.5*dotSize, width: 3*dotSize, height: 3*dotSize))
            CGContextStrokePath(context)
        }
    }
    
    private func drawTreeInContext(context: CGContext) {
        CGContextSetLineWidth(context, 1.0)
        tree?.investigateTree({ (node, parents, depth) in
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
                    UIColor.blueColor().setStroke()
                    CGContextMoveToPoint(context, self.cH*value.x, minPoint)
                    CGContextAddLineToPoint(context, self.cH*value.x, maxPoint)
                }
                else {
                    UIColor.redColor().setStroke()
                    CGContextMoveToPoint(context, minPoint, self.cH*value.y)
                    CGContextAddLineToPoint(context, maxPoint, self.cH*value.y)
                    
                }
                CGContextStrokePath(context)
                
                let textP = CGPoint(x: value.x * self.cH + 5, y: value.y * self.cH + 1)
                (String(depth) as NSString).drawAtPoint(textP, withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(8)])
            }
        })
    }
}
