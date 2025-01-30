//
//  FreeLimitExplanationView.swift
//  FlowTale
//
//  Created by iakalann on 19/01/2025.
//

import SwiftUI

struct FreeLimitExplanationView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) { // TODO: Localize
                Text("You have reached your free limit of X chapters")
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
                Text("You have reached your free trial limit for creating chapters.")
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("Why is there a free trial limit?")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("The text to speech AI is really expensive.\nCreating the stories themselves is actually relatively cheap.\nHowever, the text to speech AI costs around 5-10p per chapter.\nAs a result, creating just 2 chapters costs around 20-80p.\nThis doesn't sound like a big deal, but if just 50 users joined the app every day, this would cost us around $200-$600 every month.\nApple sends us subscription payments after around 45 days or so, and so we have to make sure we can afford the costs until the subscription payments come through.\nWe've searched far and wide, but there are no cheaper alternatives for the text to speech AI that don't suck.")
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("Which chapters used up my free trial limit?")
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
