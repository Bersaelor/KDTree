// https://github.com/Quick/Quick

import Quick
import Nimble
import KDTree

extension CGFloat {
    static func random(start start: CGFloat = 0.0, end: CGFloat = 1.0) -> CGFloat {
        return (end-start)*CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + start
    }
}

class BasicSpec: QuickSpec {
    override func spec() {
        
        describe("big KDTree") {
            let points = Array(0..<1000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
            let testPoint = CGPoint(x: 2,y: 2)
            let testPoint2 = CGPoint(x: 5,y: 5)
            let kdTree = KDTree(values: points)
            let kdTreePlus = kdTree.insert(testPoint)
            
            context("empty Tree") {
                let emptyTree = KDTree<CGPoint>(values: [])
                it("should be empty") {
                    expect(emptyTree.isEmpty).to(beTrue())
                }
            }
            
            context("from CGPoints") {
                
                it("should not be empty") {
//                    expect(kdTree).toNot(beEmpty())
                    expect(kdTree.isEmpty).to(beFalse())
                }

                it("count equals points") {
                    expect(kdTree.count).to(equal(points.count))
                }

                it("as many elements as points") {
                    expect(kdTree.elements.count).to(equal(points.count))
                }

                it("insert should increment") {
                    expect(kdTreePlus.count).to(equal(points.count + 1))
                }
                
                it("remove should decrement") {
                    expect(kdTreePlus.remove(testPoint).count).to(equal(points.count))
                }
                
                it("equals KDTree from reverse elements") {
                    expect(kdTree).to(equal(KDTree(values: points.reverse())))
                }
                
                it("should not be equal kdTreePlus") {
                    expect(kdTreePlus).notTo(equal(kdTree))
                }
                
                it("removing point that isn't contained should keep equal") {
                    expect(kdTreePlus).to(equal(kdTreePlus.remove(testPoint2)))
                }
                
                it("should contain inserted point") {
//                    expect(kdTreePlus).to(contain(testPoint))
                    expect(kdTreePlus.contains(testPoint)).to(beTrue())
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
                    
                    expect(smallerPoints.count).to(equal(smallerTree.count))
                }
                
                it("should be deeper then 2") {
                    expect(kdTree.depth).to(beGreaterThan(2))
                }
            }
        }
        
        describe("ten point KDTree") { 
            let tenPoints = Array(1...10).map({x in CGPoint(x: x, y: x)})
            let tenTree = KDTree(values: tenPoints)
            it("filter x > 5 contains 5") {
                expect(tenTree.filter({$0.x > 5}).count).to(equal(5))
            }
            
            let sum = tenTree.reduce(0) { $0 + Int($1.x)}
            it("sum should be 55") {
                expect(sum).to(equal(55))
            }
            
            it("array map to equal tree map") {
                let filterAndMap = tenTree.filter({$0.x > 5}).map({ $0.x + $0.y})
                let mapAndFilter = tenTree.map({ $0.x + $0.y}).filter({$0 > 10})
                expect(mapAndFilter).to(equal(filterAndMap))
            }
            
            context("Average norm by forEach") {
                var sum = 0.0
                tenPoints.forEach({ p in
                    sum += sqrt(Double(p.x*p.x + p.y*p.y))
                })
                let avg = sum / Double(tenPoints.count)
                it("should be") {
                    print("avg: \(avg)")
                    expect(avg).to(beCloseTo(7.78, within: 0.1))
                }
            }
        }
    }
}
