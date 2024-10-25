//
//  FavouriteViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 14/10/24.
//

import Foundation

class FavoriteViewModel {
    private let apiService: FavoriteAPIServiceProtocol
    
    var favourites: [FavouriteAllData] = []
    var reloadData: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(apiService: FavoriteAPIServiceProtocol = FavoriteAPIService.shared) {
        self.apiService = apiService
    }
    
    func setFavorite(itemId: Int, isFavorite: Bool, categoryId: Int, completion: @escaping (Bool, String?) -> Void) {
        apiService.setFavorite(itemId: itemId, isFavorite: isFavorite, categoryId: categoryId) { result in
            switch result {
            case .success(let response):
                completion(true, response.message)
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    func setAllFavourite(categoryId: Int) {
        apiService.setAllFavorite(categoryId: categoryId) { result in
            switch result {
            case .success(let response):
                self.favourites = response.data
                self.reloadData?()
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
}
