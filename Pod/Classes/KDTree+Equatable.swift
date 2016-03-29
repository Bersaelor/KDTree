//
//  KDTree+Equatable.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import Foundation

public func == <T: KDTreePoint> (lhs: KDTree<T>, rhs: KDTree<T>) -> Bool {
    switch (lhs, rhs) {
    case (.Leaf, .Leaf):
        return true
    case (let .Node(lleft, lvalue, _, lright), let .Node(rleft, rvalue, _, rright)) :
        return lvalue == rvalue && lleft == rleft && lright == rright
    default:
        return false
    }
}

public func != <T: KDTreePoint> (lhs: KDTree<T>, rhs: KDTree<T>) -> Bool {
    return !(lhs == rhs)
}
    
extension KDTree: Equatable { }
