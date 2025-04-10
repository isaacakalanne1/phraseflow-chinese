//
//  Data+AVPlayer.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import AVFoundation
import AVKit

extension Data {
    func createAVPlayer(fileExtension: String = "mp3") -> AVPlayer? {
        // 1. Create a temporary file URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = UUID().uuidString + "." + fileExtension
        let tempFileURL = tempDirectory.appendingPathComponent(tempFileName)

        do {
            // 2. Write the audio data to the temporary file
            try write(to: tempFileURL)

            // 3. Create an AVAsset from the file URL
            let asset = AVAsset(url: tempFileURL)

            // 4. Create an AVPlayerItem from the asset
            let playerItem = AVPlayerItem(asset: asset)

            // 5. Set the audio time pitch algorithm to time domain
            playerItem.audioTimePitchAlgorithm = .timeDomain

            // 6. Initialize the AVPlayer with the player item
            let player = AVPlayer(playerItem: playerItem)

            // Optionally, remove the temporary file after a delay to ensure the player has loaded the asset
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                try? FileManager.default.removeItem(at: tempFileURL)
            }

            return player
        } catch {
            print("Error creating AVPlayer from audio data: \(error)")
            return nil
        }
    }
}

/// Utility functions for handling audio extraction - created as standalone functions instead of Data extensions
class AudioExtractor {
    static let shared = AudioExtractor()

    private init() {}

    /// Extracts a segment of audio data based on specified time range
    /// - Parameters:
    ///   - audioData: The source audio data
    ///   - startTime: Start time in seconds
    ///   - duration: Duration of the segment in seconds
    /// - Returns: Audio data for the specified segment or nil if extraction fails
    func extractAudioSegment(from player: AVPlayer, startTime: Double, duration: Double) -> Data? {
        // Basic validation
        guard startTime >= 0,
              duration > 0
        else {
            print("Invalid parameters: startTime must be >= 0 and duration must be > 0")
            return nil
        }
        guard let asset = player.currentItem?.asset else {
            print("Couldn't get asset")
            return nil
        }

        // For very short segments, return nil to avoid extraction overhead
        if duration < 0.1 {
            print("Duration too short for extraction: \(duration) seconds")
            return nil
        }

        // Create a simpler, reliable implementation with m4a output format
        let tempDirectory = FileManager.default.temporaryDirectory
        let sourceFileName = UUID().uuidString + ".m4a"
        let sourceURL = tempDirectory.appendingPathComponent(sourceFileName)
        let outputFileName = UUID().uuidString + ".m4a"
        let outputURL = tempDirectory.appendingPathComponent(outputFileName)

        do {
            // Create export session
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
                print("Failed to create export session")
                try? FileManager.default.removeItem(at: sourceURL)
                return nil
            }

            // Set output parameters
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .m4a

            // Set time range
            let startCMTime = CMTime(seconds: startTime, preferredTimescale: 1000)
            let endCMTime = CMTime(seconds: startTime + duration, preferredTimescale: 1000)
            exportSession.timeRange = CMTimeRange(start: startCMTime, end: endCMTime)

            // Use RunLoop-based waiting to avoid QoS priority inversion
            var isCompleted = false
            var exportResult: AVAssetExportSession.Status = .unknown
            
            exportSession.exportAsynchronously {
                exportResult = exportSession.status
                isCompleted = true
            }

            // Wait for completion using RunLoop to avoid blocking and QoS issues
            let timeoutDate = Date().addingTimeInterval(5.0)
            while !isCompleted && Date() < timeoutDate {
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
            }

            // Check for timeout
            if !isCompleted {
                print("Audio extraction timed out")
                exportSession.cancelExport()
                try? FileManager.default.removeItem(at: sourceURL)
                try? FileManager.default.removeItem(at: outputURL)
                return nil
            }

            // Check for completion
            if exportResult == .completed {
                // Read the exported data
                let extractedData = try Data(contentsOf: outputURL)

                // Clean up
                try? FileManager.default.removeItem(at: sourceURL)
                try? FileManager.default.removeItem(at: outputURL)

                // Return the extracted data
                print("Successfully extracted audio segment: \(extractedData.count) bytes")
                return extractedData
            } else {
                // Log error and clean up
                if let error = exportSession.error {
                    print("Export failed: \(error)")
                }

                try? FileManager.default.removeItem(at: sourceURL)
                try? FileManager.default.removeItem(at: outputURL)

                // Return nil to indicate failure
                print("Audio extraction failed, returning nil")
                return nil
            }
        } catch {
            print("Error during extraction: \(error)")
            try? FileManager.default.removeItem(at: sourceURL)
            try? FileManager.default.removeItem(at: outputURL)
            return nil
        }
    }
}
