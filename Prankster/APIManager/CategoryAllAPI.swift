//
//  CharacterAllAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import Alamofire
import UIKit

// MARK: - Audio API Protocol
protocol CategoryAllAPIServiceProtocol {
    func fetchAudioData(categoryId: Int, typeId: Int, page: Int, completion: @escaping (Result<CategoryAllResponse, Error>) -> Void)
}

// MARK: - Audio API Service
class CategoryAllAPIService: CategoryAllAPIServiceProtocol {
    static let shared = CategoryAllAPIService()
    private init() {}
    
    func fetchAudioData(categoryId: Int, typeId: Int, page: Int, completion: @escaping (Result<CategoryAllResponse, Error>) -> Void) {
        let url = "https://pslink.world/api/category/all"
        
        let parameters: [String: Any] = [
            "CategoryId": categoryId,
            "TypeId": typeId,
            "page": page
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
        .responseDecodable(of: CategoryAllResponse.self) { response in
            switch response.result {
            case .success(let audioResponse):
                completion(.success(audioResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
