//
//  FillWithFormsView.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import KDTree

class FillWithFormsView: UIView {
    
    var initialPoints = 500 {
        didSet {
            if initialPoints != oldValue { update() }
        }
    }
    
    var points = 0
    
    private var maxDiscSize: CGFloat = 0.1
    private var minDiscSize: CGFloat = 0.01
    private var cH: CGFloat { return 0.5 * min(self.bounds.height, self.bounds.width) }
    private var discTree: KDTree<Disc> = KDTree<Disc>(values: [])
    
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
        
        let randomTree = KDTree(values: Array(0..<initialPoints).map({_ in CGPoint.random()}))
        discTree = randomTree.map { (point) -> Disc in
            let maxRadius = min(1 - abs(point.x), 1 - abs(point.y))
            if let nearest = randomTree.nearest(toElement: point, maxDistance: Double(2*maxDiscSize)) {
                let radius = min(0.5*norm(nearest - point), maxRadius)
                
                return Disc(center: point, radius: radius)
            }
            else { return Disc(center: point, radius: CGFloat.random(start: minDiscSize, end: min(maxDiscSize, maxRadius)))  }
        }
        
        var newPoints = 0
        for _ in 0...20*initialPoints {
            let testDisc = Disc(center:  CGPoint.random(), radius: 0.0)
            let maxCircleRadius = min(maxDiscSize, min(1 - abs(testDisc.center.x), 1 - abs(testDisc.center.y)))
            let nearest8Discs = discTree.nearestK(8, toElement: testDisc)
            let nearest8Distances = nearest8Discs.map { norm(testDisc.center - $0.center) - $0.radius }
            let circleRadius = min(maxCircleRadius, nearest8Distances.minElement() ?? maxCircleRadius)
            
            if circleRadius >= minDiscSize {
                newPoints += 1
                discTree = discTree.insert(Disc(center: testDisc.center, radius: circleRadius))
            }
        }
        
        points = initialPoints + newPoints
    }
    
    func update() {

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
        CGContextScaleCTM(context, cH, cH)
        
        
        drawTreeInContext(context)
    }
    
    private func drawTreeInContext(context: CGContext) {
        CGContextSetLineWidth(context, 1.0)
        discTree.forEach { (disc: Disc) in
            UIColor(hue: CGFloat.random(start: 0.05, end: 0.14), saturation: CGFloat.random(start: 0.4, end: 0.9), brightness: 0.9, alpha: 1.0).setFill()
            CGContextFillEllipseInRect(context, disc.rect)
        }
    }

}
