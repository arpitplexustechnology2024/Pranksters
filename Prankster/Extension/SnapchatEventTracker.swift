//
//  SnapchatEventTracker.swift
//  Prankster
//
//  Created by Arpit iOS Dev. on 09/12/24.
//

import Foundation
import Alamofire

class SnapchatEventTracker {
    // Configuration constants
    private let baseURL = "https://tr.snapchat.com/v2/conversion/validate"
    private let appId = "6670788272"
    private let snapAppId = "97ad68aa-a2bf-4a7d-b07a-f2a39f03caa6"
    private let bearerToken = "eyJhbGciOiJIUzI1NiIsImtpZCI6IkNhbnZhc1MyU0hNQUNQcm9kIiwidHlwIjoiSldUIn0.eyJhdWQiOiJjYW52YXMtY2FudmFzYXBpIiwiaXNzIjoiY2FudmFzLXMyc3Rva2VuIiwibmJmIjoxNzI2NzI2MTA1LCJzdWIiOiJjMmQyMzI5OC0wYTIzLTRmZTItOTVhZi0zZjJlMDFhMjc0MmZ-UFJPRFVDVElPTn41MjgzNjZkOC01MzMyLTQyZDMtOTQ4NS04M2Y4YjFiNDFiZGQifQ.4EaMtoDAhd4btbEZl2x_GJ2ZocL93VqujqvJ8zqpODQ"
    
    // Struct to match the JSON payload
    struct InstallEventPayload: Codable {
        let app_id: String
        let snap_app_id: String
        let timestamp: String
        let event_type: String
        let event_conversion_type: String
        let event_tag: String
        let transaction_id: String
        let hashed_email: String
    }
    
    func trackAppInstall(transactionId: String, hashedEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Get current timestamp in ISO 8601 format
        let timestamp = ISO8601DateFormatter().string(from: Date())
        // Create payload
        let payload = InstallEventPayload(
            app_id: appId,
            snap_app_id: snapAppId,
            timestamp: timestamp,
            event_type: "APP_INSTALL",
            event_conversion_type: "MOBILE_APP",
            event_tag: "offline",
            transaction_id: transactionId,
            hashed_email: hashedEmail
        )
        
        // Prepare headers
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(bearerToken)"
        ]
        
        // Make the API call
        AF.request(baseURL,
                   method: .post,
                   parameters: payload,
                   encoder: JSONParameterEncoder.default,
                   headers: headers)
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
