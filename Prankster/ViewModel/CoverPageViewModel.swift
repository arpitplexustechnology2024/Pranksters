//
//  CoverPageViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 10/10/24.
//

import Foundation

class EmojiViewModel {
    private let apiService: EmojiAPIServiceProtocol
    private(set) var currentPage = 1
    var isLoading = false
    var emojiCoverPages: [CoverPageData] = []
    var errorMessage: String?
    var hasMorePages = true
    
    init(apiService: EmojiAPIServiceProtocol = EmojiAPIService.shared) {
        self.apiService = apiService
    }
    
    func fetchEmojiCoverPages(completion: @escaping (Bool) -> Void) {
        guard !isLoading && hasMorePages else {
            completion(false)
            return
        }
        
        isLoading = true
        
        apiService.fetchCoverPages(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let coverPageResponse):
                if coverPageResponse.data.isEmpty {
                    self.hasMorePages = false
                } else {
                    self.currentPage += 1
                    self.emojiCoverPages.append(contentsOf: coverPageResponse.data)
                }
                completion(true)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
    
    func resetPagination() {
        currentPage = 1
        emojiCoverPages.removeAll()
        hasMorePages = true
    }
}

class RealisticViewModel {
    private let apiService: RealisticAPIServiceProtocol
    private(set) var currentPage = 1
    var isLoading = false
    var realisticCoverPages: [CoverPageData] = []
    var errorMessage: String?
    var hasMorePages = true
    
    init(apiService: RealisticAPIServiceProtocol = RealisticAPIService.shared) {
        self.apiService = apiService
    }
    
    func fetchRealisticCoverPages(completion: @escaping (Bool) -> Void) {
        guard !isLoading && hasMorePages else {
            completion(false)
            return
        }
        
        isLoading = true
        
        apiService.fetchRealisticCoverPages(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let coverPageResponse):
                if coverPageResponse.data.isEmpty {
                    self.hasMorePages = false
                } else {
                    self.currentPage += 1
                    self.realisticCoverPages.append(contentsOf: coverPageResponse.data)
                }
                completion(true)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
    
    func resetPagination() {
        currentPage = 1
        realisticCoverPages.removeAll()
        hasMorePages = true
    }
}

// MARK: - FileUploadViewModel
class FileUploadViewModel {
    private let apiService: FileUploadAPIServiceProtocol
    var isLoading = false
    var errorMessage: String?
    var uploadedCoverURL: String?
    
    init(apiService: FileUploadAPIServiceProtocol = FileUploadAPIService.shared) {
        self.apiService = apiService
    }
    
    func uploadFile(fileData: Data, typeId: Int, completion: @escaping (Bool) -> Void) {
        guard !isLoading else {
            completion(false)
            return
        }
        
        isLoading = true
        
        apiService.uploadFile(file: fileData, typeId: typeId) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.uploadedCoverURL = response.data.coverURL
                completion(true)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
}
