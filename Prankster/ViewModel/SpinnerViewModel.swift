//
//  SpinnerViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 30/11/24.
//

import Foundation

// MARK: - SpinViewModel
class SpinnerViewModel {
    private let spinService: SpinnerAPIProtocol
    var onDataUpdate: ((SpinnerResponse?) -> Void)?
    var onError: ((String) -> Void)?
    
    init(spinService: SpinnerAPIManger = SpinnerAPIManger()) {
        self.spinService = spinService
    }
    
    func postSpinData(typeId: String) {
        spinService.postSpin(typeId: typeId) { [weak self] result in
            switch result {
            case .success(let response):
                self?.onDataUpdate?(response)
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
}
