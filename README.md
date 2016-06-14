# KDTree

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org/)
[![Version](https://img.shields.io/cocoapods/v/KDTree.svg?style=flat)](http://cocoapods.org/pods/KDTree)
[![License](https://img.shields.io/cocoapods/l/KDTree.svg?style=flat)](http://cocoapods.org/pods/KDTree)
[![Platform](https://img.shields.io/cocoapods/p/KDTree.svg?style=flat)](http://cocoapods.org/pods/KDTree)
[![CI Status](http://img.shields.io/travis/Bersaelor/KDTree.svg?style=flat)](https://travis-ci.org/Bersaelor/KDTree)

Swift implementation of a k-dimensional binary space partitioning tree.
The KDTree is implemented as an immutable enum, inspired by functional trees from [objc.io](https://www.objc.io/books/functional-swift/).
KDTree algorithm according to [Wikipedia](https://en.wikipedia.org/wiki/K-d_tree) and [ubilabs js example](https://github.com/ubilabs/kd-tree-javascript).

Example Illustration:
![Example Illustration](/Screenshots/kNearest.png?raw=true)

The nodes have labels for their depths, the blue lines go through nodes that partition the plane vertically, the red ones for horizontal partitions.


## Usage

Import the package in your *.swift file:
```swift
import KDTree
```

Make sure your data values conforom to 
```swift
public protocol KDTreePoint: Equatable {
  static var dimensions: Int { get }
  func kdDimension(dimension: Int) -> Double
  func squaredDistance(otherPoint: Self) -> Double
}
```
(CGPoint conforms to KDTreePoint as part of the package)

Then you can grow your own Tree:
```swift
extension CustomDataPoint: KDTreePoint { ... }

let dataValues: [CustomDataPoint] = ...

var tree: KDTree<CGPoint> = KDTree(values: dataValues)
```

Then you can `insert()`, `remove()`, `map()`, `filter()`, `reduce()` and `forEach()` on this tree with the expected results.

## Applications

### K-Nearest Neighbour:

Given a KDTree:

```swift
var tree: KDTree<CGPoint> = KDTree(values: points)
```

we can retrieve the nearest Neighbour to a test point like so
```swift
let nearest: CGPoint? = tree.nearest(toElement: point)
```

or the get the 10 nearest neighbours

```swift
let nearestPoints: [CGPoint] = tree.nearestK(10, toElement: point)
```

Complexity is O(log N), while brute-force searching through an Array is of cource O(N).

Preliminary performance results can be gained by running the unit tests, the load example has 10.000 random points in [-1,1]x[-1,1] and find the nearest points for 500 test points:

![Performance Results](/Screenshots/performance.png?raw=true)


### Tesselations:

![Tesselation Example](/Screenshots/tesselations.png?raw=true)

### Range-Search:

It's also possible to use the KDTree to search for a range of values using:
```swift
let pointsInRange: [CGPoint] = tree.elementsInRange([(0.2, 0.4), (0.45, 0.75)])
```
I might add an example picture for this later.

## Installation

KDTree is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "KDTree"
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## License

KDTree is available under the MIT license. See the LICENSE file for more info.
