//
//  CoverPageAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 10/10/24.
//

import Alamofire

// MARK: - EmojiAPIServiceProtocol
protocol EmojiAPIServiceProtocol {
    func fetchCoverPages(page: Int, completion: @escaping (Result<CoverPage, Error>) -> Void)
}

// MARK: - EmojiAPIService
class EmojiAPIService: EmojiAPIServiceProtocol {
    
    static let shared = EmojiAPIService()
    private init() {}
    
    func fetchCoverPages(page: Int, completion: @escaping (Result<CoverPage, Error>) -> Void) {
        let url = "https://pslink.world/api/cover/emoji"
        
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters: [String: Any] = [
            "page": page
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .responseDecodable(of: CoverPage.self) { response in
                switch response.result {
                case .success(let coverPageResponse):
                    completion(.success(coverPageResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

// MARK: - RealisticAPIServiceProtocol
protocol RealisticAPIServiceProtocol {
    func fetchRealisticCoverPages(page: Int, completion: @escaping (Result<CoverPage, Error>) -> Void)
}

// MARK: - EmojiAPIService
class RealisticAPIService: RealisticAPIServiceProtocol {
    
    static let shared = RealisticAPIService()
    private init() {}
    
    func fetchRealisticCoverPages(page: Int, completion: @escaping (Result<CoverPage, any Error>) -> Void) {
        let url = "https://pslink.world/api/cover/realistic"
        
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters: [String: Any] = [
            "page": page
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .responseDecodable(of: CoverPage.self) { response in
                switch response.result {
                case .success(let coverPageResponse):
                    completion(.success(coverPageResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

