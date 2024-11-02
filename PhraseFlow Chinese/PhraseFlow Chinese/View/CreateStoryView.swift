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
                        ForEach(Genre.allCases, id: \.self) { genre in
                            CategoryButtonView(category: genre,
                                               isHighlighted: store.state.selectedGenres.contains(genre)) {
                                store.dispatch(.updateSelectGenre(genre,
                                                                  isSelected: !store.state.selectedGenres.contains(genre)))
                            }
                        }
                    }
                }

                Text("Setting")
                    .fontWeight(.light)
                    .greyBackground()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(StorySetting.allCases, id: \.self) { setting in
                            CategoryButtonView(category: setting,
                                               isHighlighted: store.state.selectedStorySetting == setting) {
                                store.dispatch(.selectStorySetting(store.state.selectedStorySetting == setting ? nil : setting))
                            }
                        }
                    }
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut) {
                        store.dispatch(.generateNewStory(genres: store.state.selectedGenres))
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
