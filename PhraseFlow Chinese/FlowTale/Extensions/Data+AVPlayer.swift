//
//  Data+AudioPlayer.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import AVKit

extension Data {
    func createAVPlayer(fileExtension: String = "mp3") -> AVPlayer? {
        // 1. Create a temporary file URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = UUID().uuidString + "." + fileExtension
        let tempFileURL = tempDirectory.appendingPathComponent(tempFileName)

        do {
            // 2. Write the audio data to the temporary file
            try self.write(to: tempFileURL)

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

extension Data {
    /// Extracts an audio segment using async/await.
    func extractAudioSegment(startTime: TimeInterval,
                             duration: TimeInterval,
                             outputFileType: AVFileType = .m4a) async -> Data? {
        // Write the audio data to a temporary file.
        let inputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("inputAudio.m4a")
        do {
            try self.write(to: inputURL)
        } catch {
            print("Failed to write audio data: \(error)")
            return nil
        }

        let asset = AVAsset(url: inputURL)

        // Create export session.
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
            print("Failed to create export session")
            return nil
        }

        // Define the output URL.
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("trimmedSegment.m4a")
        try? FileManager.default.removeItem(at: outputURL)

        exportSession.outputURL = outputURL
        exportSession.outputFileType = outputFileType

        // Define the time range to export.
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        let segmentDuration = CMTime(seconds: duration, preferredTimescale: 600)
        exportSession.timeRange = CMTimeRange(start: start, duration: segmentDuration)

        // Use a continuation to await the export.
        let segmentData: Data? = await withCheckedContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    if let data = try? Data(contentsOf: outputURL) {
                        continuation.resume(returning: data)
                    } else {
                        print("Could not read trimmed segment data")
                        continuation.resume(returning: nil)
                    }
                default:
                    print("Export failed: \(String(describing: exportSession.error))")
                    continuation.resume(returning: nil)
                }
            }
        }
        return segmentData
    }
}
