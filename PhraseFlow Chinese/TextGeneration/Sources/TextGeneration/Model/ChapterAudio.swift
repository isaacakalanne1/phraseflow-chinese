//
//  ChapterAudio.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import SwiftUI

public struct ChapterAudio: Codable, Equatable, Hashable, Sendable {
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
}
