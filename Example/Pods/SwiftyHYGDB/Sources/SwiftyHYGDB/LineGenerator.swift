//
//  LineGenerator.swift
//
//  Created by Konrad Feiler on 25/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

func lineIterator(file: UnsafeMutablePointer<FILE>) -> AnyIterator<String>
{
    return AnyIterator { () -> String? in
        var line: UnsafeMutablePointer<CChar>? = nil
        var linecap: Int = 0
        defer { free(line) }
        
        if getline(&line, &linecap, file) > 0, let line = line {
            return String(validatingUTF8: line)
        }
        return nil
    }
}

func lineIteratorC(file: UnsafeMutablePointer<FILE>) -> AnyIterator<UnsafeMutablePointer<CChar>>
{
    return AnyIterator { () -> UnsafeMutablePointer<CChar>? in
        var line: UnsafeMutablePointer<CChar>? = nil
        var linecap: Int = 0
        
        if getline(&line, &linecap, file) > 0, let line = line {
            return line
        }
        return nil
    }
}
