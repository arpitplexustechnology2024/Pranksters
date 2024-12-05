//
//  MoreAppViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import Foundation

class MoreAppViewModel {
    private let apiService: MoreAppApiServiceProtocol
    var moreApp: MoreApp?
    
    init(apiService: MoreAppApiServiceProtocol = MoreAppAPIService.shared) {
        self.apiService = apiService
    }
    
    func fetchMoreData(packageName: String, completion: @escaping (Result<[MoreData], Error>) -> Void) {
        
        let language: String
        if #available(iOS 16.0, *) {
            language = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            language = Locale.current.languageCode ?? "en"
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.apiService.postMoreData(packageName: packageName, language: language) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let moreApp):
                        self.moreApp = moreApp
                        completion(.success(moreApp.data))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
