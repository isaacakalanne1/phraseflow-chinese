//
//  CreateStoryState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct CreateStoryState {
    var selectedGenres: [Genre]
    var selectedStorySetting: StorySetting?

    init(selectedGenres: [Genre] = [],
         selectedStorySetting: StorySetting? = nil) {
        self.selectedGenres = selectedGenres
        self.selectedStorySetting = selectedStorySetting
    }
}
