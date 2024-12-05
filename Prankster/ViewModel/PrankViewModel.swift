//
//  PrankCreateViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 27/11/24.
//

import Foundation
import UIKit

class PrankViewModel {
    private let apiService: PrankAPIProtocol
    var isLoading = false
    var errorMessage: String?
    var createPrankLink: String?
    var createPrankName: String?
    var createPrankCoverImage: String?
    var createPrankData: String?
    var createPrankID: String?
    var createPrankResponse: PrankCreateResponse?
    
    init(apiService: PrankAPIProtocol = PrankAPIManager.shared) {
        self.apiService = apiService
    }
    
    func createPrank( coverImage: Data,coverImageURL: String,type: String,name: String,file: Data,fileURL: String,completion: @escaping (Bool) -> Void) {
        guard !isLoading else {
            completion(false)
            return
        }
        
        isLoading = true
        
        apiService.createPrank(coverImage: coverImage, coverImageURL: coverImageURL, type: type, name: name, file: file, fileURL: fileURL) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.createPrankLink = response.data.link
                    self.createPrankCoverImage = response.data.coverImage
                    self.createPrankData = response.data.file
                    self.createPrankName = response.data.name
                    self.createPrankID = response.data.id
                    self.createPrankResponse = response
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    func updatePrankName(id: String, name: String, completion: @escaping (Result<PrankNameUpdate, Error>) -> Void) {
        self.apiService.updatePrankName(id: id, name: name) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let moreApp):
                    completion(.success(moreApp))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
