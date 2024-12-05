//
//  AudioCharacterAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import Alamofire
import UIKit

// MARK: - API Protocols
protocol CategoryAPIServiceProtocol {
    func fetchCategorys(typeId: Int, completion: @escaping (Result<CategoryResponse, Error>) -> Void)
}

// MARK: - Category API Service
class CategoryAPIService: CategoryAPIServiceProtocol {
    static let shared = CategoryAPIService()
    private init() {}
    
    func fetchCategorys(typeId: Int, completion: @escaping (Result<CategoryResponse, Error>) -> Void) {
        let url = "https://pslink.world/api/category"
        
        let parameters: [String: Any] = [
            "TypeId": typeId
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
        .validate()
        .responseDecodable(of: CategoryResponse.self) { response in
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
