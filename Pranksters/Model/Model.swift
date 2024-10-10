//
//  SideMenuModel.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 08/10/24.
//

import UIKit

// MARK: - Registration
struct Registration: Codable {
    let status: Int
    let message, token: String
}

// MARK: - MoreApp
struct MoreApp: Codable {
    let status: Int
    let message: String
    let data: [MoreData]
}
struct MoreData: Codable {
    let appName: String
    let logo: String
    let appID, packageName: String
    
    enum CodingKeys: String, CodingKey {
        case appName, logo
        case appID = "appId"
        case packageName
    }
}
