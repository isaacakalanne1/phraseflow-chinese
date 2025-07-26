//
//  AudioExtractor.swift
//  Audio
//
//  Created by iakalann on 17/07/2025.
//

import AVFoundation
import Foundation

/// Utility functions for handling audio extraction - created as standalone functions instead of Data extensions
public class AudioExtractor {

    /// Extracts a segment of audio data based on specified time range
    /// - Parameters:
    ///   - audioData: The source audio data
    ///   - startTime: Start time in seconds
    ///   - duration: Duration of the segment in seconds
    /// - Returns: Audio data for the specified segment or nil if extraction fails
    @MainActor
    static public func extractAudioSegment(
        from player: AVPlayer,
        startTime: Double,
        duration: Double
    ) -> Data? {
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
