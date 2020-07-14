//
//  KDTree+Sequence.swift
//
// Copyright (c) 2020 mathHeartCode UG(haftungsbeschränkt) <konrad@mathheartcode.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

extension KDTree: Sequence {
    
    public func makeIterator() -> AnyIterator<Element> {
        
        switch self {
        case .leaf: return AnyIterator { return nil }
        case let .node(left, value, _, right):
            var index = 0
            var iteratorStruct = KDTreeIteratorStruct(left: left, right: right)

            return AnyIterator {
                if index == 0 {
                    index = 1
                    return value
                }
                else if index == 1, let nextValue = iteratorStruct.leftIterator?.next() {
                    return nextValue
                }
                else {
                    index = 2
                    return iteratorStruct.rightIterator?.next()
                }
            }
            
        }
    }
}

fileprivate struct KDTreeIteratorStruct<Element: KDTreePoint> {
    let left: KDTree<Element>
    let right: KDTree<Element>
    
    init(left: KDTree<Element>, right: KDTree<Element>) {
        self.left = left
        self.right = right
    }
    
    lazy var leftIterator: AnyIterator<Element>? = { return self.left.makeIterator() }()
    lazy var rightIterator: AnyIterator<Element>? = { return self.right.makeIterator() }()
}
