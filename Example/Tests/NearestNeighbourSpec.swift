// https://github.com/Quick/Quick

import Quick
import Nimble
import KDTree

class NearestNeighbourSpec: QuickSpec {
    override func spec() {
        
        describe("Nearest Neigbour") {
            context("for tenpoint") {
                let tenPoints = Array(1...10).map({x in CGPoint(x: x, y: x)})
                let tenTree = KDTree(values: tenPoints)
                
                it("of (4.3,4.5)") {
                    let testPoint = CGPoint(x: 4.3, y: 4.5)
                    expect(tenTree.nearest(toElement: testPoint)) != nil
                    expect(tenTree.nearest(toElement: testPoint)) == CGPoint(x: 4.0, y: 4.0)
                }
                
                it("of (5.2,5.5)") {
                    let testPoint = CGPoint(x: 5.2, y: 5.5)
                    expect(tenTree.nearest(toElement: testPoint)) != nil
                    expect(tenTree.nearest(toElement: testPoint)) == CGPoint(x: 5.0, y: 5.0)
                }
                it("of (4.9,4.5)") {
                    let testPoint = CGPoint(x: 4.9, y: 4.5)
                    expect(tenTree.nearest(toElement: testPoint)) != nil
                    expect(tenTree.nearest(toElement: testPoint)) == CGPoint(x: 5.0, y: 5.0)
                }
            }
            
            context("special CGPoints set") {
                let points = [CGPoint(x: -0.5, y: 0),
                              CGPoint(x: -0.1, y: -1),
                              CGPoint(x: 0.0, y: -1.0),
                              CGPoint(x: 0.1, y: 0.5),
                              CGPoint(x: 1.0, y: 0.0)]
                
                let tree = KDTree(values: points)
                it("should bubble over after finding firstBest") {
                    expect(tree.nearest(toElement: CGPoint(x: -0.1, y:0.5))) == points[3]
                }
            }
            
            context("Distant subtree") {
                let points = [CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: -1, y: 1)]
                let tree = KDTree(values: points)
                
                it("3 nearest points should be all 3") {
                    expect(tree.nearestK(3, toElement: CGPoint(x: 1, y: 1))) == points
                }
            }
        }
    }
}
