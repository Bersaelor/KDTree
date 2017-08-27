//
//  KDTree+Equatable.swift
//  Pods
//
//  Created by Konrad Feiler on 28/03/16.
//
//

import Foundation

public func == <T> (lhs: KDTree<T>, rhs: KDTree<T>) -> Bool {
    switch (lhs, rhs) {
    case (.leaf, .leaf):
        return true
    case (let .node(lleft, lvalue, _, lright), let .node(rleft, rvalue, _, rright)) :
        return lvalue == rvalue && lleft == rleft && lright == rright
    default:
        return false
    }
}

public func != <T> (lhs: KDTree<T>, rhs: KDTree<T>) -> Bool {
    return !(lhs == rhs)
}
    
extension KDTree: Equatable { }
