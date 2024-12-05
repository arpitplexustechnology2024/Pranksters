//
//  CharacterAllViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import Foundation
import UIKit

// MARK: - CategoryAll ViewModel
class CategoryAllViewModel {
    private let apiService: CategoryAllAPIServiceProtocol
    var audioData: [CategoryAllData] = []
    var isLoading = false
    var hasMorePages = true
    private(set) var currentPage = 1
    var errorMessage: String?
    
    init(apiService: CategoryAllAPIServiceProtocol = CategoryAllAPIService.shared) {
        self.apiService = apiService
    }
    
    func fetchAudioData(categoryId: Int, typeId: Int, completion: @escaping (Bool) -> Void) {
        guard !isLoading && hasMorePages else {
            completion(false)
            return
        }
        
        isLoading = true
        apiService.fetchAudioData(categoryId: categoryId, typeId: typeId, page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.data.isEmpty {
                    self.hasMorePages = false
                } else {
                    self.currentPage += 1
                    self.audioData.append(contentsOf: response.data)
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
        audioData.removeAll()
        hasMorePages = true
    }
}
