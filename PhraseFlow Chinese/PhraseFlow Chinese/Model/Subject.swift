//
//  Subject.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 17/10/2024.
//

import Foundation

enum Subject: String, CaseIterable {
    case cats, dogs, river, house, city, suburbs, pen, chocolate, cleaner, cooking, holiday, rain, sunshine, painting, sport

    var title: String {
        rawValue.uppercased()
    }
}
