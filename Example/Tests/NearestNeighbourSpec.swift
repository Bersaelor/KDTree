// https://github.com/Quick/Quick

import Quick
import Nimble
import KDTree

class NearestNeighbourSpec: QuickSpec {
    override func spec() {
        
        describe("ten point KDTree") {
            let tenPoints = Array(1...10).map({x in CGPoint(x: x, y: x)})
            let tenTree = KDTree(values: tenPoints)
            let testPoint = CGPoint(x: 5.2, y: 5.5)
            it("filter x > 5 contains 5") {
                expect(tenTree.nearest(toElement: testPoint)).toNot(beNil())
            }
            
        }
    }
}
