//
//  AudioCharacterViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import Foundation
import UIKit

// MARK: - ViewModel
class CharacterViewModel {
    private let apiService: CharacterAPIServiceProtocol
    
    var characters: [CharacterData] = []
    var reloadData: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(apiService: CharacterAPIServiceProtocol) {
        self.apiService = apiService
    }
    
    func fetchCharacters(categoryId: Int) {
        apiService.fetchCharacters(categoryId: categoryId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.characters = response.data
                self.reloadData?()
                
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
}
