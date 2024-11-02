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

        NavigationView {
            VStack {
                Text("Create Story")
                    .bold()
                    .padding(.top, 20)
                Text("Genre")
                    .fontWeight(.light)
                    .greyBackground()

                ScrollView(.horizontal, showsIndicators: false) {
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
                }

                Text("Setting")
                    .fontWeight(.light)
                    .greyBackground()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(StorySetting.allCases, id: \.self) { setting in
                            CategoryButtonView(imageUrl: setting.imageUrl,
                                               title: setting.name,
                                               isHighlighted: store.state.selectedStorySetting == setting) {
                                store.dispatch(.selectStorySetting(store.state.selectedStorySetting == setting ? nil : setting))
                            }
                        }
                    }
                }

                Spacer()

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
