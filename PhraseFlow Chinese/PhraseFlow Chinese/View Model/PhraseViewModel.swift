//
//  PhraseViewModel.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI
import AVFoundation
import Combine

class PhraseViewModel: ObservableObject {
    @Published var phrases = [Phrase]() // All phrases (short + medium)
    @Published var shortPhrases = [Phrase]() // Short phrases only
    @Published var mediumPhrases = [Phrase]() // Medium phrases only

    // Computed property to get all learning phrases (short + medium)
    var allLearningPhrases: [Phrase] {
        return learningShortPhrases + learningMediumPhrases
    }

    @Published var learningShortPhrases = [Phrase]() // Short phrases being learned
    @Published var learningMediumPhrases = [Phrase]()
    @Published var currentPhrase: Phrase?
    @Published var toLearnPhrases = [Phrase]() // Phrases to learn (short + medium)
    @Published var userInput = ""
    @Published var isCorrect = false
    @Published var showCorrectText = false

    private var player: AVAudioPlayer? // Store the AVAudioPlayer as a property
    private var audioCache: [String: Data] = [:] // In-memory cache for audio data
    private var currentPhraseIndex: Int = 0 // Track current phrase index

    private let learningShortKey = "learningShortPhrases"
        private let learningMediumKey = "learningMediumPhrases"

    init() {
        loadPhrasesOnAppLaunch() // Load both short and medium phrases
        loadLearningPhrases() // Load learning phrases from UserDefaults
        loadNextPhrase()
    }

    // Load short and medium phrases on app launch
    func loadPhrasesOnAppLaunch() {
        // Load short phrases
        fetchGoogleSheetData(gid: "0") { [weak self] fetchedShortPhrases in
            self?.shortPhrases = fetchedShortPhrases.shuffled()
            self?.phrases.append(contentsOf: fetchedShortPhrases) // Add to the main phrases list
            self?.toLearnPhrases.append(contentsOf: fetchedShortPhrases) // Add to learnable phrases
        }

        // Load medium phrases
        fetchGoogleSheetData(gid: "2033303776") { [weak self] fetchedMediumPhrases in
            self?.mediumPhrases = fetchedMediumPhrases.shuffled()
            self?.phrases.append(contentsOf: fetchedMediumPhrases) // Add to the main phrases list
            self?.toLearnPhrases.append(contentsOf: fetchedMediumPhrases) // Add to learnable phrases
        }
    }

    private func loadLearningPhrases() {
        if let savedShortData = UserDefaults.standard.data(forKey: learningShortKey),
           let savedShortPhrases = try? JSONDecoder().decode([Phrase].self, from: savedShortData) {
            self.learningShortPhrases = savedShortPhrases.shuffled()
        }

        if let savedMediumData = UserDefaults.standard.data(forKey: learningMediumKey),
           let savedMediumPhrases = try? JSONDecoder().decode([Phrase].self, from: savedMediumData) {
            self.learningMediumPhrases = savedMediumPhrases.shuffled()
        }
    }

    // Save learning phrases to UserDefaults
    private func saveLearningPhrases() {
        if let encodedShortData = try? JSONEncoder().encode(learningShortPhrases) {
            UserDefaults.standard.set(encodedShortData, forKey: learningShortKey)
        }

        if let encodedMediumData = try? JSONEncoder().encode(learningMediumPhrases) {
            UserDefaults.standard.set(encodedMediumData, forKey: learningMediumKey)
        }
    }

    // Clear the saved learning phrases from UserDefaults
    func clearLearningPhrases() {
        UserDefaults.standard.removeObject(forKey: learningShortKey)
        UserDefaults.standard.removeObject(forKey: learningMediumKey)
        learningShortPhrases.removeAll() // Also clear the current in-memory learning list
        learningMediumPhrases.removeAll() // Also clear the current in-memory learning list
    }

    // Move a short phrase to the learning list
    func moveToLearning(phrase: Phrase, category: PhraseCategory) {
        if category == .short {
            shortPhrases.removeAll { $0 == phrase }
            learningShortPhrases.append(phrase)
        } else {
            mediumPhrases.removeAll { $0 == phrase }
            learningMediumPhrases.append(phrase)
        }
        saveLearningPhrases() // Save to UserDefaults
        loadNextPhrase()
    }

    // Remove a phrase from the learning list and move it back to To Learn
    func removeFromLearning(phrase: Phrase, category: PhraseCategory) {
        if category == .short {
            learningShortPhrases.removeAll { $0 == phrase }
            shortPhrases.append(phrase)
        } else {
            learningMediumPhrases.removeAll { $0 == phrase }
            mediumPhrases.append(phrase)
        }
        saveLearningPhrases() // Save the updated learning phrases to UserDefaults
    }

    // Load next phrase from the allLearningPhrases list
    func loadNextPhrase() {
        let learningPhrases = allLearningPhrases
        guard !learningPhrases.isEmpty else { return }

        currentPhraseIndex = (currentPhraseIndex + 1) % learningPhrases.count
        currentPhrase = learningPhrases[currentPhraseIndex]
        userInput = ""
        showCorrectText = false
        preloadAudio() // Preload audio for the next 3 phrases
    }

    // Preload audio for the next 3 phrases in the learningPhrases list
    private func preloadAudio() {
        let learningPhrases = allLearningPhrases
        guard !learningPhrases.isEmpty else { return }

        for i in 0..<4 {
            let index = (currentPhraseIndex + i) % learningPhrases.count
            let phrase = learningPhrases[index]
            if audioCache[phrase.mandarin] == nil {
                fetchAzureTextToSpeech(phrase: phrase.mandarin) { [weak self] audioData in
                    guard let self = self, let audioData = audioData else { return }
                    self.audioCache[phrase.mandarin] = audioData
                }
            }
        }
    }


    // Normalize punctuation between English and Chinese
    private func normalizePunctuation(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
    }

    // Validate user input with normalized punctuation
    func validateInput() {
        guard let currentPhrase = currentPhrase else { return }

        let normalizedUserInput = normalizePunctuation(userInput)
        let normalizedCorrectText = normalizePunctuation(currentPhrase.mandarin)

        isCorrect = normalizedUserInput == normalizedCorrectText
        showCorrectText = true
    }

    // Play audio for the current phrase (fetch from cache or Azure)
    func playTextToSpeech() {
        guard let currentPhrase = currentPhrase else { return }

        // Check if audio is already cached
        if let cachedAudio = audioCache[currentPhrase.mandarin] {
            playAudio(from: cachedAudio)
        } else {
            // Fetch audio from Azure if not cached
            fetchAzureTextToSpeech(phrase: currentPhrase.mandarin) { [weak self] audioData in
                guard let self = self, let audioData = audioData else { return }
                self.audioCache[currentPhrase.mandarin] = audioData
                self.playAudio(from: audioData)
            }
        }
    }

    // Function to play the audio directly from data
    private func playAudio(from data: Data) {
        do {
            self.player = try AVAudioPlayer(data: data)
            self.player?.prepareToPlay()
            self.player?.play()
        } catch {
            print("Error playing audio from data: \(error.localizedDescription)")
        }
    }

    func fetchGoogleSheetData(gid: String, completion: @escaping ([Phrase]) -> Void) {
        let spreadsheetId = "19B3xWuRrTMfpva_IJAyRqGN7Lj3aKlZkZW1N7TwesAE"
        let sheetURL = URL(string: "https://docs.google.com/spreadsheets/d/\(spreadsheetId)/export?format=csv&gid=\(gid)")!

        let task = URLSession.shared.dataTask(with: sheetURL) { data, response, error in
            if let data = data, let csvString = String(data: data, encoding: .utf8) {
                let phrases = self.parseCSVData(csvString)
                DispatchQueue.main.async {
                    completion(phrases)
                }
            }
        }
        task.resume()
    }

    // Parse CSV data into phrases
    private func parseCSVData(_ csvString: String) -> [Phrase] {
        let rows = csvString.components(separatedBy: "\n")
        var phrases = [Phrase]()

        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count == 3 {
                let mandarin = columns[0]
                let pinyin = columns[1]
                let english = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let phrase = Phrase(mandarin: mandarin, pinyin: pinyin, english: english)
                phrases.append(phrase)
            }
        }
        return phrases
    }

    // Azure TTS API call (fetch data directly)
    private func fetchAzureTextToSpeech(phrase: String, completion: @escaping (Data?) -> Void) {
        let subscriptionKey = "144bc0cdea4d44e499927e84e795b27a"
        let region = "eastus"

        var request = URLRequest(url: URL(string: "https://\(region).tts.speech.microsoft.com/cognitiveservices/v1")!)
        request.httpMethod = "POST"
        request.addValue("application/ssml+xml", forHTTPHeaderField: "Content-Type")
        request.addValue("riff-24khz-16bit-mono-pcm", forHTTPHeaderField: "X-Microsoft-OutputFormat")
        request.addValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let ssml = """
        <speak version='1.0' xml:lang='zh-CN'>
            <voice name='zh-CN-XiaoxiaoNeural'>
                \(phrase)
            </voice>
        </speak>
        """
        request.httpBody = ssml.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    completion(data)  // Return the audio data directly
                }
            } else {
                print("Error fetching audio: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}
