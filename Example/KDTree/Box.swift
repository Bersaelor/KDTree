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
    //unmanaged because the assumption is that all data points are retained only once, and released at the end of the program
    var ref: Unmanaged<Ref<T>>
    init(_ value: T) { ref = Unmanaged.passRetained(Ref(value)) }
    
    var value: T {
        get { return ref.takeUnretainedValue().value }
        set {
            ref.takeUnretainedValue().value = newValue
        }
    }
}
