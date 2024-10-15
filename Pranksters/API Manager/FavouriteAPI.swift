//
//  FavouriteAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 14/10/24.
//

import Foundation
import Alamofire

// MARK: - FavoriteAPIServiceProtocol
protocol FavoriteAPIServiceProtocol {
    func setFavorite(itemId: Int, isFavorite: Bool, completion: @escaping (Result<FavouriteSet, Error>) -> Void)
}

// MARK: - FavoriteAPIService
class FavoriteAPIService: FavoriteAPIServiceProtocol {
    static let shared = FavoriteAPIService()
    private init() {}
    
    func setFavorite(itemId: Int, isFavorite: Bool, completion: @escaping (Result<FavouriteSet, Error>) -> Void) {
        let url = "https://pslink.world/api/favourite"
        
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters: [String: Any] = [
            "ItemId": itemId,
            "Favourite": isFavorite ? "true" : "false",  // Changed to string
            "CategoryId": 4
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .responseDecodable(of: FavouriteSet.self) { response in
                switch response.result {
                case .success(let favouriteSetResponse):
                    completion(.success(favouriteSetResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
