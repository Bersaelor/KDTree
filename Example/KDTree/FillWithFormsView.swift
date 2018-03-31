//
//  FillWithFormsView.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#if os(macOS)
    import AppKit
    public typealias View = NSView
#else
    import UIKit
    public typealias View = UIView
#endif

extension View {
    func xPlatformNeedsDisplay(rect: CGRect? = nil) {
        #if os(macOS)
            self.needsDisplay = true
        #else
            if let rect = rect {
                self.setNeedsDisplay(rect)
            } else {
                self.setNeedsDisplay()
            }
        #endif
    }
}

import KDTree

let initialPoints = 1000
let maxDiscSize: CGFloat = 0.1
let minDiscSize: CGFloat = 0.01

enum ShapeChosen {
    case circle
    case square
}

class FillWithFormsView: View {

    var points = 0 {
        didSet { self.pointsUpdated?(points) }
    }
    var pointsUpdated: ((Int) -> Void)?
    
    var chosenShape: ShapeChosen = .circle {
        didSet {
            downloadQueue.cancelAllOperations()
            commonInit()
            update()
        }
    }
    
    fileprivate var adjSize: CGFloat { return 0.5 * min(self.bounds.height, self.bounds.width) }
    fileprivate var closeDiscs: [Disc] = []
    fileprivate var discTree: KDTree<Disc> = KDTree<Disc>(values: [])
    fileprivate lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
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
            backgroundColor = UIColor.lightGray
            backgroundColor = UIColor.clear
        #endif

        let randomTree = KDTree(values: (0..<initialPoints).map({_ in CGPoint.random()}))
        discTree = randomTree.map { (point) -> Disc in
            let color = Color(hue: CGFloat.random(0.05, end: 0.15),
                saturation: CGFloat.random(0.4, end: 0.9), brightness: 0.9, alpha: 1.0)
            let maxRadius = min(1 - abs(point.x), 1 - abs(point.y))
            if let nearest = randomTree.nearest(to: point, maxDistance: Double(2*maxDiscSize)) {
                let distance = chosenShape == .circle ? (nearest - point).norm : (nearest - point).maximumNorm
                let radius = min(0.5*distance, maxRadius)
                
                return Disc(center: point, radius: radius, color: color)
            }
            else { return Disc(center: point, radius: CGFloat.random(minDiscSize, end: min(maxDiscSize, maxRadius)), color: color)  }
        }
        points = initialPoints
        
        addMoreShapesBlock()
        
        log.debug("operationCount: \(self.downloadQueue.operationCount)")
    }
    
    func addMoreShapesBlock() {
        let moreShapesOperation = BlockOperation()
        weak var weakShapeOp = moreShapesOperation
        moreShapesOperation.addExecutionBlock { [weak self] in
            guard let strongself = self else { return }
            var treeCopy = strongself.discTree
            var newPoints = 0
            for _ in 0...5*initialPoints {
                if weakShapeOp?.isCancelled == true { break }
                let testDisc = Disc(center: CGPoint.random(), radius: 0.0, color: Color.clear)
                let maxshapeRadius = min(maxDiscSize, min(1 - abs(testDisc.center.x), 1 - abs(testDisc.center.y)))
                let nearest8Discs = treeCopy.nearestK(8, to: testDisc)
                let closestDistance = nearest8Discs.reduce(CGFloat.infinity) { (currentMin, disc) -> CGFloat in
                    let distance = (strongself.chosenShape == .circle) ?
                        (testDisc.center - disc.center).norm - disc.radius : (testDisc.center - disc.center).maximumNorm - disc.radius
                    return min(currentMin, distance)
                }
                let shapeRadius = min(maxshapeRadius, closestDistance)
                
                if shapeRadius >= minDiscSize {
                    newPoints += 1
                    let color = Color(hue: CGFloat.random(0.05, end: 0.15),
                        saturation: CGFloat.random(0.4, end: 0.9), brightness: 0.9, alpha: 1.0)
                    treeCopy = treeCopy.inserting(Disc(center: testDisc.center, radius: shapeRadius, color: color))
                }
            }
            
            if weakShapeOp?.isCancelled == false {
                DispatchQueue.main.async { [weak self] in
                    self?.discTree = treeCopy
                    log.debug("newPoints: \(newPoints)")
                    self?.points = newPoints + strongself.points
                    self?.update()
                    if newPoints > Int(0.1*Double(initialPoints)) { self?.addMoreShapesBlock() }
                }
            }
        }
        
        self.downloadQueue.addOperation(moreShapesOperation)
    }
    
    func tapped(_ point: CGPoint) {
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let tappedPoint = 1.0/adjSize * (point - c)
        log.debug("c: \(c), tappedPoint: \(tappedPoint)")
        closeDiscs = discTree.nearestK(16, to: Disc(center: tappedPoint, radius: 0.0, color: Color.clear))
        
        xPlatformNeedsDisplay()
    }
    
    func update() {
        xPlatformNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        #if os(macOS)
            guard let context = NSGraphicsContext.current?.cgContext else {
                log.error("failed to get graphics context")
                return
            }
        #else
            guard let context = UIGraphicsGetCurrentContext() else {
                log.error("failed to get graphics context")
                return
            }
        #endif
        
        context.clear(rect)
        let c = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        context.translateBy(x: c.x, y: c.y)
        context.scaleBy(x: adjSize, y: adjSize)
        
        drawTreeInContext(context)
    }
    
    fileprivate func drawTreeInContext(_ context: CGContext) {
        context.setLineWidth(1.0)
        discTree.forEach { (disc: Disc) in
            if closeDiscs.contains(disc) {
                Color(hue: CGFloat.random(0.35, end: 0.54),
                    saturation: CGFloat.random(0.75, end: 0.95), brightness: 0.9, alpha: 1.0).setFill()
            }
            else { disc.color.setFill() }
            if chosenShape == .circle { context.fillEllipse(in: disc.rect) }
            else { context.fill(disc.rect) }
        }
    }

}
