import Foundation
import FirebaseFirestore

public class FirestoreConfigUploader {
    
    static func uploadFalApiKey() {
        let db = Firestore.firestore()
        
        // The FAL API key to upload
        let falApiKey = "e1f58875-fe36-4a31-ad34-badb6bbd0409:4645ce9820c0b75b3cbe1b0d9c324306"
        
        // Create a configuration document with the API key
        let configData: [String: Any] = [
            "fal_api_key": falApiKey,
            "last_updated": FieldValue.serverTimestamp()
        ]
        
        // Store in a 'config' collection under 'api_keys' document
        db.collection("config").document("api_keys").setData(configData) { error in
            if let error = error {
                print("❌ Error uploading FAL API key: \(error.localizedDescription)")
            } else {
                print("✅ FAL API key successfully uploaded to Firestore!")
                print("📍 Location: config/api_keys")
                print("🔑 Field name: fal_api_key")
                
                // Verify by reading back
                db.collection("config").document("api_keys").getDocument { document, error in
                    if let document = document, document.exists {
                        if let apiKey = document.data()?["fal_api_key"] as? String {
                            print("✅ Verified: API key successfully stored")
                            print("📱 Retrieved key: \(apiKey)")
                        }
                    }
                }
            }
        }
    }
    
    // Helper function to retrieve the FAL API key from Firestore
    static func getFalApiKey() async throws -> String {
        let db = Firestore.firestore()
        
        do {
            let document = try await db.collection("config").document("api_keys").getDocument()
            
            guard document.exists,
                  let apiKey = document.data()?["fal_api_key"] as? String,
                  !apiKey.isEmpty else {
                throw NSError()
            }
            
            return apiKey
        } catch {
            throw error
        }
    }
}

// Usage example (call this after Firebase.configure() in your app):
// FirestoreConfigUploader.uploadFalApiKey()
