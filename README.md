# KDTree

[![CI Status](http://img.shields.io/travis/Konrad Feiler/KDTree.svg?style=flat)](https://travis-ci.org/Konrad Feiler/KDTree)
[![Version](https://img.shields.io/cocoapods/v/KDTree.svg?style=flat)](http://cocoapods.org/pods/KDTree)
[![License](https://img.shields.io/cocoapods/l/KDTree.svg?style=flat)](http://cocoapods.org/pods/KDTree)
[![Platform](https://img.shields.io/cocoapods/p/KDTree.svg?style=flat)](http://cocoapods.org/pods/KDTree)

!Under Construction!

Swift implementation of a k-dimensional binary space partitioning tree.
The KDTree is implemented as an immutable enum, inspired by functional trees from [objc.io](https://www.objc.io/books/functional-swift/).
KDTree algorithm according to [Wikipedia](https://en.wikipedia.org/wiki/K-d_tree) and [ubilabs js example](https://github.com/ubilabs/kd-tree-javascript).

Example Illustration:
![Example Illustration](/Screenshots/kNearest.png?raw=true)

The nodes have labels for their depths, the blue lines go through nodes that partition the plane vertically, the red ones for horizontal partitions.

Preliminary performance results can be gained by running the unit tests, the load example has 10.000 random points in [-1,1]x[-1,1] and find the nearest points for 1000 test points.
![Performance Results](/Screenshots/performance.png?raw=true)


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Applications

Tesselations:

![Tesselation Example](/Screenshots/tesselations.png?raw=true)




## Installation

KDTree is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "KDTree"
```

## License

KDTree is available under the MIT license. See the LICENSE file for more info.
