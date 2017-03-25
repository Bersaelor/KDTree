//
//  Box.swift
//  KDTree
//
//  Created by Konrad Feiler on 25/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

final class Ref<T> {
    var value: T
    init(_ val: T) {value = val}
}

struct Box<T> {
    var ref: Ref<T>
    init(_ value: T) { ref = Ref(value) }
    
    var value: T {
        get { return ref.value }
        set {
            if !isKnownUniquelyReferenced(&ref) {
                ref = Ref(newValue)
                return
            }
            ref.value = newValue
        }
    }
}
