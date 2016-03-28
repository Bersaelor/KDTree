// https://github.com/Quick/Quick

import Quick
import Nimble
import KDTree

extension CGFloat {
    static func random(start start: CGFloat = 0.0, end: CGFloat = 1.0) -> CGFloat {
        return (end-start)*CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + start
    }
}

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        
        describe("KDTree") {
            let points = Array(0..<1000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
            let testPoint = CGPoint(x: 2,y: 2)
            let kdTree = KDTree(values: points)
            let kdTreePlus = kdTree.insert(testPoint)

            context("from CGPoints") {

                it("should not be empty") {
                    kdTree.isEmpty
                }

                it("count equals points") {
                    kdTree.count == points.count
                }

                it("as many elements as points") {
                    kdTree.elements.count == points.count
                }

                it("insert should increment") {
                    kdTreePlus.count == points.count + 1
                }
                
                it("should contain inserted point") {
                    kdTreePlus.contains(testPoint)
                }
                
                it("remove should decrement") {
                    kdTreePlus.remove(testPoint).count == points.count
                }

                it("remove many should still have correct count") {
                    var smallerPoints = points
                    var smallerTree = kdTree
                    for _ in 0..<50 {
                        let n = Int(arc4random() % UInt32(smallerPoints.count))
                        let pointToBeRemoved = smallerPoints[n]
                        smallerPoints.removeAtIndex(n)
                        smallerTree = smallerTree.remove(pointToBeRemoved)
                    }
                    print("smallerTree: \(smallerTree)")
                    
                    smallerPoints.count == smallerTree.count
                }
                
                it("should be deeper then 2") {
                    kdTree.depth > 2
                }
                
                it("filter should ") {
                    
                }

                
            }
            
        }
    }
}
