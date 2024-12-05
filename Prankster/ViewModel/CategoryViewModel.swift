//
//  AudioCharacterViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import Foundation
import UIKit

// MARK: - ViewModel
class CategoryViewModel {
    private let apiService: CategoryAPIServiceProtocol
    
    var categorys: [CategoryData] = []
    var reloadData: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(apiService: CategoryAPIServiceProtocol) {
        self.apiService = apiService
    }
    
    func fetchCategorys(typeId: Int) {
        apiService.fetchCategorys(typeId: typeId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.categorys = response.data
                self.reloadData?()
                
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
}
