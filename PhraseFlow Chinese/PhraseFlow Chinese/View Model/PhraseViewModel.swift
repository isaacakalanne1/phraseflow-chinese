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
    @Published var phrases = [Phrase]()
    @Published var currentPhrase: Phrase?
    @Published var userInput = ""
    @Published var isCorrect = false
    @Published var showCorrectText = false

    private var player: AVAudioPlayer? // Store the AVAudioPlayer as a property
    private var audioCache: [String: Data] = [:] // In-memory cache for audio data
    private var currentPhraseIndex: Int = 0 // Track current phrase index

    // Fetch the Google Sheets data and preload the first four phrases
    func loadPhrases() {
        fetchGoogleSheetData { [weak self] fetchedPhrases in
            self?.phrases = fetchedPhrases.shuffled()
            self?.currentPhraseIndex = 0
            self?.currentPhrase = self?.phrases.first
            self?.preloadAudio() // Preload audio for the first four phrases
        }
    }

    // Preload the audio for the current phrase and the next three phrases
    private func preloadAudio() {
        for i in 0..<4 {
            let index = (currentPhraseIndex + i) % phrases.count
            let phrase = phrases[index]
            if audioCache[phrase.mandarin] == nil {
                // Fetch audio and cache it
                fetchAzureTextToSpeech(phrase: phrase.mandarin) { [weak self] audioData in
                    guard let self = self, let audioData = audioData else { return }
                    self.audioCache[phrase.mandarin] = audioData
                }
            }
        }
    }

    // Load the next phrase and preload the following phrases
    func loadNextPhrase() {
        currentPhraseIndex = (currentPhraseIndex + 1) % phrases.count
        currentPhrase = phrases[currentPhraseIndex]
        userInput = ""
        showCorrectText = false
        preloadAudio() // Preload audio for the next 3 phrases
    }

    // Normalize punctuation between English and Chinese
    private func normalizePunctuation(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "?", with: "？")
            .replacingOccurrences(of: "!", with: "！")
            .replacingOccurrences(of: ".", with: "。")
            .replacingOccurrences(of: ",", with: "，")
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

    // Fetch data from Google Sheets (simplified)
    private func fetchGoogleSheetData(completion: @escaping ([Phrase]) -> Void) {
        let sheetURL = URL(string: "https://docs.google.com/spreadsheets/d/19B3xWuRrTMfpva_IJAyRqGN7Lj3aKlZkZW1N7TwesAE/export?format=csv")!

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

    // Parse CSV data into an array of phrases
    private func parseCSVData(_ csvString: String) -> [Phrase] {
        let rows = csvString.components(separatedBy: "\n")
        var phrases = [Phrase]()

        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count == 3 {
                let phrase = Phrase(mandarin: columns[0], pinyin: columns[1], english: columns[2])
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
