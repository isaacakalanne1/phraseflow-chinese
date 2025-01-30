//
//  DailyLimitExplanationView.swift
//  FlowTale
//
//  Created by iakalann on 19/01/2025.
//

import SwiftUI

struct DailyLimitExplanationView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) { // TODO: Localize
                Text("You have reached your daily limit of X chapters")
                    .lineLimit(0)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(store.state.settingsState.customPrompt)
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("What happened?")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("You have reached your daily limit for creating chapters.")
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("Why is there a daily limit?")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("The text to speech AI is really expensive.\nCreating the stories themselves is actually relatively cheap. However, the text to speech AI costs around 5-10p per chapter.\nThis sounds okay, but if a user simply creates 4 chapters a day, this would cost us $6-$12 per month, and we would lose money. If this was the case with too many users, even just a hundred, we would go bankrupt.\nHowever, we want the app to be as cool and fun as possible.\nAs a result, we've added daily limits where using it all up would actually cause us to make nearly zero profit. This is to give you the most value possible, while making sure we don't go into horrifying debt and have to take the app offline.\nWe've left some wiggle room to further reduce the chances of the finances going really bad, as the text to speech AI cost is different for every chapter, and is sort of unpredictable as a result. If you do some maths and work out that actually we could afford an extra chapter or two a day, this is the reason why.")
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("Which stories did I create today?")
                    .font(.title2)
                    .fontWeight(.medium)

                Divider()

                // Show each category’s pass/fail
                ScrollView {
                    if let moderationResponse = store.state.moderationResponse {
                        ForEach(moderationResponse.categoryResults.sorted(by: { !$0.didPass && $1.didPass })) { result in
                            HStack {
                                if result.didPass {
                                    Text("✅ \(result.category.name)")
                                        .foregroundColor(.green)
                                } else {
                                    Text("❌ \(result.category.name)")
                                        .foregroundColor(.red)
                                }

                                Spacer()

                                // Example text:
                                // "We accept below 80% | You scored 92%"
                                VStack(alignment: .trailing) {
                                    Text(LocalizedString.acceptanceThresholdExplanation("\(result.thresholdPercentageString)"))
                                         Text(LocalizedString.userScoreExplanation("\(result.scorePercentageString)"))
                                        .bold(!result.didPass)
                                }
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            }
                            .padding(.bottom)
                        }
                    }
                }
            }

            PrimaryButton(title: LocalizedString.okayButton) {
                dismiss()
            }
        }
        .padding()
        .navigationTitle(LocalizedString.navigationTitleWhy)
        .navigationBarTitleDisplayMode(.inline)
        .background(FlowTaleColor.background)
    }
}
