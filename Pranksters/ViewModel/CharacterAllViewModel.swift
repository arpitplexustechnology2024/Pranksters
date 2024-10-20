//
//  CharacterAllViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import Foundation
import UIKit

// MARK: - Audio ViewModel
class CharacterAllViewModel {
    private let apiService: ChracterAllAPIServiceProtocol
    var audioData: [CharacterAllData] = []
    var reloadData: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(apiService: ChracterAllAPIServiceProtocol) {
        self.apiService = apiService
    }
    
    func fetchAudioData(categoryId: Int, characterId: Int) {
        apiService.fetchAudioData(categoryId: categoryId, characterId: characterId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.audioData = response.data
                self.reloadData?()
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
}
