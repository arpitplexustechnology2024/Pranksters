//
//  AudioCharacterAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import Alamofire
import UIKit

// MARK: - API Protocols
protocol CharacterAPIServiceProtocol {
    func fetchCharacters(categoryId: Int, completion: @escaping (Result<CharacterResponse, Error>) -> Void)
}

// MARK: - Character API Service
class CharacterAPIService: CharacterAPIServiceProtocol {
    static let shared = CharacterAPIService()
    private init() {}
    
    func fetchCharacters(categoryId: Int, completion: @escaping (Result<CharacterResponse, Error>) -> Void) {
        let url = "https://pslink.world/api/character"
        
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters: [String: Any] = [
            "CategoryId": categoryId
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: headers)
        .validate()
        .responseDecodable(of: CharacterResponse.self) { response in
            switch response.result {
            case .success(let characterResponse):
                if characterResponse.status == 1 {
                    completion(.success(characterResponse))
                } else {
                    let error = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid status"])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
