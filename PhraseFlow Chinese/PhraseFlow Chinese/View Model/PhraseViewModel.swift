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

    // Fetch the Google Sheets data and load the first phrase
    func loadPhrases() {
        fetchGoogleSheetData { [weak self] fetchedPhrases in
            self?.phrases = fetchedPhrases
            self?.loadNextPhrase()
        }
    }

    // Load a random phrase from the fetched list
    func loadNextPhrase() {
        guard !phrases.isEmpty else { return }
        currentPhrase = phrases.randomElement()
        userInput = ""
        showCorrectText = false
    }

    private func normalizePunctuation(_ text: String) -> String {
        // Replace English punctuation with Chinese equivalents
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

    // Fetch the audio from Azure Text-to-Speech API and play it
    func playTextToSpeech() {
        guard let currentPhrase = currentPhrase else { return }
        fetchAzureTextToSpeech(phrase: currentPhrase.mandarin) { [weak self] url in
            if let url = url {
                self?.playAudio(from: url)
            }
        }
    }

    // Function to play the audio directly from data
    private func playAudio(from data: Data) {
        do {
            // Initialize the AVAudioPlayer and assign it to the player property
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


    // Azure TTS API call (simplified to return Data instead of a file URL)
        private func fetchAzureTextToSpeech(phrase: String, completion: @escaping (Data?) -> Void) {
            let subscriptionKey = "144bc0cdea4d44e499927e84e795b27a"
            let region = "eastus"

            var request = URLRequest(url: URL(string: "https://\(region).tts.speech.microsoft.com/cognitiveservices/v1")!)
            request.httpMethod = "POST"
            request.addValue("application/ssml+xml", forHTTPHeaderField: "Content-Type")
            request.addValue("riff-24khz-16bit-mono-pcm", forHTTPHeaderField: "X-Microsoft-OutputFormat")
            request.addValue("\(subscriptionKey)", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

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

    // Azure Text-to-Speech API
//    private func fetchAzureTextToSpeech(phrase: String, completion: @escaping (URL?) -> Void) {
//        let subscriptionKey = "144bc0cdea4d44e499927e84e795b27a"
//        let region = "eastus"
//
//        var request = URLRequest(url: URL(string: "https://\(region).tts.speech.microsoft.com/cognitiveservices/v1")!)
//        request.httpMethod = "POST"
//        request.addValue("application/ssml+xml", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(subscriptionKey)", forHTTPHeaderField: "Authorization")
//
//        let ssml = """
//        <speak version='1.0' xml:lang='zh-CN'>
//            <voice name='zh-CN-XiaoxiaoNeural'>
//                \(phrase)
//            </voice>
//        </speak>
//        """
//        request.httpBody = ssml.data(using: .utf8)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data, error == nil {
//                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("speech.wav")
//                try? data.write(to: tempURL)
//                DispatchQueue.main.async {
//                    completion(tempURL)
//                }
//            } else {
//                completion(nil)
//            }
//        }
//        task.resume()
//    }
}
