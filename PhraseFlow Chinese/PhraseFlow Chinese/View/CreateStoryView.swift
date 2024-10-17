//
//  CreateStoryView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 17/10/2024.
//

import SwiftUI

struct CreateStoryView: View {
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
                Text("Select Categories")
                    .font(.title2)

                HStack {
                    ForEach(Category.allCases, id: \.self) { category in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                store.dispatch(.updateSelectCategory(category,
                                                                     isSelected: !store.state.selectedCategories.contains(category)))
                            }
                        }) {
                            Text(category.title)
                                .font(.body)
                                .foregroundColor(store.state.selectedCategories.contains(category) ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(store.state.selectedCategories.contains(category) ? Color.accentColor : Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
                }

                Button(action: {
                    withAnimation(.easeInOut) {
                        store.dispatch(.generateNewStory(categories: store.state.selectedCategories))
                    }
                }) {
                    Text("Create Story")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            }
            .toolbar(.hidden)
            .padding(.horizontal)
        }
    }

}
