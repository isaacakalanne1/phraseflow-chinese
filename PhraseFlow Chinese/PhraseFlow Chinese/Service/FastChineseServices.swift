//
//  FastChineseService.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseServicesError: Error {
    case failedToGetResponseData
    case failedToEncodeJson
    case failedToDecodeJson
    case failedToDecodeSentences
}

protocol FastChineseServicesProtocol {
    func generateStory(categories: [Category]) async throws -> Story
    func generatePassage(using story: Story) async throws -> String
    func generateChapter(from passage: String) async throws -> Chapter
    func fetchDefinition(of character: String, withinContextOf sentence: String) async throws -> GPTResponse
}

final class FastChineseServices: FastChineseServicesProtocol {

    func generateStory(categories: [Category]) async throws -> Story {
        let subjects = Subject.allCases.map { $0.title }.shuffled()[0...2]
        let categoryTitles = categories.map { $0.title }
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: """
                  You are the greatest Mandarin Chinese storywriter alive, who takes great pleasure in creating Mandarin stories.
                  """),
            .init(role: "user",
                  content: """
        I would like you to create a story overview and summaries of 10 chapters for a deep and thought-provoking Mandarin Chinese novel.

        The story should begin with an ordinary setting and gradually lead into a complex plot that introduces profound conflicts and challenges. The plot should become deep and intense.

        Include these in the story:
        \(categoryTitles) \(subjects)

        Write the data in the following JSON format:
        { "storyOverview": "Story summary", "chapterSummaryList": ["List of descriptions for each chapter"] "difficulty": "HSK1", "title": "Story title in English", "description": "2 line story description, in English, which leaves the reader curious about where the plot will go" }
        Do not include the ```json prefix tag or or ``` suffix tag in your response.
        """)
        ])

        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let (data, _) = try await URLSession.shared.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data) else {
            throw FastChineseServicesError.failedToDecodeJson
        }

        guard let storyData = response.choices.first?.message.content.data(using: .utf8) else {
            throw FastChineseServicesError.failedToGetResponseData
        }

        do {
            let story = try JSONDecoder().decode(Story.self, from: storyData)
            return story
        } catch {
            throw FastChineseServicesError.failedToDecodeJson
        }
    }

    func generatePassage(using story: Story) async throws -> String {
        let initialPrompt = """
        You are the greatest Mandarin Chinese storywriter alive, who takes great pleasure in creating Mandarin stories. You write stories to help people learn Mandarin Chinese.
        Do not include any explaining statements before or after the story. Simply write the most amazing, engaging, suspenseful story possible.
        """

        let choice = Int.random(in: 0...2)
        var mainPrompt: String

        switch choice {
        case 0:
            mainPrompt = """
            You are an experienced novelist skilled in creating engaging and high-quality Mandarin Chinese stories.

            \(story.chapters.count == 0 ? "" : "Below are the previous chapters of the story \"\(story.title)\":")

            \(story.chapters.reduce("") { $0 + "\n\n" + $1.passage })

            Please generae the \(story.chapters.count == 0 ? "first" : "next") chapter, ensuring the following:

            1. **Plot Progression:** Advance the main plot logically and introduce subtle subplots if appropriate.
            2. **Character Development:** Deepen the characters' personalities, motivations, and relationships.
            3. **Descriptive Language:** Use vivid descriptions to bring settings and actions to life.
            4. **Dialogue:** Craft realistic and purposeful dialogue that reveals character traits and advances the story.
            5. **Pacing:** Maintain a balanced pace, incorporating moments of tension and relief.
            6. **Cliffhanger:** End the chapter with an intriguing event or question that compels the reader to continue.

            Ensure the writing style is consistent with previous chapters and maintains a captivating narrative flow.
        """
        case 1:
            mainPrompt = """
        You are a master storyteller known for crafting compelling and high-quality Mandarin Chinese narratives that keep readers hooked.

        \(story.chapters.count == 0 ? "" : "Given the previous chapters of the story \"\(story.title)\":")

        \(story.chapters.reduce("") { $0 + "\n\n" + $1.passage })

        Please write the \(story.chapters.count == 0 ? "first" : "next") chapter with the following objectives:

        - **Maintain High Quality:** Ensure the prose is polished, with rich descriptions and well-structured sentences.
        - **Enhance Engagement:** Introduce new developments that deepen the plot and characters.
        - **Build Suspense:** Incorporate elements that heighten tension and create anticipation for future events.
        - **Character Interaction:** Focus on meaningful interactions that reveal more about the characters and their dynamics.
        - **Narrative Hooks:** Include hooks or unresolved issues that encourage the reader to continue to the next chapter.

        Make sure the chapter flows seamlessly from the previous ones and upholds the story's overall tone and style.
        """
        case 2:
            mainPrompt = """
        As a seasoned author, you excel at creating high-quality and engaging Mandarin Chinese story chapters.

        \(story.chapters.count == 0 ? "" : "Here are the previous chapters of \"\(story.title)\":")

        \(story.chapters.reduce("") { $0 + "\n\n" + $1.passage })

        For the \(story.chapters.count == 0 ? "first" : "next") chapter, please ensure the following:

        1. **Conflict Introduction:** Introduce a new conflict or escalate an existing one to drive the story forward.
        2. **Character Arcs:** Show significant development or a turning point for key characters.
        3. **World-Building:** Expand on the story’s setting with detailed and immersive descriptions.
        4. **Emotional Depth:** Convey the characters' emotions effectively to connect with the reader.
        5. **Foreshadowing:** Plant subtle hints about future events or twists.
        6. **Engaging Ending:** Conclude the chapter with a moment that leaves the reader eager to find out what happens next.

        Maintain consistency in voice and style with the previous chapters to ensure a smooth narrative continuity.
        """
        default:
            mainPrompt = ""
        }

        mainPrompt.append("""
                Write the story using \(story.difficulty.title) vocabulary. Use only vocabulary for someone that is at this level, considering HSK1 is absolute beginner, like a 5 year old, and HSK5 is an absolute expert, like a PhD student.

                Feel free to use the same words often, in order to help the user learn the Mandarin words better.
        """)

        let response = try await makeRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt)
        guard let passage = response.choices.first?.message.content else {
            throw FastChineseServicesError.failedToGetResponseData
        }

        return passage
    }

    func generateChapter(from passage: String) async throws -> Chapter {
        let initialPrompt = """
        You are a Mandarin Chinese translator. You output only the expected story in JSON format, with each sentence split into entries in the list.
        You output no explaining text before or after the JSON, only the JSON.
        You output data in the following format: [ { "mandarin": "你好", "pinyin": ["nǐ", "hǎo"], "english": "Hello" }, { "mandarin": "谢谢", "pinyin": ["xiè", "xie"], "english": "Thank you" }, { "mandarin": "再见", "pinyin": ["zài", "jiàn"], "english": "Goodbye" } ]
        Do not nest JSON statements within each other. Ensure the list only has a depth of 1 JSON object.
        You are a master at pinyin and write the absolute best, most accurate tone markings for the pinyin, based on context, and including all relevant neutral tones.
        Separate each pinyin in the list into their individual sounds. For example, "níanqīng" would be separated into ["nían", "qīng"]
        Include punctuation in the pinyin, to match the Mandarin, such as commas, and full stops. The punctuation should be its own item in the pinyin list, such as ["nǐ", "，"]. Use Mandarin punctuation.
        Do not include the ```json prefix tag or or ``` suffix tag in your response.
        """

        let mainPrompt = """
        Split this story into the JSON format outlined above.
        This is the story:
        \(passage)
        """

        let response = try await makeRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt)
        guard let data = response.choices.first?.message.content.data(using: .utf8) else {
            throw FastChineseServicesError.failedToGetResponseData
        }

        do {
            let sentences = try JSONDecoder().decode([Sentence].self, from: data)
            let chapter = Chapter(passage: passage, sentences: sentences)
            return chapter
        } catch {
            throw FastChineseServicesError.failedToDecodeSentences
        }
    }

    func fetchDefinition(of character: String, withinContextOf sentence: String) async throws -> GPTResponse {
        let initialPrompt = "You are an AI assistant that provides English definitions for characters in Chinese sentences. Your explanations are brief, and simple to understand. You provide the pinyin for the Chinese character in brackets after the Chinese character. If the character is used as part of a larger word, you also provide the pinyin and definition for each character in this overall word. You never repeat the Chinese sentence, and never translate the whole of the Chinese sentence into English."
        let mainPrompt = "Provide a definition for \(character) in \(sentence)"
        let response = try await makeRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt)
        return response
    }

    private func makeRequest(initialPrompt: String, mainPrompt: String) async throws -> GPTResponse {

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestData = DefineCharacterRequest(messages: [
            .init(role: "system",
                  content: initialPrompt),
            .init(role: "user",
                  content: mainPrompt)
        ])

        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            throw FastChineseServicesError.failedToEncodeJson
        }

        let (data, _) = try await URLSession.shared.upload(for: request, from: jsonData)
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data) else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        return response
    }
}
