# KDTree

[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://swift.org/)
[![CI Status](http://img.shields.io/travis/Bersaelor/KDTree.svg?style=flat)](https://travis-ci.org/Bersaelor/KDTree)

Swift implementation of a k-dimensional binary space partitioning tree.
The KDTree is implemented as an immutable enum, inspired by functional trees from [objc.io](https://www.objc.io/books/functional-swift/).
KDTree algorithm according to [Wikipedia](https://en.wikipedia.org/wiki/K-d_tree) and [ubilabs js example](https://github.com/ubilabs/kd-tree-javascript).

If you want to know more, you can watch [this talk](https://youtu.be/CwcEjxRtn18) I gave at [funswiftconf](http://2017.funswiftconf.com).

Visual animation of creating a KDTree:

![Example Illustration](/Screenshots/tree_generation.gif?raw=true)

Very simply put, a tree is created by:
1. find the median point in the current direction
2. bisect along the hyperplane(=line in 2D) going through the current median
3. go one step deeper, same thing with next axis

The blue lines go through nodes that partition the plane vertically, the red ones for horizontal partitions.


## Usage

Import the package in your *.swift file:
```swift
import KDTree
```

Make sure your data values conforom to 
```swift
public protocol KDTreePoint: Equatable {
  static var dimensions: Int { get }
  func kdDimension(_ dimension: Int) -> Double
  func squaredDistance(to otherPoint: Self) -> Double
}
```
(CGPoint conforms to KDTreePoint as part of the package)

Then you can grow your own Tree:
```swift
extension CustomDataPoint: KDTreePoint { ... }

let dataValues: [CustomDataPoint] = ...

var tree: KDTree<CGPoint> = KDTree(values: dataValues)
```

Then you can `insert()`, `remove()`, `map()`, `filter()`, `reduce()` and `forEach()` on this tree with the expected results, as KDTree conforms to Sequence.

## Applications

### K-Nearest Neighbour:

![Example Illustration](/Screenshots/kNearest.png?raw=true)

Given a KDTree:

```swift
var tree: KDTree<CGPoint> = KDTree(values: points)
```

we can retrieve the nearest Neighbour to a test point like so
```swift
let nearest: CGPoint? = tree.nearest(to: point)
```

or the get the 10 nearest neighbours

```swift
let nearestPoints: [CGPoint] = tree.nearestK(10, to: point)
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

One example is based on the [HYG Database](https://github.com/astronexus/HYG-Database/blob/master/README.md) of 120 thousand stars. Here we see a piece of the sky around 10h right ascension and 35° declination where the KDTree algorithm can be used to both get the stars in the area the iPhone screen is pointing at and also find the closest Star to a position the user is tapping via NN:

<img src="https://raw.githubusercontent.com/Bersaelor/KDTree/master/Screenshots/starMap.png" width="621" />

## Examples of Implementation

The example app in the `Example` folder shows some demo implementations on `iOS`.

`KDTree` can also be used as a package in a server-side-swift app. [StarsOnKitura](https://github.com/Bersaelor/StarsOnKitura) is one example that returns stars from the [HYG database](http://www.astronexus.com/hyg) of 120'000 stars using `ascension`/`declination` parameters. Live available running on a 64MB instance on [IBM Bluemix](https://starsonkitura.eu-de.mybluemix.net).

## Installation

In Xcode, open `File` -> `Swift Packages` -> `Add Package Dependency` and copy the project url into the text field:

```
https://github.com/Bersaelor/KDTree
```

Or add the following to your `Package.swift` dependencies

```
.Package(url: "https://github.com/Bersaelor/KDTree", majorVersion: 1, minor: 4),
```

As of 2020 the Swift package manager covers all use cases and is super convenient, so we felt that supporting other package managers like Carthage or Cocoapods is no longer necessary.

## License

KDTree is available under the MIT license. See the LICENSE file for more info.
