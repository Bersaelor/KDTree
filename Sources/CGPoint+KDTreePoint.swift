//
//  CGPoint+KDTreeGrowing.swift
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
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import CoreGraphics
#endif

extension CGPoint: KDTreePoint {
    public static var dimensions = 2
    
    public func kdDimension(_ dimension: Int) -> Double {
        return dimension == 0 ? Double(self.x) : Double(self.y)
    }

    public func squaredDistance(to otherPoint: CGPoint) -> Double {
        let x = self.x - otherPoint.x
        let y = self.y - otherPoint.y
        return Double(x*x + y*y)
    }
}
