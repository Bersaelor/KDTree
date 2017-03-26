// Swift3 adaption of https://gist.github.com/kazk/5c660d071642193f5301 by https://github.com/kazk

// An implementation of [Smoothsort] algorithm invented by Edsger Dijkstra,
// which I didn't get until reading [Smoothsort Demystified] by Keith Schwarz.
//
// Some optimizations like the chained swaps and corner case elimination were
// derived from [smoothsort.c] by Martin Knoblauch Revuelta.

func smoothsort<T : Comparable>( a: inout [T]) {
    smoothsort(&a) { $0 < $1 }
}

func smoothsort<T : Comparable>( a: inout [T], range: CountableRange<Int>) {
    smoothsort(&a, range: range) { $0 < $1 }
}

func smoothsort<T>(_ a: inout [T], isOrderedBefore: @escaping (T, T)->Bool) {
    smoothsort(&a, range: a.indices, isOrderedBefore: isOrderedBefore)
}

func smoothsort<T>(_ a: inout [T], range: CountableRange<Int>, isOrderedBefore: @escaping (T, T)->Bool) {
    if [].distance(from: range.lowerBound, to: range.upperBound) <= 1 { return }
    
    // Build the Leonardo heap and sort by consuming it.
    let sizes = heapify(a: &a, range: range, isOrderedBefore: isOrderedBefore)
    extract(a: &a, range: range, hsz: sizes, isOrderedBefore: isOrderedBefore)
}

extension Array {
    func smoothsorted(range: CountableRange<Int>, by isOrderedBefore: @escaping (Element, Element)->Bool) -> [Element] {
        var a = self
        smoothsort(&a, range: range, isOrderedBefore: isOrderedBefore)
        return a
    }
    
    func smoothsorted(by isOrderedBefore: @escaping (Element, Element)->Bool) -> [Element] {
        var a = self
        smoothsort(&a, isOrderedBefore: isOrderedBefore)
        return a
    }
}


// MARK: - Private
/// Leonardo Numbers. [OEIS A001595]
///
///        ⎧ 1                   if n ≤ 1
/// L(n) = ⎨
///        ⎩ L(n - 1) + L(n - 2) if n > 1
private let L = [
    1, 1, 3, 5,
    9, 15, 25, 41,
    
    67, 109, 177, 287,
    465, 753, 1219, 1973,
    
    3193, 5167, 8361, 13529,
    21891, 35421, 57313, 92735,
    
    150049, 242785, 392835, 635621,
    1028457, 1664079, 2692537, 4356617,
    
    7049155, 11405773, 18454929, 29860703,
    48315633, 78176337, 126491971, 204668309,
    
    331160281, 535828591, 866988873, 1402817465,
    2269806339, 3672623805, 5942430145, 9615053951,
    
    15557484097, 25172538049, 40730022147, 65902560197,
    106632582345, 172535142543, 279167724889, 451702867433,
    
    730870592323, 1182573459757, 1913444052081, 3096017511839,
    5009461563921, 8105479075761, 13114940639683, 21220419715445 // L[63]
]

// Tuple used to keep track of the forest of Leonardo tree heaps
fileprivate typealias HeapSizes = (mask: UInt, offset: Int)

/// Removes a tree from the forest
fileprivate func shrink( h: inout HeapSizes) {
    // NOTE: The mask will never be zero because
    //       this function is called in loops defined to terminate earlier and
    //       the case of empty forest is eliminated.
    repeat {
        h.mask >>= 1
        h.offset += 1
    } while ((h.mask & 1) == 0)
}


// sift downwards
fileprivate func siftIn<T>( a: inout [T], root: Int, size: Int, isOrderedBefore: @escaping (T, T)->Bool) {
    // Do nothing if already at bottom (Lt₁ or Lt₀)
    var size = size
    var root = root
    if (size <= 1) { return }
    
    // Returns the index and the order of the greater child node.
    let greaterChild = {(a: [T], r: Int, s: Int) -> (Int, Int) in
        let q = r - 1, p = q - L[s - 2]
        return isOrderedBefore(a[p], a[q]) ? (q, s - 2) : (p, s - 1)
    }
    
    let v = a[root] // The value to move down
    repeat { // For internal nodes (nodes with children)
        let (i, k) = greaterChild(a, root, size)
        // Stop when the greater child is less than or equal to the value;
        // i.e., when the value is not less than the greater child.
        if !isOrderedBefore(v, a[i]) { break }
        
        // Otherwise, swap with greater child and go down.
        (a[root], root, size) = (a[i], i, k)
    } while (size >= 2)
    a[root] = v
}


// Dijkstra's "trinkle". sift left, down;
// Ensures the correct ordering across sequence of heaps.
fileprivate func interheapSift<T>( a: inout [T], root: Int, hsz: HeapSizes, isOrderedBefore: @escaping (T, T)->Bool) {
    // *inter*-heap sift is unnecessary when there is only one heap.
    var hsz = hsz
    var root = root
    if hsz.mask == 1 {
        return siftIn(a: &a, root: root, size: hsz.offset, isOrderedBefore: isOrderedBefore)
    }
    
    let v = a[root]
    // Returns max(v, children) or just v if leaf was given.
    let effectiveRootValue = {(a: [T], r: Int, s: Int) -> T in
        if s <= 1 { return v } // no child
        
        let q = r - 1, p = q - L[s - 2]
        let x = a[p], y = a[q]
        let z = isOrderedBefore(x, y) ? y : x
        return isOrderedBefore(v, z) ? z : v
    }
    
    repeat { // While more than one trees exist in forest
        let i = root - L[hsz.offset] // Index of the left tree.
        // Stop if the effective root value is not less than
        // the root value of tree on left.
        let erv = effectiveRootValue(a, root, hsz.offset)
        if !isOrderedBefore(erv, a[i]) { break }
        
        // Otherwise, swap the roots and go left.
        (a[root], root) = (a[i], i)
        shrink(h: &hsz)
    } while (hsz.mask != 1)
    
    // Place the initial root value in the heap computed above,
    // and ensure the correct ordering within.
    a[root] = v
    siftIn(a: &a, root: root, size: hsz.offset, isOrderedBefore: isOrderedBefore)
}


// Build the Leonardo Heap
fileprivate func heapify<T>
    ( a: inout [T], range: CountableRange<Int>, isOrderedBefore: @escaping (T, T)->Bool) -> HeapSizes
{
    // Fuse if last two trees have sizes of contiguous Leonardo numbers.
    // (..., L[x+1], L[x])
    let fuse = {( h: inout HeapSizes)->() in
        h.mask    = (h.mask >> 2) | 1
        h.offset += 2
    }
    // Plant the next tree. Plant Lt₀ if last tree is Lt₁, otherwise plant Lt₁.
    let plant = {( h: inout HeapSizes)->() in
        if h.offset == 1 { // If the last tree is Lt₁, plant Lt₀.
            h.mask   = (h.mask << 1) | 1
            h.offset = 0
        } else { // Otherwise, plant Lt₁.
            h.mask   = (h.mask << numericCast(h.offset - 1)) | 1
            h.offset = 1
        }
    }
    
    let end = range.upperBound
    // Heap with size L[x] will be fused with its left heap if
    // the heap on left has size L[x + 1] and
    // there is at least one more element left in array.
    let leftFusible = {(i: Int, m: UInt) in
        (m & 0b11 == 0b11) && (i + 1 < end)
    }
    // Heap with size L[x] will be fused with its potential right heap if
    // x > 0 and there're at least L[x - 1] + 1 more elements left in array;
    // i.e., it's `rightFusable` if the heap on right is `leftFusable`.
    let rightFusible = {(i: Int, x: Int) in
        (x > 0) && (i + L[x - 1] + 1 < end)
    }
    let fusible = {(i: Int, h: HeapSizes) in
        leftFusible(i, h.mask) || rightFusible(i, h.offset)
    }
    
    // Initialize the heap with Lt₁ containing the first element,
    // then expand by adding the rest.
    var h: HeapSizes = (mask: 0b01, offset: 1)
    for i in range.lowerBound + 1 ..< end {
        // Fuse the last two heaps together if possible.
        // Otherwise, plant the next tree.
        if ((h.mask & 0b11) == 0b11) {
            fuse(&h)
        } else {
            plant(&h)
        }
        
        // If the heap will be fused, only sift in itself.
        // Otherwise, also sift across.
        if fusible(i, h) {
            siftIn(a: &a, root: i, size: h.offset, isOrderedBefore: isOrderedBefore)
        } else {
            interheapSift(a: &a, root: i, hsz: h, isOrderedBefore: isOrderedBefore)
        }
    }
    return h
}


// Extract elements from the Leonardo heap to put elements in sorted order.
fileprivate func extract<T>
    ( a: inout [T], range: CountableRange<Int>, hsz: HeapSizes, isOrderedBefore: @escaping (T, T)->Bool)
{
    // (ω1, n + 2) -> (ω011, n)
    var hsz = hsz
    let bisect = {( a: inout [T], r: Int, s: inout HeapSizes)->() in
        s.mask &= ~0b01 // Remove the parent from the forest.
        let q = r - 1, p = q - L[s.offset - 2]
        
        // Add both exposed trees to the forest and ensure ordering of roots.
        s.mask = (s.mask << 1) | 1
        s.offset -= 1
        interheapSift(a: &a, root: p, hsz: s, isOrderedBefore: isOrderedBefore)
        
        s.mask = (s.mask << 1) | 1
        s.offset -= 1
        interheapSift(a: &a, root: q, hsz: s, isOrderedBefore: isOrderedBefore)
    }
    
    // Extract elements starting from the end until the last two.
    for i in (range.lowerBound + 2 ..< range.upperBound).reversed() {
        if hsz.offset <= 1 {
            // If the last is Lt₁ or Lt₀, simply remove from the forest.
            // Lt₀: Expose Lt₁ which must exist by definition. (ω11, 0) -> (ω1, 1)
            // Lt₁: Shift until the next. (ω100...001, 1) -> (ω1, 1 + n)
            shrink(h: &hsz)
        } else {
            // Otherwise, bisect to expose children and sift.
            bisect(&a, i, &hsz)
        }
    }
}


// MARK: - Overview
// MARK: Heapify (Leonardo)
//  8 7 6 5 4 3 2 1 0
// -----------------------------------------------------------------------
//  8                  | 1 | (0b0001, 1)  | First: Lt₁
// -----------------------------------------------------------------------
//                     |   |              | Add Lt₀ ∵ (…, Lt₁)
//  8                  | 1 | (0b0011, 0)  |
//    7                | 0 |              | No interheap sift
//                     |   |              | ∵ Fusible with left into Lt₂
// -----------------------------------------------------------------------
//     ⇄               |   |              |
//  ⇵,--8              | 2 |              |
//  6  /               |   | (0b0001, 2)  | Fuse into Lt₂ ∵ (…, Lt₁, Lt₀)
//    7                |   |              |
// -----------------------------------------------------------------------
//                     |   |              | Add Lt₁
//   ,--8              | 2 |              |
//  6  /  5            | 1 | (0b0011, 1)  | No interheap sift
//    7                |   |              | ∵ Fusible with left into Lt₃
// -----------------------------------------------------------------------
//         ⇄           |   |              |
//      ⇵,--8          | 3 |              |
//   ,--7  /           |   | (0b0001, 3)  | Fuse into Lt₃ ∵ (…, Lt₂, Lt₁)
//  6 ⇵/  5            |   |              |
//    4                |   |              |
// -----------------------------------------------------------------------
//       ,--8          | 3 |              | Add Lt₁
//   ,--7  /           |   |              |
//  6  /  5   3        | 1 | (0b0101, 1)  | No interheap sift
//    4                |   |              | ∵ Fusible with right
// -----------------------------------------------------------------------
//       ,--8          | 3 |              | Add Lt₀ ∵ (…, Lt₁)
//   ,--7  /           |   |              |
//  6  /  5   3        | 1 | (0b1011, 0)  | No interheap sift
//    4         2      | 0 |              | ∵ Fusible with left into Lt₂
// -----------------------------------------------------------------------
//       ,--8    ⇄     | 3 |              | Fuse into Lt₂ ∵ (…, Lt₁, Lt₀)
//   ,--7  /  ⇵,--3    | 2 | (0b0011, 2)  |
//  6  /  5   1  /     |   |              | No interheap sift
//    4         2      |   |              | ∵ Fusible with left into Lt₄
// -----------------------------------------------------------------------
//                ⇄    |   |              |
//          ⇵,------8  | 4 |              |
//      ⇵,--7      /   |   |              |
//  ⇵,--6  /   ,--3    |   | (0b0001, 4)  | Fuse into Lt₄ ∵ (…, Lt₃, Lt₂)
//  0  /  5   1  /     |   |              |
//    4         2      |   |              |
// -----------------------------------------------------------------------
//  0 4 6 5 7 1 2 3 8
// MARK: Extract
//  0 4 6 5 7 1 2 3 8
// -----------------------------------------------------------------------
//           ,------8  | 4 |              |
//       ,--7      /   |   |              |
//   ,--6  /   ,--3    |   | (0b0001, 4)  | Lt₄
//  0  /  5   1  /     |   |              |
//    4         2      |   |              |
// -----------------------------------------------------------------------
//         ⇄     ⇄  8  |   |              |
//      ⇵,--6          | 3 |              | Expose children and sift
//   ,--4  /   ,--7    | 2 | (0b0011, 2)  |
//  0 ⇵/  5   1  /     |   |              | Lt₄ -> (Lt₃, Lt₂, 8)
//    3         2      |   |              |
// -----------------------------------------------------------------------
//         ⇄        8  |   |              |
//      ⇵,--4          | 3 |              | Expose children and sift
//   ,--3 ⇵/ ⇄ ⇄  7    |   | (0b1011, 0)  |
//  0 ⇵/  1   5        | 1 |              | Lt₂ -> (Lt₁, Lt₀, 7)
//    2         6      | 0 |              |
// -----------------------------------------------------------------------
//                  8  |   |              |
//       ,--4          | 3 |              |
//   ,--3  /      7    |   | (0b0101, 1)  | Take Lt₀ = 6
//  0  /  1   5        | 1 |              |
//    2         6      |   |              |
// -----------------------------------------------------------------------
//                  8  |   |              |
//       ,--4          | 3 |              |
//   ,--3  /      7    |   | (0b0001, 3)  | Take Lt₁ = 5
//  0  /  1   5        |   |              |
//    2         6      |   |              |
// -----------------------------------------------------------------------
//                  8  |   |              |
//       ⇄  4          |   |              | Expose children and sift
//   ,--2         7    | 2 | (0b0011, 1)  |
//  0 ⇵/  3   5        | 1 |              | Lt₃ -> (Lt₂, Lt₁, 4)
//    1         6      |   |              |
// -----------------------------------------------------------------------
//                  8  |   |              |
//          4          |   |              |
//   ,--2         7    | 2 | (0b0001, 2)  | Take Lt₁ = 3
//  0  /  3   5        |   |              |
//    1         6      |   |              |
// -----------------------------------------------------------------------
//                  8  |   |              |
//          4          |   |              | Expose children and sift
//      2         7    |   | (0b0011, 0)  |
//  0     3   5        | 1 |              | Lt₂ -> (Lt₁, Lt₀, 2)
//    1         6      | 0 |              | Remaining elements are sorted
// -----------------------------------------------------------------------
//  0 1 2 3 4 5 6 7 8

// MARK: - References
// [Smoothsort Demystified]: http://www.keithschwarz.com/smoothsort/
// TODO: Fully understand the proof of Lemma: "Any positive integer can be written as the sum of O(lg n) distinct Leonardo numbers."
//
// [Smoothsort]:             http://en.wikipedia.org/wiki/Smoothsort
// [Leonardo number]:        http://en.wikipedia.org/wiki/Leonardo_number
// [OEIS A001595]:           http://oeis.org/A001595/b001595.txt

// MARK: - smoothsort.c
// [smoothsort.c]: http://code.google.com/p/combsortcs2p-and-other-sorting-algorithms/source/browse/smoothsort.c
//
// MARK: LICENSE.TXT
// Copyright (c) 2013, Martin Knoblauch Revuelta
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall
// be included in all copies or substantial portions of the
// Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
// KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
// OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
