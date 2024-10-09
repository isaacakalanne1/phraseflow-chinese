//
//  SettingsView.swift
//  FastChinese
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

                Text("Choose Speech Speed")
                    .font(.title2)

                HStack {
                    ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                store.dispatch(.updateSpeechSpeed(speed))
                            }
                        }) {
                            Text(speed.title)
                                .font(.body)
                                .foregroundColor(store.state.speechSpeed == speed ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(store.state.speechSpeed == speed ? Color.accentColor : Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
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
