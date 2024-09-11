//
//  SettingsView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 11/09/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: FastChineseStore

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Text("Choose Phrases to Learn")
                    .font(.title2)

                NavigationLink(destination: PhraseListView(viewModel: viewModel, category: .short)) {
                    Text("Short")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: 100)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }

                NavigationLink(destination: PhraseListView(viewModel: viewModel, category: .medium)) {
                    Text("Medium")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: 100)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }

                NavigationLink(destination: PhraseListView(viewModel: viewModel, category: .long)) {
                    Text("Long")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: 100)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.bottom)

                Text("Choose Speech Speed")
                    .font(.title2)

                HStack {

                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.speechSpeed = .slow
                        }
                    }) {
                        Text("Slow")
                            .font(.body)
                            .foregroundColor(viewModel.speechSpeed == .slow ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.speechSpeed == .slow ? Color.accentColor : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.speechSpeed = .normal
                        }
                    }) {
                        Text("Normal")
                            .font(.body)
                            .foregroundColor(viewModel.speechSpeed == .normal ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.speechSpeed == .normal ? Color.accentColor : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.speechSpeed = .fast
                        }
                    }) {
                        Text("Fast")
                            .font(.body)
                            .foregroundColor(viewModel.speechSpeed == .fast ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.speechSpeed == .fast ? Color.accentColor : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }

                Text("Choose Mode")
                    .font(.title2)

                HStack(spacing: 10) {
                    modeButton("Reading", mode: .readingMode)
                    modeButton("Writing", mode: .writingMode)
                    modeButton("Listening", mode: .listeningMode)
                }

                Text("Settings")
                    .font(.title2.bold())
                    .padding(.vertical)
            }
            .toolbar(.hidden)
            .padding(.horizontal)
        }
    }

}
