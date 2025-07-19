//
//  ImageGenerationServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

protocol ImageGenerationServicesProtocol {
    func generateImage(with prompt: String) async throws -> Data
}
