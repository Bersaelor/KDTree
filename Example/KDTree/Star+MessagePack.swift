//
//  Star+MessagePack.swift
//  KDTree_Example
//
//  Created by Konrad Feiler on 03.09.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import MessagePack

protocol Packable {
    init(value: MessagePackValue)
    func messagePackValue() -> MessagePackValue
}

extension StarData: Packable {
    init(value: MessagePackValue) {
        var iterator = value.arrayValue!.makeIterator()

        right_ascension = iterator.next()!.floatValue!
        declination = iterator.next()!.floatValue!
        hip_id = iterator.next()!.integerValue.flatMap({ Int32($0) })
        hd_id = iterator.next()!.integerValue.flatMap({ Int32($0) })
        hr_id = iterator.next()!.integerValue.flatMap({ Int32($0) })
        gl_id = iterator.next()!.stringValue
        bayer_flamstedt = iterator.next()!.stringValue
        properName = iterator.next()!.stringValue
        distance = iterator.next()!.doubleValue!
        pmra = iterator.next()!.doubleValue!
        pmdec = iterator.next()!.doubleValue!
        rv = iterator.next()!.doubleValue
        mag = iterator.next()!.doubleValue!
        absmag = iterator.next()!.doubleValue!
        spectralType = iterator.next()!.stringValue
        colorIndex = iterator.next()?.floatValue
    }
    
    func messagePackValue() -> MessagePackValue {
        let pack = MessagePackValue(arrayLiteral:
                                    MessagePackValue(right_ascension),
                                    MessagePackValue(declination),
                                    hip_id.flatMap({ MessagePackValue($0) }) ?? MessagePackValue(),
                                    hd_id.flatMap({ MessagePackValue($0) }) ?? MessagePackValue(),
                                    hr_id.flatMap({ MessagePackValue($0) }) ?? MessagePackValue(),
                                    gl_id.flatMap({ MessagePackValue($0) }) ?? MessagePackValue(),
                                    bayer_flamstedt.flatMap({ MessagePackValue($0) }) ?? MessagePackValue(),
                                    properName.flatMap({ MessagePackValue($0) }) ?? MessagePackValue(),
                                    MessagePackValue(distance),
                                    MessagePackValue(pmra),
                                    MessagePackValue(pmdec),
                                    rv.flatMap({ MessagePackValue($0) }) ?? MessagePackValue(),
                                    MessagePackValue(mag),
                                    MessagePackValue(absmag),
                                    spectralType.flatMap({ MessagePackValue($0) }) ?? MessagePackValue(),
                                    colorIndex.flatMap({ MessagePackValue($0) }) ?? MessagePackValue())
        return pack
    }
}

extension Star: Packable {
    init(value: MessagePackValue) {
        var iterator = value.arrayValue!.makeIterator()
        dbID = Int32(iterator.next()!.integerValue!)
        normalizedAscension = iterator.next()!.floatValue!
        normalizedDeclination = iterator.next()!.floatValue!
        let starValue = StarData(value: iterator.next()!)
        starData = Box(starValue)
    }
    
    func messagePackValue() -> MessagePackValue {
        guard let value = starData?.value else {
            log.error("Failed to decode starData's value for star \(dbID)")
            return MessagePackValue()
        }
        let pack: MessagePackValue = [
            MessagePackValue(dbID),
            MessagePackValue(normalizedAscension),
            MessagePackValue(normalizedDeclination),
            value.messagePackValue()
        ]
        return pack
    }
}
