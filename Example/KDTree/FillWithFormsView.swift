//
//  FillWithFormsView.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#if os(OSX)
    import Cocoa
    public typealias View = NSView
#else
    import UIKit
    public typealias View = UIView
#endif

import KDTree

let initialPoints = 500
let maxDiscSize: CGFloat = 0.1
let minDiscSize: CGFloat = 0.01

enum ShapeChosen {
    case Circle
    case Square
}

class FillWithFormsView: View {

    var points = 0 {
        didSet { self.pointsUpdated?(points) }
    }
    var pointsUpdated: (Int -> Void)?
    
    var chosenShape: ShapeChosen = .Circle {
        didSet {
            downloadQueue.cancelAllOperations()
            commonInit()
            update()
        }
    }
    
    // swiftlint:disable variable_name_min_length
    private var cH: CGFloat { return 0.5 * min(self.bounds.height, self.bounds.width) }
    // swiftlint:enable variable_name_min_length
    private var closeDiscs: [Disc] = []
    private var discTree: KDTree<Disc> = KDTree<Disc>(values: [])
    private lazy var downloadQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Shape creation queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        #if os(iOS)
            backgroundColor = UIColor.lightGrayColor()
            backgroundColor = UIColor.clearColor()
        #endif

        let randomTree = KDTree(values: (0..<initialPoints).map({_ in CGPoint.random()}))
        discTree = randomTree.map { (point) -> Disc in
            let color = Color(hue: CGFloat.random(start: 0.05, end: 0.15),
                saturation: CGFloat.random(start: 0.4, end: 0.9), brightness: 0.9, alpha: 1.0)
            let maxRadius = min(1 - abs(point.x), 1 - abs(point.y))
            if let nearest = randomTree.nearest(toElement: point, maxDistance: Double(2*maxDiscSize)) {
                let distance = chosenShape == .Circle ? norm(nearest - point) : maximumNorm(nearest - point)
                let radius = min(0.5*distance, maxRadius)
                
                return Disc(center: point, radius: radius, color: color)
            }
            else { return Disc(center: point, radius: CGFloat.random(start: minDiscSize, end: min(maxDiscSize, maxRadius)), color: color)  }
        }
        points = initialPoints
        
        addMoreShapesBlock()
        
        xcLog.debug("operationCount: \(downloadQueue.operationCount)")
    }
    
    func addMoreShapesBlock() {
        let moreShapesOperation = NSBlockOperation()
        weak var weakShapeOp = moreShapesOperation
        moreShapesOperation.addExecutionBlock { [weak self] in
            guard let strongself = self else { return }
            var treeCopy = strongself.discTree
            var newPoints = 0
            for _ in 0...5*initialPoints {
                if weakShapeOp?.cancelled == true { break }
                let testDisc = Disc(center:  CGPoint.random(), radius: 0.0, color: Color.clearColor())
                let maxshapeRadius = min(maxDiscSize, min(1 - abs(testDisc.center.x), 1 - abs(testDisc.center.y)))
                let nearest8Discs = treeCopy.nearestK(8, toElement: testDisc)
                let closestDistance = nearest8Discs.reduce(CGFloat.infinity) { (currentMin, disc) -> CGFloat in
                    let distance = (strongself.chosenShape == .Circle) ?
                        norm(testDisc.center - disc.center) - disc.radius : maximumNorm(testDisc.center - disc.center) - disc.radius
                    return min(currentMin, distance)
                }
                let shapeRadius = min(maxshapeRadius, closestDistance ?? maxshapeRadius)
                
                if shapeRadius >= minDiscSize {
                    newPoints += 1
                    let color = Color(hue: CGFloat.random(start: 0.05, end: 0.15),
                        saturation: CGFloat.random(start: 0.4, end: 0.9), brightness: 0.9, alpha: 1.0)
                    treeCopy = treeCopy.insert(Disc(center: testDisc.center, radius: shapeRadius, color: color))
                }
            }
            
            if weakShapeOp?.cancelled == false {
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    self?.discTree = treeCopy
                    xcLog.debug("newPoints: \(newPoints)")
                    self?.points = newPoints + strongself.points
                    self?.update()
                    if newPoints > Int(0.1*Double(initialPoints)) { self?.addMoreShapesBlock() }
                }
            }
        }
        
        self.downloadQueue.addOperation(moreShapesOperation)
    }
    
    func pointTapped(point: CGPoint) {
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let tappedPoint = 1.0/cH * (point - c)
        xcLog.debug("c: \(c), tappedPoint: \(tappedPoint)")
        closeDiscs = discTree.nearestK(16, toElement: Disc(center: tappedPoint, radius: 0.0, color: Color.clearColor()))
        
        
        #if os(OSX)
            self.needsDisplay = true
        #else
            self.setNeedsDisplay()
        #endif
    }
    
    
    func update() {

        #if os(OSX)
            self.needsDisplay = true
        #else
            self.setNeedsDisplay()
        #endif
    }
    
    override func drawRect(rect: CGRect) {
        #if os(OSX)
            guard let context = NSGraphicsContext.currentContext()?.CGContext else {
                xcLog.error("failed to get graphics context")
                return
            }
        #else
            guard let context = UIGraphicsGetCurrentContext() else {
                xcLog.error("failed to get graphics context")
                return
            }
        #endif
        
        CGContextClearRect(context, self.bounds)
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        CGContextTranslateCTM(context, c.x, c.y)
        CGContextScaleCTM(context, cH, cH)
        
        drawTreeInContext(context)
    }
    
    private func drawTreeInContext(context: CGContext) {
        CGContextSetLineWidth(context, 1.0)
        discTree.forEach { (disc: Disc) in
            if closeDiscs.contains(disc) {
                Color(hue: CGFloat.random(start: 0.35, end: 0.54),
                    saturation: CGFloat.random(start: 0.75, end: 0.95), brightness: 0.9, alpha: 1.0).setFill()
            }
            else { disc.color.setFill() }
            if chosenShape == .Circle { CGContextFillEllipseInRect(context, disc.rect) }
            else { CGContextFillRect(context, disc.rect) }
        }
    }

}
