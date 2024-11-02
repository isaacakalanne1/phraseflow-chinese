//
//  Genre.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 17/10/2024.
//

import Foundation

enum Genre: String, CaseIterable, Categorisable {
    case romance, adventure, action, historical

    var title: String {
        rawValue.capitalized
    }

    var imageUrl: URL? {
        let urlString: String
        switch self {
        case .romance:
            urlString = "https://i.pinimg.com/736x/cb/9a/8a/cb9a8ac5113621f290110b5dfd74ae8c.jpg"
        case .adventure:
            urlString = "https://i.pinimg.com/236x/f4/26/8f/f4268f81a7ecda69b82fa4133d31fdfd.jpg"
        case .action:
            urlString = "https://www.shutterstock.com/image-photo/man-professional-motorcyclist-full-moto-600nw-2303322993.jpg"
        case .historical:
            urlString = "https://image.jimcdn.com/app/cms/image/transf/dimension=1040x10000:format=jpg/path/s2217cd0bb1220415/image/ia4cd080af21ba896/version/1717730739/ancient-greek-polis.jpg"
        }
        return URL(string: urlString)
    }
}
