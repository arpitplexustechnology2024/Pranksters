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
        
        let parameters: [String: Any] = [
            "page": page
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
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
        
        let parameters: [String: Any] = [
            "page": page
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
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

// MARK: - FileUploadAPIServiceProtocol
protocol FileUploadAPIServiceProtocol {
    func uploadFile(file: Data, typeId: Int, completion: @escaping (Result<UserDataUpload, Error>) -> Void)
}

// MARK: - FileUploadAPIService
class FileUploadAPIService: FileUploadAPIServiceProtocol {
    static let shared = FileUploadAPIService()
    private init() {}
    
    func uploadFile(file: Data, typeId: Int, completion: @escaping (Result<UserDataUpload, Error>) -> Void) {
        let url = "https://pslink.world/api/users/upload"
        
        // Create multipart form data
        AF.upload(multipartFormData: { multipartFormData in
            // Add file data
            multipartFormData.append(file, withName: "File", fileName: "file.jpg", mimeType: "image/jpeg")
            
            // Add typeId as string
            if let typeIdData = String(typeId).data(using: .utf8) {
                multipartFormData.append(typeIdData, withName: "TypeId")
            }
        }, to: url, method: .post)
        .responseDecodable(of: UserDataUpload.self) { response in
            switch response.result {
            case .success(let uploadResponse):
                completion(.success(uploadResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
