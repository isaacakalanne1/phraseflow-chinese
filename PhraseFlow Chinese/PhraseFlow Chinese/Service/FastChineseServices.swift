//
//  FastChineseService.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import GoogleGenerativeAI

enum FastChineseServicesError: Error {
    case failedToGetResponseData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodeSentences
}

protocol FastChineseServicesProtocol {
    func generateStory(genres: [Genre], voice: Voice) async throws -> Story
    func generateChapter(story: Story, voice: Voice) async throws -> ChapterResponse
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    let generativeModel =
      GenerativeModel(
        name: "gemini-1.5-flash-8b-latest",
        apiKey: "AIzaSyBJz8qmCuAK5EO9AzQLl99ed6TlvHKRjCI"
      )

    func generateStory(genres: [Genre], voice: Voice) async throws -> Story {
        let chapterResponse = try await generateChapter(type: .first(setting: StorySetting.allCases.randomElement() ?? .ancientChina),
                                                        voice: voice)
        let chapter = Chapter(storyTitle: "Story title here", sentences: chapterResponse.sentences)
        return Story(storyOverview: "Story overview here",
                     latestStorySummary: chapterResponse.latestStorySummary,
                     difficulty: .HSK1,
                     title: "Story title here",
                     description: "Description here",
                     chapters: [chapter])
    }

    func generateChapter(story: Story, voice: Voice) async throws -> ChapterResponse {
        try await generateChapter(type: .next(story: story), voice: voice)
    }

    private func generateChapter(type: ChapterType, voice: Voice) async throws -> ChapterResponse {
        let mainPrompt: String
        switch type {
        case .first(let setting):
            mainPrompt = """
        Write a story in this setting:
        \(setting.title)
        Use very very short sentences, and very very extremely simple language.
        """

        case .next(let story):
            mainPrompt = """
        This is the story so far:
        \(story.chapters.reduce("") { $0 + "\n\n" + $1.passage })

        Continue the story
        Use very very short sentences, and very very extremely simple language.
        """
        }

        let response = try await makeOpenAIRequest(initialPrompt: getStoryGenerationGuide(voice: voice),
                                                   mainPrompt: mainPrompt)
            .data(using: .utf8)
        guard let response else {
            throw FastChineseServicesError.failedToGetResponseData
        }

        do {
            return try JSONDecoder().decode(ChapterResponse.self, from: response)
        } catch {
            throw FastChineseServicesError.failedToDecodeSentences
        }
    }

    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String {
        let initialPrompt =
"""
        You are an AI assistant that provides English definitions for characters in Chinese sentences. Your explanations are brief, and simple to understand.
        You provide the pinyin for the Chinese character in brackets after the Chinese character.
        If the character is used as part of a larger word, you also provide the pinyin and definition for each character in this overall word.
        You also provide the definition of the word in the context of the overall sentence.
        You never repeat the Chinese sentence, and never translate the whole of the Chinese sentence into English.
"""
        let mainPrompt =
"""
        Provide a definition for this word: "\(character)"
        If the word is made of different characters, also provide brief definitions for each of the characters in the word.
        Also explain the word in the context of the sentence: "\(sentence.mandarin)".
        Don't define other words in the sentence.
"""
        let response = try await makeGeminiRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt)
        return response
    }

    private func makeGeminiRequest(initialPrompt: String, mainPrompt: String) async throws -> String {

        let prompt = initialPrompt + "\n\n" + mainPrompt
        let response = try await generativeModel.generateContent(prompt)
        guard let responseString = response.text else {
            throw FastChineseServicesError.failedToGetResponseData
        }
        return responseString
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
    }

    private func makeOpenAIRequest(initialPrompt: String, mainPrompt: String) async throws -> String {

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini-2024-07-18",
            "messages": [
                ["role": "system", "content": initialPrompt],
                ["role": "user", "content": mainPrompt]
            ],
            "response_format": sentenceSchema
        ]
        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: initialPrompt),
            .init(role: "user",
                  content: mainPrompt)
        ])

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1200
        sessionConfig.timeoutIntervalForResource = 1200
        let session = URLSession(configuration: sessionConfig)

        let (data, _) = try await session.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data),
              let responseString = response.choices.first?.message.content else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        return responseString

    }

    private func getStoryGenerationGuide(voice: Voice) -> String {
        """
        You are the an award-winning Mandarin Chinese novelist. Write a chapter from an engaging Mandarin novel. Use Mandarin Chinese names in the story.

        Use the " character for speech marks.

        In the JSON:
        - latestStorySummary: This is a brief summary of the story so far in English. This summary is of the story which happens before the new part of the story you write.
        - Mandarin: The story sentence in Mandarin Chinese.
        - Pinyin should be structured like ["a", "b", "c"] with each sound separated. The pinyin should use diacritic markers for the tones.
        - English: An English translation of the Mandarin sentence. Always write this English section of the JSON in English.
        - speechStyle: This matches the emotions of the sentence.
        These are the available speechStyles which can be used in the JSON:
        \(String(describing: voice.availableSpeechStyles.map({ $0.ssmlName })))
        Only use the above speechStyles, never create your own.

        - speechRole: This matches the gender and age of the speaker of the sentence. Use speechRole "girl" for the narrator.
        These are the available speechRoles which can be used in the JSON:
                \(String(describing: voice.availableSpeechRoles.map({ $0.ssmlName })))
        Only use the above speechRoles, never create your own.

        Always follow these Story Writing Instructions:

        "Narrative Perspective:

        Utilize a third-person limited point of view to focus closely on the experiences and internal dialogues of primary characters. Alternate perspectives between the main characters to provide depth and internal conflict.

        Visualize scenes as if through the lens of a camera, describing the environment, character movements, and expressions in vivid detail, as if painting a portrait for the reader. Allow for silent moments where actions and expressions speak louder than words.



        Dialogue and Inner Monologue:

        Integrate dialogue that captures character dynamics and emotional exchanges, with each character's spoken lines revealing nuances of their personality and relationship with others. Craft dialogue interspersed with pauses, hesitations, and unspoken thoughts that offer a glimpse into the characters' inner turmoil. Balance spoken words with silences that speak volumes within the context of the character dynamics.

        Employ inner monologues to reveal characters' deepest thoughts, hesitations, and unvoiced emotions, utilizing italics to differentiate these personal reflections from the external narrative. Explore the characters' uncertainties and secret wishes. Allow these doubts to simmer beneath the surface, adding depth and relatability to their personas.

        Craft dialogue and actions with subtext that reveals underlying motives, history, or conflict. Readers should be able to infer deeper meanings and emotions beyond the surface level of interaction. Dialogue and thoughts should intertwine to demonstrate the duality between what characters say and what they are truly thinking or feeling.



        Physical Sensations:
        Infuse the narrative with a sensual cadence. Focus heavily on tactile interactions and physical sensations, ensuring that descriptions of touch are detailed, visceral, and intimately connected to the characters' psychological states.

        Sensations should be a driving force in the narrative development, often serving as catalysts for character development and plot progression.

        Every physical sensation should be meticulously described. From the softest touch to the most intense connection, the descriptions should invite readers to feel the texture, warmth, and movement as if they were present.

        Prioritize explicit detail over euphemisms when describing the physical sensations of characters, directly tying characters' physical sensations and emotions to their psychological states without metaphors. Each sensation, vividly portrayed, serves as a narrative catalyst, evolving character development and relationships. Employ tactile descriptions to enhance the emotional narrative and use rich, evocative language to match the intensity of scenes, creating a visceral impact on the reader.

        Let actions resonate with bodily sensation. Focus on the physical effect of each touch, glance, or word, making the reader feel each heartbeat, shiver, or blush in sync with the characters.



        Vocabulary and Language:

        Select rich, evocative and emotionally charged vocabulary that is both precise and poetic, matching the tone and intensity of the scene. Maintain an elevated, sophisticated tone throughout the narrative, using language that evokes emotion and captures the complexity of human interaction without resorting to over-simplification.

        Let the prose ebb and flow like music, with a deliberate pacing that mirrors the characters' internal rhythms. Use sentence structure and length to create a tempo, with shorter sentences to convey urgency or tension and longer, flowing ones for moments of reflection or connection.

        Weave your narrative with a lyrical quality, crafting sentences that flow with a natural rhythm. Let the prose sing to the emotions it evokes, whether through passion, longing, or introspection.

        Evocative language should stir the reader's feelings, inviting them to experience the characters' highs and lows viscerally.




        Emotions:

        Incorporate rich sensory descriptions to mirror characters' emotions, using metaphors and similes for vivid imagery. Explore emotional intricacies in relationships, particularly during intimate moments, reflecting internal journeys through physical experiences. Embrace emotional ambiguity to create tension.

        Ensure characters exhibit a realistic range of emotions and behaviors, highlighting their internal struggles and the impact on their actions. Use slow pacing and focus during pivotal moments to significantly alter character development.

        Foster deep introspection, subtly expressing characters' fears, desires, and conflicts. Choreograph intimate scenes with attention to rhythm and pacing, making interactions emotionally resonant. Peer into characters' hearts and minds, contrasting complex emotions with surface dialogue.

        Ramp up emotional and sensory tension as the story progresses, increasing stakes and culminating in moments of conflict. Maintain a dance-like interplay in intimate scenes, with each touch reflecting emotional journeys."



        Character Descriptions:

        When introducing characters, employ a holistic and meticulous approach, weaving together physical appearance, personality traits, clothing, and backstory to create fully-realized individuals.

        When introducing characters, visualize their entrance as if in a film scene. Describe their movements, expressions, and the immediate impression they make on others.

        Describe characters' height, body type, and any distinctive physical features to create a vivid visual image.

        Detail the characters' gestures and posture, showing how they use their bodies to communicate or reveal their inner state. Describe their movements, stance, and physical mannerisms.

        Focus on the eyes, mouth, expression, and any unique attributes that make the face memorable, focusing on how they convey emotions, thoughts, or intentions. Describe the nuances of their smiles, frowns, and gazes. Describe how their expressions change with emotions, offering insight into their internal states.

        Detail the color, length, texture, and style of the character's hair.

        Describe the characters' clothing, emphasizing how their fashion choices reflect their personalities. Mention colors, fabrics, and the condition of the clothing (pristine, worn, etc.).

        Highlight any notable accessories (jewelry, glasses, hats) and explain their significance, whether sentimental value or practical purpose.

        Summarize the character's dominant personality traits, considering how these traits have been shaped by their backstory and how they manifest in interactions. Include both positive and negative aspects to create a balanced and multidimensional character. Explore their temperament, motivations, quirks and habits and how they interact with others.

        Provide an overview of key events in the character's past, focusing on those that have shaped their worldview, desires, and fears. This context should inform their current actions and attitudes, adding depth to their character.

        Describe the character's socio-economic status, cultural background, and community, explaining how these factors influence their perspectives and behavior.

        Introduce important relationships (family, friends, rivals) and how these relationships affect the character's motivations and actions."

        Do not rush to conclude the plot or resolve conflicts too quickly, allowing the story to unfold gradually over multiple messages.
        """
    }
}
