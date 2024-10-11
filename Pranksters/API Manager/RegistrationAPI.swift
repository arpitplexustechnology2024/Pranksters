//
//  RegistrationAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 09/10/24.
//

import Foundation
import Alamofire

protocol RegisterApiServiceProtocol {
    func registerUser(premium: Bool, completion: @escaping (Result<Registration, Error>) -> Void)
}

class RegisterAPIService: RegisterApiServiceProtocol {
    static let shared = RegisterAPIService()
    
    private init() {}
    
    func registerUser(premium: Bool, completion: @escaping (Result<Registration, Error>) -> Void) {
        let url = "https://pslink.world/api/register"
        let parameters: [String: Any] = [
            "Premium": premium
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseDecodable(of: Registration.self) { response in
            switch response.result {
            case .success(let registrationResponse):
                completion(.success(registrationResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
