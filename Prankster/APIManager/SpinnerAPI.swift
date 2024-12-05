//
//  SpinnerAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 30/11/24.
//

import Foundation
import Alamofire

// MARK: - SpinService Protocol
protocol SpinnerAPIProtocol {
    func postSpin(typeId: String, completion: @escaping (Result<SpinnerResponse, Error>) -> Void)
}

// MARK: - SpinService
class SpinnerAPIManger: SpinnerAPIProtocol {
    func postSpin(typeId: String, completion: @escaping (Result<SpinnerResponse, Error>) -> Void) {
        let url = "https://pslink.world/api/spin"
        
        let parameters: [String: String] = [
            "TypeId": typeId,
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .responseDecodable(of: SpinnerResponse.self) { response in
                switch response.result {
                case .success(let welcome):
                    if welcome.status == 1 {
                        completion(.success(welcome))
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
