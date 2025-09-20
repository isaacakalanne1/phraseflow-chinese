//
//  CategoryResultTests.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
import Localization
@testable import Moderation
@testable import ModerationMocks

class ModerationCategoriesTests {

    @Test
    func sexual() {
        let category = ModerationCategories.sexual
        #expect(category.name == LocalizedString.moderationCategorySexual)
        #expect(category.key == "sexual")
        #expect(category.thresholdScore == 0.2)
    }

    @Test
    func sexualMinors() {
        let category = ModerationCategories.sexualMinors
        #expect(category.name == LocalizedString.moderationCategorySexualMinors)
        #expect(category.key == "sexual/minors")
        #expect(category.thresholdScore == 0.2)
    }

    @Test
    func violenceGraphic() {
        let category = ModerationCategories.violenceGraphic
        #expect(category.name == LocalizedString.moderationCategoryViolenceGraphic)
        #expect(category.key == "violence/graphic")
        #expect(category.thresholdScore == 0.2)
    }

    @Test
    func selfHarmIntent() {
        let category = ModerationCategories.selfHarmIntent
        #expect(category.name == LocalizedString.moderationCategorySelfHarmIntent)
        #expect(category.key == "self-harm/intent")
        #expect(category.thresholdScore == 0.2)
    }

    @Test
    func selfHarmInstructions() {
        let category = ModerationCategories.selfHarmInstructions
        #expect(category.name == LocalizedString.moderationCategorySelfHarmInstructions)
        #expect(category.key == "self-harm/instructions")
        #expect(category.thresholdScore == 0.2)
    }

    @Test
    func illicitViolent() {
        let category = ModerationCategories.illicitViolent
        #expect(category.name == LocalizedString.moderationCategoryIllicitViolence)
        #expect(category.key == "illicit/violent")
        #expect(category.thresholdScore == 0.2)
    }
}
