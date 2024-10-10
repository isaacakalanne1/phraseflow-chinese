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

        let showPinyin: Binding<Bool> = .init {
            store.state.isShowingPinyin
        } set: { newValue in
            store.dispatch(.updateShowPinyin(newValue))
        }

        let showMandarin: Binding<Bool> = .init {
            store.state.isShowingMandarin
        } set: { newValue in
            store.dispatch(.updateShowMandarin(newValue))
        }

        let showEnglish: Binding<Bool> = .init {
            store.state.isShowingEnglish
        } set: { newValue in
            store.dispatch(.updateShowEnglish(newValue))
        }


        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Toggle("Show Pinyin", isOn: showPinyin)
                Toggle("Show Mandarin", isOn: showMandarin)
                Toggle("Show English", isOn: showEnglish)

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
