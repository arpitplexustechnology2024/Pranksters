//
//  RegistrationViewModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 09/10/24.
//

import Foundation

class RegistrationViewModel {
    private let apiService: RegisterApiServiceProtocol
    var registrationResponse: Registration?
    var errorMessage: String?
    
    init(apiService: RegisterApiServiceProtocol = RegisterAPIService.shared) {
        self.apiService = apiService
    }

    func isUserRegistered() -> Bool {
        return UserDefaults.standard.bool(forKey: "isUserRegistered")
    }

    func markUserAsRegistered() {
        UserDefaults.standard.set(true, forKey: "isUserRegistered")
    }

    func saveUserToken(token: String) {
        UserDefaults.standard.set(token, forKey: "userToken")
    }

    func clearUserToken() {
        UserDefaults.standard.removeObject(forKey: "userToken")
    }
    
    func registerUserIfNeeded(completion: @escaping (Bool) -> Void) {
        if isUserRegistered() {
            completion(false)
            return
        }
        
        RegisterAPIService.shared.registerUser(premium: false) { result in
            switch result {
            case .success(let response):
                self.registrationResponse = response
                if response.status == 1 {
                    self.saveUserToken(token: response.token)
                    self.markUserAsRegistered()
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }

    func getUserToken() -> String? {
        return UserDefaults.standard.string(forKey: "userToken")
    }
}
