//
//  ChapterAudio.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import SwiftUI

public struct ChapterAudio: Codable, Equatable, Hashable {
    let data: Data
    
    public init(data: Data) {
        self.data = data
    }
}
