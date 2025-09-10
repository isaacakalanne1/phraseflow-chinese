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

    /// Extracts a segment of audio data based on specified time range using semaphore-based synchronization
    /// - Parameters:
    ///   - asset: The AVAsset to extract audio from
    ///   - startTime: Start time in seconds
    ///   - duration: Duration of the segment in seconds
    /// - Returns: Audio data for the specified segment or nil if extraction fails
    static public func extractAudioSegment(
        from asset: AVAsset,
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

        // For very short segments, return nil to avoid extraction overhead
        if duration < 0.1 {
            print("Duration too short for extraction: \(duration) seconds")
            return nil
        }

        // Create output URL in temp directory
        let tempDirectory = FileManager.default.temporaryDirectory
        let outputFileName = UUID().uuidString + ".m4a"
        let outputURL = tempDirectory.appendingPathComponent(outputFileName)

        // Create export session
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            print("Failed to create export session")
            return nil
        }

        // Set output parameters
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a

        // Set time range
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 1000)
        let endCMTime = CMTime(seconds: startTime + duration, preferredTimescale: 1000)
        exportSession.timeRange = CMTimeRange(start: startCMTime, end: endCMTime)

        // Use DispatchSemaphore for synchronization instead of RunLoop
        let semaphore = DispatchSemaphore(value: 0)
        var result: Data? = nil
        
        exportSession.exportAsynchronously {
            defer { semaphore.signal() }
            
            switch exportSession.status {
            case .completed:
                do {
                    result = try Data(contentsOf: outputURL)
                    print("Successfully extracted audio segment: \(result?.count ?? 0) bytes")
                } catch {
                    print("Failed to read exported audio data: \(error)")
                    result = nil
                }
            case .failed:
                if let error = exportSession.error {
                    print("Export failed: \(error)")
                }
                result = nil
            case .cancelled:
                print("Export was cancelled")
                result = nil
            default:
                print("Export completed with unexpected status: \(exportSession.status)")
                result = nil
            }
            
            // Clean up output file
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        // Wait for completion with timeout
        let timeoutResult = semaphore.wait(timeout: .now() + 5.0)
        
        if timeoutResult == .timedOut {
            print("Audio extraction timed out")
            exportSession.cancelExport()
            try? FileManager.default.removeItem(at: outputURL)
            return nil
        }
        
        return result
    }
    
    /// Main actor isolated version that safely extracts audio from a player
    /// - Parameters:
    ///   - player: The AVPlayer to extract audio from
    ///   - startTime: Start time in seconds
    ///   - duration: Duration of the segment in seconds
    /// - Returns: Audio data for the specified segment or nil if extraction fails
    @MainActor
    static public func extractAudioSegment(
        from player: AVPlayer,
        startTime: Double,
        duration: Double
    ) -> Data? {
        print("Ayo!")
        guard let asset = player.currentItem?.asset else {
            print("Couldn't get asset from player")
            return nil
        }
        
        return extractAudioSegment(from: asset, startTime: startTime, duration: duration)
    }
}
