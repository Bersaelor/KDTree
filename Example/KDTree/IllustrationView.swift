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
    
    fileprivate var points: [CGPoint] = (0..<23).map({_ in CGPoint(x: CGFloat.random(-1, end: 1), y: CGFloat.random(-1, end: 1))})
    fileprivate var tree: KDTree<CGPoint>?
    fileprivate var dotSize: CGFloat = 5.0
    fileprivate var adjSize: CGFloat { return 0.5 * 0.98 * min(self.bounds.height, self.bounds.width) }

    var tappedPoint: CGPoint?
    var nearestPoints: [CGPoint] = []
    
    final var handleRadius: CGFloat {
        return 0.575*adjSize
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
        backgroundColor = UIColor.clear
        
        tree = KDTree(values: points)
    }
    
    func update() {
        points =  (0..<pointNumber).map({_ in CGPoint(x: CGFloat.random(-1, end: 1), y: CGFloat.random(-1, end: 1))})
        tree = KDTree(values: points)
        self.setNeedsDisplay()
    }
    
    func pointTapped(_ point: CGPoint) {
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        tappedPoint = 1.0/adjSize * (point - c)
        xcLog.debug("c: \(c), tappedPoint: \(self.tappedPoint)")
        
        if let tappedPoint = tappedPoint {
            if isKNearest { nearestPoints = tree?.nearestK(5, toElement: tappedPoint) ?? [] }
            else { nearestPoints = tree?.nearest(toElement: tappedPoint).map({ [$0] }) ?? [] }
            
            //check up if it's really the closest
            var bestDistance = Double.infinity
            let nearestFromArray = self.points.reduce(CGPoint.zero, { (bestPoint: CGPoint, testPoint: CGPoint) -> CGPoint in
                let testDistance = tappedPoint.squaredDistance(to: testPoint)
                if testDistance < bestDistance {
                    bestDistance = testDistance
                    return testPoint
                }
                return bestPoint
            })
            
            if nearestFromArray != nearestPoints.first {
                xcLog.debug("WARNING: nearestFromArray: \(nearestFromArray) != \(self.nearestPoints.first)")
                xcLog.debug("nearestFromArray.distance: \(nearestFromArray.squaredDistance(to: tappedPoint))")
                xcLog.debug("nearest: \(self.nearestPoints.first?.squaredDistance(to: tappedPoint))")
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
        context.translateBy(x: c.x, y: c.y)
        
        for point in points {
            UIColor.black.setFill()
            context.fillEllipse(in: CGRect(x: adjSize*point.x-0.5*dotSize, y: adjSize*point.y-0.5*dotSize,
                width: dotSize, height: dotSize))
        }
        
        drawTreeInContext(context)

        if let tappedPoint = tappedPoint {
            UIColor.black.setStroke()
            context.move(to: CGPoint(x: adjSize*tappedPoint.x - 5.0, y: adjSize*tappedPoint.y - 5.0))
            context.addLine(to :CGPoint(x: adjSize*tappedPoint.x + 5, y: adjSize*tappedPoint.y + 5))
            context.strokePath()
            context.move(to: CGPoint(x: adjSize*tappedPoint.x - 5, y: adjSize*tappedPoint.y + 5))
            context.addLine(to: CGPoint(x: adjSize*tappedPoint.x + 5, y: adjSize*tappedPoint.y - 5))
            context.strokePath()
        }
        
        for nearestPoint in nearestPoints {
            UIColor.purple.setStroke()
            context.setLineWidth(1.0)
            context.strokeEllipse(in: CGRect(x: adjSize*nearestPoint.x-1.0*dotSize,
                y: adjSize*nearestPoint.y-1.0*dotSize, width: 2*dotSize, height: 2*dotSize))
            context.strokePath()
        }
        
        //ring around tappedPoint and nearest elements
        guard let tappedPoint = tappedPoint, let farthestPoint = nearestPoints.last else { return }
        UIColor.yellow.setStroke()
        let distance = (farthestPoint - tappedPoint).norm
        context.setLineWidth(1.0)
        context.strokeEllipse(in: CGRect(x: adjSize*(tappedPoint.x-distance), y: adjSize*(tappedPoint.y-distance),
            width: adjSize*2*distance, height: adjSize*2*distance))
        context.strokePath()
    }
    
    fileprivate func drawTreeInContext(_ context: CGContext) {
        context.setLineWidth(1.0)
        tree?.investigateTree { (node, parents, depth) in
            switch node {
            case .leaf: break
            case .node(_, let value, let dimension, _):
                var minPoint = -self.adjSize
                var maxPoint = self.adjSize
                if dimension == 0 {
                    for parent in parents {
                        if case .node(_, let parentValue, let parentDim, _) = parent, parentDim == 1 && parentValue.y > value.y {
                            maxPoint = parentValue.y*self.adjSize
                            break
                        }
                    }
                    for parent in parents {
                        if case .node(_, let parentValue, let parentDim, _) = parent, parentDim == 1 && parentValue.y < value.y {
                            minPoint = parentValue.y*self.adjSize
                            break
                        }
                    }
                }
                else {
                    for parent in parents {
                        if case .node(_, let parentValue, let parentDim, _) = parent, parentDim == 0 &&  parentValue.x > value.x {
                            maxPoint = parentValue.x*self.adjSize
                            break
                        }
                    }
                    for parent in parents {
                        if case .node(_, let parentValue, let parentDim, _) = parent, parentDim == 0 &&  parentValue.x < value.x {
                            minPoint = parentValue.x*self.adjSize
                            break
                        }
                    }
                }
                
                if dimension == 0 {
                    UIColor.blue.setStroke()
                    context.move(to: CGPoint(x: adjSize*value.x, y: minPoint))
                    context.addLine(to: CGPoint(x: adjSize*value.x, y: maxPoint))
                }
                else {
                    UIColor.red.setStroke()
                    context.move(to: CGPoint(x: minPoint, y: adjSize*value.y))
                    context.addLine(to: CGPoint(x: maxPoint, y: adjSize*value.y))
                    
                }
                context.strokePath()
                
                let textP = CGPoint(x: value.x * self.adjSize + 5, y: value.y * self.adjSize + 1)
                (String(depth) as NSString).draw(at: textP,
                                                 withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 8)])
            }
        }
    }
}
