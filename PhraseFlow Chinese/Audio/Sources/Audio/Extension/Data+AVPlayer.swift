//
//  Data+AVPlayer.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import AVFoundation
import AVKit

public extension Data {
    func createAVPlayer(fileExtension: String = "mp3") async -> AVPlayer? {
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
            let playerItem = await AVPlayerItem(asset: asset)

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
