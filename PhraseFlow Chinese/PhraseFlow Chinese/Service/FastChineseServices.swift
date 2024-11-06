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
    func generateChapter(previousChapter: Chapter, voice: Voice) async throws -> ChapterResponse
    func fetchDefinition(of character: String, withinContextOf sentence: Sentence) async throws -> String
}

final class FastChineseServices: FastChineseServicesProtocol {

    let storStructureGuide = """
        Story structure is an essential element of any book—whether you’re a fiction writer, photographer, or even cookbook author. It is the way storytellers create a path for their narrative, with its peaks and valleys, twists and turns. It’s what makes stories memorable.

        Story structure helps guide your audience from the beginning to the end of your book by introducing characters and settings, setting up the conflict, developing the main plot points, and finally resolving that conflict. It also helps create tension, suspense, and surprise—essential components of almost any story.

        Most people think of structuring only novels or documentary photo books, but all the most engaging and cohesive books take structure seriously. For example, a portfolio may feel like a collection of your best stand-alone work. But, you’re weaving a tale of your journey as an artist, photographer, or designer—and telling the story of who you are professionally. Cookbooks are another great example—you must take your readers through a narrative of thematically connected, delicious recipes and why the reader should care.

        Of course, you’re here because you know the power of story structure—so let’s dive in.

        Definition of story structure
        As the sequence and backbone of your book, story structure is the order in which you present the narrative. The linear storyline shapes the flow of events (rising action, climax, and resolution) while establishing the book’s setting and plot.

        Before we get into the different story archetypes and narrative types, there are a few fundamental structural elements worth learning. While these are most often used to describe written storytelling, you can easily use this structure to push a visually-driven story along. They include:

        Opener
        The opener establishes your story’s setting, premise, plot, and character roles. A compelling opener teases readers with what challenges or conflicts are ahead.

        Incident
        Stage two is the story’s incident. As the catalyst or instigating force that compels your main character to act, the incident establishes the conflict that sets the stage for the third phase of a story’s structure.

        Crisis
        As a consequence of the incident, the story’s crisis is an unfolding of the primary conflict or series of issues. A crisis must be realistic and related to the plot. If the character experiences more than one crisis, each should build on the last, heightening the sense of danger and tension.

        Climax
        Stage four is the climax or the height of the crisis. Depending on your perspective, you can also think of the climax as the bottom of your action. At this stage, the character has hit rock bottom in the storyline–hopeless and seemingly out of options. The climax is not the end of the book but the beginning of the end.

        Ending
        The final stage of the story structure is the ending or close. Success or failure are both valid outcomes, but the ending should provide a conclusion and resolution to your story. The ending should close the loop on all crises, plot twists, and loose ends but could also leave the reader wanting more.

        Christopher Booker’s seven story archetypes
        Now that you know the basics of a story structure sequence, let’s look at another structural aspect that can help shape your book. A story archetype is a basic plot focusing on the type of journey the story takes, and the obstacles characters overcome.

        As defined by scholar Christopher Booker, all stories and character arcs fall under seven main story archetypes.

        Overcoming the Monster
        This is an underdog story where the main character sets out to destroy a greater evil of some kind. Examples include Beowulf, Jaws, and David & Goliath.

        Rags to Riches
        In this classic plot line, the primary character begins in a situation of poverty or despair and rises to a higher status of wealth and success. You’ll recognize it from Jane Eyre, The Ugly Duckling, and Cinderella.

        The Quest
        A story archetype that takes many shapes, The Quest is a plot where a hero embarks on a journey to discover something and eventually finds success through trials and tribulations. Find it in classics like The Lord of the Rings, The Odyssey, and the more recent Finding Nemo.

        Voyage and Return
        In this definitive story type, a protagonist starts on a journey into foreign territory and encounters adversity before eventually returning home. Alice in Wonderland, The Hobbit, and The Chronicles of Narnia are beloved examples.

        Comedy
        Contrary to what we might typically view as humor, the comedy story archetype is a plot in which destiny brings the protagonist and love interest together, but conflicting forces keep them apart. Find it in Pride & Prejudice, A Midsummer Night’s Dream, and Carry on Jeeves.

        Tragedy
        In this story type, the protagonist has a major flaw or makes a huge mistake—this leads to their inevitable undoing. During the story, we watch as they unravel and fall. You’ll see it show up well in The Picture of Dorian Gray, Anna Karenina, and Macbeth.

        Rebirth
        Here the protagonist falls under the spell or hypnosis of darkness and eventually redeems themself as the story unfolds. A Christmas Carol, Beauty & The Beast, and The Secret Garden are ideal examples.

        In addition to writing stories, these archetypes can also apply to filmmaking and photography. For example, a great photography book tells a story and takes the viewer on the same narrative arc or adventure.

        11 different narrative story structure types
        Beyond Christopher Booker’s story archetypes discussed above, the collective writing community has established several different story structure types over many centuries. Although many share common traits and overlap in sequence steps, each helps guide a story’s style, flow, and structure.

        To know which story structure type best aligns with your book and its narrative, below we discuss eleven of the most common narrative story structure types.

        The Classic Story Structure
        The Classic Story Structure, also known as narrative structure or dramatic structure, has been a standard format used for many centuries in visual stories and novels. This structure’s seven main parts include the exposition, rising action, climax, falling action, resolution, dénouement, and themes.

        While most of these elements are self-explanatory, and based on conventional story structures, the last two are slightly more unique. The dénouement unveils the main character’s long-term consequences, and the theme is the story’s underlying message. The Classic Story Structure has considerable overlap with other story structure types and is often viewed as an umbrella type to describe general fiction story structure.

        The Hero’s Journey
        Typically consisting of three distinct stages (departure, initiation, and return), The Hero’s Journey is a common narrative type that involves a series of eleven steps that storytellers can present in a flexible and adaptable way. Often seen in comic books and graphic novels, this structure is fantastic for visual storytelling.

        These steps include the call to adventure, refusal of the call, meeting a mentor, crossing the threshold, facing enemies and adversity, building up to the climax, facing the climatic ordeal, receiving the reward, returning to the ordinary world, undergoing transformation, and disseminating the newfound wisdom.

        The Three-Act Structure
        The Three-Act Structure is one of the most common narrative story structures that divides a story into three main parts: the Setup, the Confrontation, and the Resolution.

        The First Act (Setup): This act sets the stage by introducing the main character, their relationships, the world they live in, and the initial conflict.
        The Second Act (Confrontation): As the heart of the story, this act is a turning point that involves the main character encountering increasing challenges and obstacles as they work to resolve climactic challenges.
        The Third Act (Resolution): This final act brings the story to a close, resolving the conflict and tying up loose ends. The third act reveals the consequences and outcomes of the character’s actions.
        A popular storytelling format used across many photo books, comic strips, novels, plays, and films, the Three-Act Structure helps provide a clear and concise way of structuring the events of a story.

        The Seven-Point Structure
        As a more detailed extension of the Three-Act Structure above, using the Seven-Point Structure breaks a story down into more segmented and granular components for storytelling. These parts include the following:

        Hook
        Set-up
        Catalyst
        Debate
        Break into Two
        Confrontation
        Resolution
        The Seven-Point Structure is a traditional story structure that is helpful for writers looking to craft a compelling and engaging narrative.

        The Snowflake Method
        The Snowflake Method is a ten-step writing process designed to help writers expand upon ideas into a complete story. Developed by author Randy Ingermanson, the Snowflake Method guides a story’s structure and direction before actually beginning the writing process. The steps include the following:

        Start by writing a single-sentence summary of the story’s overarching premise.
        Elaborate that single sentence into a full paragraph that describes the story in greater detail.
        Expand the paragraph into a one-page story synopsis.
        Construct a character chart of the story’s main characters and their roles.
        Write a single sentence that describes each scene of the story.
        For each scene sentence, compose a paragraph that adds greater detail about the scene’s events.
        Write a complete chapter for each significant scene.
        Complete a full draft of the story.
        Revise the story’s draft as needed.
        Edit the story and its structure, and organize the flow to be most engaging.
        The Snowflake Method encourages substantial planning and organizing of the story, helping writers ensure that they have a solid foundation to avoid getting stuck in the middle of their story writing.

        The Five-Act Structure
        The Five-Act Structure is a familiar story structure used across many tales that helps organize key events throughout your book. It’s also the most easily adaptable for visual storytellers, like photographers, graphic designers, and illustrators looking to build a book.

        As a hybrid between the Three-Act Structure, Seven-Point Structures, and Christopher Booker’s archetypes, the five acts include:

        Introduction
        Rising Action
        Climax
        Falling Action
        Resolution
        This type of story structure helps maintain a narrative that’s both engaging and well-paced for your audience. And for storytellers, The Five Act Structure provides a simple roadmap that clearly segments the story into distinct parts for story development.

        Two doors side by side, one blue, one green
        A Disturbance and Two Doors
        This narrative structure is a simple yet powerful way to create tension in a story. Common in fantasy and science fiction genres, a Disturbance and Two Doors involves a situation in which the character faces a conflict (or disturbance) and is given two possible solutions (doors to take).

        Each solution involves two vastly different realities that can shape how the story unfolds. Once the protagonist chooses a door, the consequences of their decision carry out into the eventual climax until the story reaches a resolution.

        The Story Circle
        A narrative structure used in drama, fantasy, science fiction, and mystery genres, the Story Circle is based on the protagonist traveling through an eight-stage circular model. The stages involve the character:

        In their familiar world or comfort zone
        Experiencing a desire to need or want something
        Entering an unfamiliar situation
        Adapting to the situation
        Obtaining the object of desire
        Paying the price for it
        Returning to their familiar world with newly-acquired knowledge or power
        Applying that knowledge or power
        Similar to the Hero’s Journey and widely used in screenwriting and storytelling, the Story Circle provides a framework for structuring an engaging story with a clear and balanced sense of direction and purpose.

        A story arch depicted as a wave, starting low with exposition, then rising action, cresting with the climax, falling action, and lastly the resolution
        Freytag’s Pyramid
        Inspired by German playwright Gustav Freytag in the 19th century, Freytag’s Pyramid is a simple paradigm that maps the dramatic story structure into five points that make up a pyramid. This includes the exposition (lowest left), rising action (left middle), climax (highest pinnacle), falling action (right middle), and resolution (lowest right).

        Freytag’s Pyramid works well for dramatic storytelling, where the protagonist faces significant obstacles and must overcome challenges to reach their goal. However, it’s also used in other types of story genres and has seen evolved iterations that include more descriptive seven stages of the story pyramid.

        Inciting incident
        The Inciting Incident centers around a single, unexpected event that sets the protagonist on a journey away from their typical life. This event, known as the inciting incident, disrupts the protagonist’s status quo and commences the story’s adventure. The core stages of this story structure type include the:

        Status quo
        Inciting incident
        Response
        Journey
        Climax
        Resolution
        Compared to other story structure types, the inciting incident is the core element that sparks a catalyst for change by upsetting the character’s status quo and triggering the story’s journey. This structure is fantastic when used in documentary photo books—where a single event is explored visually.

        Fichtean Curve
        Based on the work of German philosopher Johann Gottlieb Fichte, the Fichtean Curve is a narrative structure that’s centered around a protagonist’s story of self-discovery and perpetual conflict. The story’s rising action is a series of crises the protagonist must overcome, thereby building tension until they reach the climax.

        Often characterized by a story of constant ups and downs, the Fichtean Curve is a gripping story structure used across many genres and formats, including film.

        Someone typing on a laptop, writing a story
        Adding story structure to your book
        As we’ve seen, you can use many different story structure types to guide the creation of your self-published book. From Freytag’s Pyramid to the Fichtean Curve, these structures provide a clear and practical framework for telling a compelling story.

        You can create a story with a precise balance of pacing and tension, impact and engagement, well-developed characters and themes, and a satisfying resolution when you follow a structured narrative or story archetype.
        """

    let generativeModel =
      GenerativeModel(
        name: "gemini-1.5-flash-8b-latest",
        apiKey: "AIzaSyBJz8qmCuAK5EO9AzQLl99ed6TlvHKRjCI"
      )

    func generateStory(genres: [Genre], voice: Voice) async throws -> Story {
        let chapterResponse = try await generateChapter(type: .first(setting: StorySetting.allCases.randomElement() ?? .ancientChina),
                                                        voice: voice)
        let chapter = Chapter(storyTitle: chapterResponse.storyTitle, sentences: chapterResponse.sentences)
        return Story(storyOverview: "Story overview here",
                     latestStorySummary: chapterResponse.latestStorySummary,
                     difficulty: .HSK1,
                     title: chapterResponse.storyTitle,
                     description: "Description here",
                     chapters: [chapter])
    }

    func generateChapter(previousChapter: Chapter, voice: Voice) async throws -> ChapterResponse {
        try await generateChapter(type: .next(previousChapter: previousChapter), voice: voice)
    }

    private func generateChapter(type: ChapterType, voice: Voice) async throws -> ChapterResponse {
        let initialPrompt = """
        You are the an award-winning Mandarin Chinese novelist. Write a chapter from an engaging Mandarin novel.
        Do not include any explaining statements before or after the story. Simply write the most amazing, engaging, suspenseful story possible.
        You output only the expected story in JSON format, with each sentence split into entries in the list.
        You output no explaining text before or after the JSON, only the JSON.
        You output data in the following format:
        {
            "sentences": [
                {
                    "sentenceIndex": 0,
                    "mandarin": "你好",
                    "pinyin": ["nǐ", "hǎo"],
                    "english": "Hello",
                    "speechStyle": "Speech style based on Mandarin sentence"
                },
                {
                    "sentenceIndex": 1,
                    "mandarin": "谢谢",
                    "pinyin": ["xiè", "xie"],
                    "english": "Thank you",
                    "speechStyle": "speech style based on Mandarin sentence"
                },
                {
                    "sentenceIndex": 2,
                    "mandarin": "再见",
                    "pinyin": ["zài", "jiàn"],
                    "english": "Goodbye",
                    "speechStyle": "speech style based on Mandarin sentence"
                }
            ],
            "storyTitle": "Short story title in English. Create a short title if no title is provided below",
            "latestStorySummary": "Suspenseful short teaser description of the story so far, which makes the reader want to read the above chapter."
        }
        Always use "lyrical" for third-person text. Only use other speech styles when a character is speaking, not for describing a character's feeling or such.
        For describing a character's feelings, still use "lyrical".
        Do not nest JSON statements within each other. Ensure the list only has a depth of 1 JSON object.
        Separate each pinyin in the list into their individual sounds. For example, "níanqīng" would be separated into ["nían", "qīng"]
        Include punctuation in the pinyin, to match the Mandarin, such as commas, and full stops. The punctuation should be its own item in the pinyin list, such as ["nǐ", "，"]. Use Mandarin punctuation.
        Do not include the ```json prefix tag or or ``` suffix tag in your response.
        """

        let mainPrompt: String
        switch type {
        case .first(let setting):
            mainPrompt = """
        Write the first chapter of an engaging Mandarin novel.
        The reader should be amazed an AI came up with it.
        Use vocabulary a 5 year old child could understand.
        The chapter should be 20 sentences long.

        This is the setting of the story:
        \(setting.title)

        These are the available speech styles:
        \(String(describing: voice.availableSpeechStyles.map({ $0.ssmlName })))

        Base the story on the following guide:
        \(storStructureGuide)
        """
        case .next(let previousChapter):
            mainPrompt = """
        Write the next chapter of an engagin Mandarin novel.
        The reader should be amazed an AI came up with it.
        Use vocabulary a 5 year old child could understand.
        The chapter should be 20 sentences long.

        "This is the previous chapter:
        \(previousChapter.passage)

        These are the available speech styles:
        \(String(describing: voice.availableSpeechStyles.map({ $0.ssmlName })))

        Base the chapter on the following guide:
        \(storStructureGuide)
        """
        }

        let response = try await makeGeminiRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt).data(using: .utf8)
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
        let mainPrompt = "Provide a definition for \(character) in \(sentence.mandarin)"
        let response = try await makeOpenAIRequest(initialPrompt: initialPrompt, mainPrompt: mainPrompt)
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
        guard let response = try? JSONDecoder().decode(GPTResponse.self, from: data),
              let responseString = response.choices.first?.message.content else {
            throw FastChineseServicesError.failedToDecodeJson
        }
        return responseString

    }

}
