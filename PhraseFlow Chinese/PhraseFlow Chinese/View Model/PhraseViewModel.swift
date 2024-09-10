//
//  PhraseViewModel.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI
import AVFoundation
import Combine
import Speech

class PhraseViewModel: ObservableObject {
    @Published var phrases = [Phrase]() // All phrases (short + medium)
    @Published var shortPhrases = [Phrase]() // Short phrases only
    @Published var mediumPhrases = [Phrase]() // Medium phrases only
    @Published var longPhrases = [Phrase]() // Medium phrases only

    // Computed property to get all learning phrases (short + medium)
    var allLearningPhrases: [Phrase] {
        return learningShortPhrases + learningMediumPhrases + learningLongPhrases
    }

    @Published var learningShortPhrases = [Phrase]() // Short phrases being learned
    @Published var learningMediumPhrases = [Phrase]()
    @Published var learningLongPhrases = [Phrase]()
    @Published var currentPhrase: Phrase?
    @Published var toLearnPhrases = [Phrase]() // Phrases to learn (short + medium)
    @Published var userInput = ""
    @Published var isCorrect = false
    @Published var showCorrectText = false

    @Published var speechSpeed: SpeechSpeed = .normal

    private var player: AVAudioPlayer? // Store the AVAudioPlayer as a property
    private var audioCache: [String: Data] = [:] // In-memory cache for audio data
    private var currentPhraseIndex: Int = 0 // Track current phrase index

    private let learningShortKey = "learningShortPhrases"
    private let learningMediumKey = "learningMediumPhrases"
    private let learningLongKey = "learningLongPhrases"

    init() {
        requestSpeechAuthorization()
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

        // Load long phrases
        fetchGoogleSheetData(gid: "547164039") { [weak self] fetchedLongPhrases in
            self?.longPhrases = fetchedLongPhrases.shuffled()
            self?.phrases.append(contentsOf: fetchedLongPhrases) // Add to the main phrases list
            self?.toLearnPhrases.append(contentsOf: fetchedLongPhrases) // Add to learnable phrases
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

        if let savedLongData = UserDefaults.standard.data(forKey: learningLongKey),
           let savedLongPhrases = try? JSONDecoder().decode([Phrase].self, from: savedLongData) {
            self.learningLongPhrases = savedLongPhrases.shuffled()
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

        if let encodedLongData = try? JSONEncoder().encode(learningLongPhrases) {
            UserDefaults.standard.set(encodedLongData, forKey: learningLongKey)
        }
    }

    // Clear the saved learning phrases from UserDefaults
    func clearLearningPhrases() {
        UserDefaults.standard.removeObject(forKey: learningShortKey)
        UserDefaults.standard.removeObject(forKey: learningMediumKey)
        UserDefaults.standard.removeObject(forKey: learningLongKey)
        learningShortPhrases.removeAll() // Also clear the current in-memory learning list
        learningMediumPhrases.removeAll() // Also clear the current in-memory learning list
        learningLongPhrases.removeAll() // Also clear the current in-memory learning list
    }

    // Move a short phrase to the learning list
    func moveToLearning(phrase: Phrase, category: PhraseCategory) {
        switch category {
        case .short:
            learningShortPhrases.append(phrase)
            shortPhrases.removeAll { $0 == phrase }
        case .medium:
            learningMediumPhrases.append(phrase)
            mediumPhrases.removeAll { $0 == phrase }
        case .long:
            learningLongPhrases.append(phrase)
            longPhrases.removeAll { $0 == phrase }
        }
        saveLearningPhrases() // Save to UserDefaults
        loadNextPhrase()
    }

    // Remove a phrase from the learning list and move it back to To Learn
    func removeFromLearning(phrase: Phrase, category: PhraseCategory) {
        switch category {
        case .short:
            learningShortPhrases.removeAll { $0 == phrase }
            shortPhrases.append(phrase)
        case .medium:
            learningMediumPhrases.removeAll { $0 == phrase }
            mediumPhrases.append(phrase)
        case .long:
            learningLongPhrases.removeAll { $0 == phrase }
            longPhrases.append(phrase)
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

    private func preloadAudio() {
        let learningPhrases = allLearningPhrases
        guard !learningPhrases.isEmpty else { return }

        // Preload audio for the current phrase and the next 3 phrases
        for i in 0..<4 {
            let index = (currentPhraseIndex + i) % learningPhrases.count
            let phrase = learningPhrases[index]

            // Check if audio is already cached
            if audioCache[phrase.mandarin] == nil {
                fetchAzureTextToSpeech(phrase: phrase.mandarin) { [weak self] audioData in
                    guard let self = self, let audioData = audioData else { return }

                    // Cache the audio data
                    self.audioCache[phrase.mandarin] = audioData

                    // Segment the audio into timestamps for each character
                    self.segmentAudio(data: audioData, mandarinText: phrase.mandarin) { timestamps in
                        if let timestamps = timestamps {
                            self.saveCharacterTimestamps(timestamps, for: phrase)
                            self.saveLearningPhrases() // Save the updated learning phrases with timestamps
                        }
                    }
                }
            }
        }
    }

    // Save character timestamps in the Phrase
    private func saveCharacterTimestamps(_ timestamps: [TimeInterval], for phrase: Phrase) {
        if let index = learningShortPhrases.firstIndex(where: { $0 == phrase }) {
            learningShortPhrases[index].characterTimestamps = timestamps
        } else if let index = learningMediumPhrases.firstIndex(where: { $0 == phrase }) {
            learningMediumPhrases[index].characterTimestamps = timestamps
        } else if let index = learningLongPhrases.firstIndex(where: { $0 == phrase }) {
           learningLongPhrases[index].characterTimestamps = timestamps
       }
    }

    // Normalize punctuation between English and Chinese
    private func normalizePunctuation(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "?", with: "？")
            .replacingOccurrences(of: ",", with: "，")
        
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "！", with: "")
            .replacingOccurrences(of: "。", with: "")
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

                // Segment the audio to get timestamps for each character
                segmentAudio(data: audioData, mandarinText: currentPhrase.mandarin) { timestamps in
                    if let timestamps = timestamps {
                        self.currentPhrase?.characterTimestamps = timestamps
                        self.saveLearningPhrases() // Save to UserDefaults
                    }
                    self.playAudio(from: audioData)
                }
            }
        }
    }

    // Function to play the audio directly from data
    private func playAudio(from data: Data) {
        do {
            self.player = try AVAudioPlayer(data: data)
            self.player?.enableRate = true
            self.player?.rate = speechSpeed.rate
            self.player?.prepareToPlay()
            self.player?.play()
        } catch {
            print("Error playing audio from data: \(error.localizedDescription)")
        }
    }

    func playAudio(from characterIndex: Int) {
        guard let currentPhrase = currentPhrase,
              characterIndex < currentPhrase.characterTimestamps.count else {
            return
        }

        let timestamp = currentPhrase.characterTimestamps[characterIndex]

        if let audioData = audioCache[currentPhrase.mandarin] {
            do {
                player = try AVAudioPlayer(data: audioData)
                player?.currentTime = timestamp
                player?.play()
            } catch {
                print("Error playing audio from timestamp: \(error)")
            }
        }
    }

    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    self.showPermissionAlert()
                case .restricted:
                    self.showPermissionAlert()
                case .notDetermined:
                    self.showPermissionAlert()
                @unknown default:
                    self.showPermissionAlert()
                }
            }
        }
    }

    func showPermissionAlert() {
        // Show an alert that asks the user to enable speech recognition in settings
        let alert = UIAlertController(title: "Speech Recognition Permission Required", message: "Please enable speech recognition in the device settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }


    func segmentAudio(data: Data, mandarinText: String, completion: @escaping ([TimeInterval]?) -> Void) {
        // Initialize the speech recognizer and request transcription
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN")) else {
            completion(nil)
            return
        }

        guard let url = saveAudioToTempFile(mandarinText: mandarinText, data: data) else {
            completion(nil)
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        recognizer.recognitionTask(with: request) { result, error in
            if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let result = result else {
                print("No result from speech recognizer")
                completion(nil)
                return
            }

            var timestamps: [TimeInterval] = []
            for segment in result.bestTranscription.segments {
                // Map each character in the Mandarin text to the corresponding timestamp
                let characterIndex = segment.substringRange.location
                if characterIndex < mandarinText.count {
                    timestamps.append(segment.timestamp)
                }
            }
            completion(timestamps)
        }
    }

    func saveAudioToTempFile(mandarinText: String, data: Data) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(mandarinText).wav")
        do {
            try data.write(to: tempURL)
            let asset = AVAsset(url: tempURL)
            let formatDescriptions = asset.tracks.first?.formatDescriptions
            formatDescriptions?.forEach { description in
                let formatDescription = description as! CMAudioFormatDescription
                let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)?.pointee
                print("Sample rate: \(streamBasicDescription?.mSampleRate ?? 0)")
                print("Channels: \(streamBasicDescription?.mChannelsPerFrame ?? 0)")
            }
            return tempURL
        } catch {
            print("Error writing audio data to file: \(error.localizedDescription)")
            return nil
        }
        return tempURL
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

    private func parseCSVData(_ csvString: String) -> [Phrase] {
        var phrases = [Phrase]()

        // Split the string into lines
        let lines = csvString.components(separatedBy: .newlines)

        // Parse each line
        for line in lines {
            // Use a regular expression to match quoted fields
            let pattern = #"(?<=^|,)(\"(?:[^\"]|\"\")*\"|[^,]*)"#
            let regex = try? NSRegularExpression(pattern: pattern, options: [])

            if let matches = regex?.matches(in: line, range: NSRange(location: 0, length: line.utf16.count)) {
                var columns = [String]()

                for match in matches {
                    if let range = Range(match.range, in: line) {
                        var column = String(line[range])

                        // Remove enclosing quotes and unescape any double quotes
                        if column.hasPrefix("\"") && column.hasSuffix("\"") {
                            column.removeFirst()
                            column.removeLast()
                            column = column.replacingOccurrences(of: "\"\"", with: "\"")
                        }

                        columns.append(column)
                    }
                }

                // Ensure there are exactly 3 columns: Mandarin, Pinyin, and English
                if columns.count == 3 {
                    let mandarin = columns[0]
                    let pinyin = columns[1]
                    let english = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    let phrase = Phrase(mandarin: mandarin, pinyin: pinyin, english: english)
                    phrases.append(phrase)
                }
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
