//
//  AnyKey.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Foundation

struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}
