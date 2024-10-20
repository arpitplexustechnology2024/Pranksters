//
//  CharacterAllAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import Alamofire
import UIKit

// MARK: - Audio API Protocol
protocol ChracterAllAPIServiceProtocol {
    func fetchAudioData(categoryId: Int, characterId: Int, completion: @escaping (Result<CharacterAllResponse, Error>) -> Void)
}

// MARK: - Audio API Service
class CharacterAllAPIService: ChracterAllAPIServiceProtocol {
    static let shared = CharacterAllAPIService()
    private init() {}
    
    func fetchAudioData(categoryId: Int, characterId: Int, completion: @escaping (Result<CharacterAllResponse, Error>) -> Void) {
        let url = "https://pslink.world/api/character/all"
        
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters: [String: Any] = [
            "CategoryId": categoryId,
            "CharacterId": characterId
        ]
        
        AF.request(url,
                  method: .post,
                  parameters: parameters,
                  encoding: URLEncoding.default,
                  headers: headers)
        .validate()
        .responseDecodable(of: CharacterAllResponse.self) { response in
            switch response.result {
            case .success(let audioResponse):
                completion(.success(audioResponse))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
}
