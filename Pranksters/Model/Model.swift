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

// MARK: - CoverPage
struct CoverPage: Codable {
    let status: Int
    let message: String
    let data: [CoverPageData]
}
struct CoverPageData: Codable {
    let coverURL: String
    let coverPremium: Bool
    let itemID: Int
    var isFavorite: Bool

    enum CodingKeys: String, CodingKey {
        case coverURL = "CoverURL"
        case coverPremium = "CoverPremium"
        case itemID = "ItemId"
        case isFavorite
    }
}

// MARK: - FavouriteSet
struct FavouriteSet: Codable {
    let status: Int
    let message: String
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
