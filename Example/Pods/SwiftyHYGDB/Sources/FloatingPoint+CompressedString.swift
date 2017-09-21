//
//  FloatingPoint+CompressedString.swift
//  SwiftyHYGDB
//
//  Created by Konrad Feiler on 13.09.17.
//

import Foundation

extension String {
    var trailingZerosTrimmed: String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
    }
}

extension Float {
    var compressedString: String {
        guard abs(self) > Float.ulpOfOne else { return "0" }
        return String(format: "%f", self).trailingZerosTrimmed
    }
}

extension Double {
    var compressedString: String {
        guard abs(self) > Double.ulpOfOne else { return "0" }
        return String(format: "%f", self).trailingZerosTrimmed
    }
}
