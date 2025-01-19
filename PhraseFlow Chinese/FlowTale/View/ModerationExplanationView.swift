//
//  ModerationExplanationView.swift
//  FlowTale
//
//  Created by iakalann on 19/01/2025.
//

import SwiftUI

struct ModerationExplanationView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) private var dismiss

    // Suppose your store holds the latest ModerationResponse in
    // `store.state.moderationResponse`.
    // Adjust as needed for your architecture.
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text("Your story didn't pass moderation")
                    .lineLimit(0)
                    .font(.title)
                    .fontWeight(.semibold)

                Text(store.state.settingsState.customPrompt)
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("What's moderation?")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("We check story ideas to make sure they align with our AI provider's usage policies.")
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("How does moderation work?")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("We check the story using confidence scores.\nThis is how confident the AI is that this content is within the story.\nIf your story is above an accepted confidence score for a category, it will not pass moderation.")
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text("Why didn't it pass?")
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
                                    Text("We accept below \(result.thresholdPercentageString)")
                                    Text("You scored \(result.scorePercentageString)")
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

            PrimaryButton(title: "Okay") {
                dismiss()
            }
        }
        .padding()
        .navigationTitle("Why?")
        .navigationBarTitleDisplayMode(.inline)
        .background(FlowTaleColor.background)
    }
}
