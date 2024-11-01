//
//  StorySetting.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 01/11/2024.
//

import Foundation

enum StorySetting: CaseIterable {
    case ancientChina, modernCity, futuristic

    var name: String {
        switch self {
        case .ancientChina:
            "Ancient\nChina"
        case .modernCity:
            "Modern\nCity"
        case .futuristic:
            "Futuristic"
        }
    }

    var imageUrl: URL? {
        switch self {
        case .ancientChina:
            URL(string: "https://www.thoughtco.com/thmb/vvHe7ZbuukBD4M2gwJlVhDCQIdA=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/view-of-great-wall-china-93199461-59cc049a03f4020011c1608c.jpg")
        case .modernCity:
            URL(string: "https://cdn-v2.theculturetrip.com/1200x630/wp-content/uploads/2021/12/dbxhkt_hong-kong-sar-china--sean-pavone-alamy-stock-photo.webp")
        case .futuristic:
            URL(string: "https://easy-peasy.ai/cdn-cgi/image/quality=80,format=auto,width=700/https://fdczvxmwwjwpwbeeqcth.supabase.co/storage/v1/object/public/images/991c1741-5d23-42a0-bd8a-2b6a0a236a72/101f76cd-a739-4819-a577-50603c235be8.png")
        }
    }
}
