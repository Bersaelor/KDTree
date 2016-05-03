// https://github.com/Quick/Quick

import Quick
import Nimble
import KDTree

// swiftlint:disable function_body_length
class BasicSpec: QuickSpec {
    override func spec() {
        
        describe("big KDTree") {
            let points = (0..<1000).map({_ in CGPoint(x: CGFloat.random(), y: CGFloat.random())})
            let testPoint = CGPoint(x: 2, y: 2)
            let testPoint2 = CGPoint(x: 5, y: 5)
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
                    expect(kdTree.isEmpty) == false
                }

                it("count equals points") {
                    expect(kdTree.count) == points.count
                }

                it("as many elements as points") {
                    expect(kdTree.elements.count) == points.count
                }

                it("insert should increment") {
                    expect(kdTreePlus.count) == points.count + 1
                }
                
                it("remove should decrement") {
                    expect(kdTreePlus.remove(testPoint).count) == points.count
                }
                
                it("equals KDTree from reverse elements") {
                    expect(kdTree) == KDTree(values: points.reverse())
                }
                
                it("should not be equal kdTreePlus") {
                    expect(kdTreePlus) != kdTree
                }
                
                it("removing point that isn't contained should keep equal") {
                    expect(kdTreePlus) == kdTreePlus.remove(testPoint2)
                }
                
                it("should contain inserted point") {
                    expect(kdTreePlus.contains(testPoint)) == true
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
                    smallerPoints = smallerPoints.sort({ $0.x < $1.x })
                    
                    expect(smallerPoints) == smallerTree.elements.sort({ $0.x < $1.x })
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
                expect(tenTree.filter({$0.x > 5}).count) == 5
            }
            
            let sum = tenTree.reduce(0) { $0 + Int($1.x)}
            it("sum should be 55") {
                expect(sum) == 55
            }
            
            it("array map to equal tree map") {
                let filterAndMap = tenTree.filter({$0.x > 5}).mapToArray({ $0.x + $0.y })
                let mapAndFilter = tenTree.mapToArray({ $0.x + $0.y }).filter({$0 > 10})
                expect(mapAndFilter) == filterAndMap
            }

            it("filtered map to Tree of Rects equals mapped filter") {
                let filterAndMap = tenTree.filter({ $0.norm > 5 }).map({ CGRectMake($0.x, $0.y, 0.0, 0.0)
                    .insetBy(dx: -0.5, dy: -0.5) })
                let mapAndFilter = tenTree.map({ CGRectMake($0.x, $0.y, 0.0, 0.0)
                    .insetBy(dx: -0.5, dy: -0.5) }).filter({ $0.origin.norm > 4.5 })
                expect(mapAndFilter) == filterAndMap
            }

            context("Average norm by forEach") {
                var sum = 0.0
                tenPoints.forEach({ p in
                    sum += sqrt(Double(p.x*p.x + p.y*p.y))
                })
                let avg = sum / Double(tenPoints.count)
                it("should be") {
                    expect(avg).to(beCloseTo(7.78, within: 0.1))
                }
            }
        }
    }
}
// swiftlint:enable function_body_length
