//
//  TranslatorView.swift
//  Translation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import SwiftUI

public struct TranslatorView: View {
    private let environment: TranslationEnvironmentProtocol

    public init(environment: TranslationEnvironmentProtocol) {
        self.environment = environment
    }
    
    public var body: some View {
        TranslationRootView(environment: environment)
    }
}
