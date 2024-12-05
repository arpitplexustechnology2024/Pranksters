//
//  PrankCreateAPI.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 27/11/24.
//

import Foundation
import Alamofire

protocol PrankAPIProtocol {
    func createPrank(coverImage: Data, coverImageURL: String, type: String, name: String, file: Data, fileURL: String, completion: @escaping (Result<PrankCreateResponse, Error>) -> Void)
    func updatePrankName(id: String, name: String, completion: @escaping (Result<PrankNameUpdate, Error>) -> Void)
}

class PrankAPIManager: PrankAPIProtocol {
    static let shared = PrankAPIManager()
    private init() {}
    
    func createPrank(coverImage: Data, coverImageURL: String, type: String, name: String, file: Data, fileURL: String, completion: @escaping (Result<PrankCreateResponse, Error>) -> Void) {
        let url = "https://pslink.world/api/prank/create"
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(type.data(using: .utf8)!, withName: "Type")
            
            multipartFormData.append(name.data(using: .utf8)!, withName: "Name")
            
            multipartFormData.append(coverImageURL.data(using: .utf8)!, withName: "CoverImageURL")
            
            multipartFormData.append(fileURL.data(using: .utf8)!, withName: "FileURL")
            
            multipartFormData.append(coverImage, withName: "CoverImage", fileName: "coverImage.jpg", mimeType: "image/jpeg")
            
            multipartFormData.append(file, withName: "File", fileName: "file.jpg", mimeType: "image/jpeg")
            
        }, to: url, method: .post).responseDecodable(of: PrankCreateResponse.self) { response in
            switch response.result {
            case .success(let prankResponse):
                if prankResponse.status == 1 {
                    completion(.success(prankResponse))
                } else {
                    let error = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid status"])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updatePrankName(id: String, name: String, completion: @escaping (Result<PrankNameUpdate, Error>) -> Void) {
        let url = "https://pslink.world/api/prank/update"
        
        let parameters: [String: String] = [
            "Id": id,
            "Name": name
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .validate()
            .responseDecodable(of: PrankNameUpdate.self) { response in
                switch response.result {
                case .success(let prankName):
                    if prankName.status == 1 {
                        completion(.success(prankName))
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
