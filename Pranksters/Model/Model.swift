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

// MARK: - CharacterResponse
struct CharacterResponse: Codable {
    let status: Int
    let message: String
    let data: [CharacterData]
}
struct CharacterData: Codable {
    let characterName: String
    let characterImage: String
    let characterID: Int

    enum CodingKeys: String, CodingKey {
        case characterName = "CharacterName"
        case characterImage = "CharacterImage"
        case characterID = "CharacterId"
    }
}

// MARK: - CharacterAllResponse
struct CharacterAllResponse: Codable {
    let status: Int
    let message: String
    let data: [CharacterAllData]
}
struct CharacterAllData: Codable {
    let file: String?
    let name: String
    let image: String
    let premium: Bool
    let itemID: Int
    var isFavorite: Bool

    enum CodingKeys: String, CodingKey {
        case file = "File"
        case name = "Name"
        case image = "Image"
        case premium = "Premium"
        case itemID = "ItemId"
        case isFavorite
    }
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
