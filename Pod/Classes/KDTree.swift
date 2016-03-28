
public protocol KDTreeGrowing {
    static func kdTreeMetric(a: Self, b: Self) -> Double
    static var kdDimensionFunctions: [Self -> Double] { get }
}

public enum KDTree<T: KDTreeGrowing> {
    case Leaf
    indirect case Node(left: KDTree<T>, value: T, right: KDTree<T>)
    //    case Node(left: KDTree<T>, value: T, parent: KDTree<T>?, right: KDTree<T>)

    public init(values: [T], depth: Int = 0) {
        if values.isEmpty {
            self = .Leaf
        }
        else if values.count == 1, let firstValue = values.first {
            self = .Node(left: .Leaf, value: firstValue, right: .Leaf)
        }
        else {
            let currentSplittingDimension = depth % T.kdDimensionFunctions.count
            let sortedValues = values.sort { (a, b) -> Bool in
                let f = T.kdDimensionFunctions[currentSplittingDimension]
                return f(a) < f(b)
            }
            let median = sortedValues.count / 2
            let leftTree = KDTree(values: Array(sortedValues[0..<median]), depth: depth+1)
            let rightTree = KDTree(values: Array(sortedValues[median+1..<sortedValues.count]), depth: depth+1)
            
            self = KDTree.Node(left: leftTree, value: sortedValues[median], right: rightTree)
        }
    }
}
