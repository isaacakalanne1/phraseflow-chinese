//
//  FlowTaleRepositoryProtocol.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Foundation
import StoreKit

protocol FlowTaleRepositoryProtocol {
    func synthesizeSpeech(_ chapter: Chapter,
                          voice: Voice,
                          language: Language) async throws -> (Chapter, Int)
    func getProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws
    func validateAppStoreReceipt()
}
