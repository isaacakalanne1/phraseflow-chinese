//
//  String+Pinyin.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 11/09/2024.
//

import Foundation

extension String {
    func getPinyin() -> String {
        let mutableString = NSMutableString(string: self)
        // Transform to Pinyin with tone marks
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        return mutableString as String
    }

}
