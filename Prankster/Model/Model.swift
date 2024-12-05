//
//  Model.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit

// MARK: - CoverPage
struct CoverPage: Codable {
    let status: Int
    let message: String
    let data: [CoverPageData]
}
struct CoverPageData: Codable {
    let coverURL: String
    let coverName: String
    let tagName: [String]
    let coverPremium: Bool
    let itemID: Int
    
    enum CodingKeys: String, CodingKey {
        case coverURL = "CoverURL"
        case coverName = "CoverName"
        case tagName = "TagName"
        case coverPremium = "CoverPremium"
        case itemID = "ItemId"
    }
}

// MARK: - UserDataUpload
struct UserDataUpload: Codable {
    let status: Int
    let message: String
    let data: UserData
}
struct UserData: Codable {
    let coverURL: String
    
    enum CodingKeys: String, CodingKey {
        case coverURL = "CoverURL"
    }
}

// MARK: - CategoryAllResponse
struct CategoryAllResponse: Codable {
    let status: Int
    let message: String
    let data: [CategoryAllData]
}
struct CategoryAllData: Codable {
    let file: String?
    let name: String
    let image: String
    let premium: Bool
    let itemID: Int
    let artistName: String
    
    enum CodingKeys: String, CodingKey {
        case file = "File"
        case name = "Name"
        case image = "Image"
        case premium = "Premium"
        case itemID = "ItemId"
        case artistName = "ArtistName"
    }
}

// MARK: - Welcome
struct CategoryResponse: Codable {
    let status: Int
    let message: String
    let data: [CategoryData]
}
struct CategoryData: Codable {
    let categoryName: String
    let categoryImage: String
    let categoryID: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryName = "CategoryName"
        case categoryImage = "CategoryImage"
        case categoryID = "CategoryId"
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


// MARK: - prank create
struct PrankCreateResponse: Codable {
    let status: Int
    let message: String
    let data: PrankCreateData
    let file: File
}
struct PrankCreateData: Codable {
    let id: String
    let link: String
    let coverImage, file: String
    let type, name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case link = "Link"
        case coverImage = "CoverImage"
        case file = "File"
        case type = "Type"
        case name = "Name"
    }
}
struct File: Codable {
    let coverImage, file: [CoverImage]

    enum CodingKeys: String, CodingKey {
        case coverImage = "CoverImage"
        case file = "File"
    }
}
struct CoverImage: Codable {
    let fieldname, originalname, encoding, mimetype: String
    let destination, filename, path: String
    let size: Int
}

// MARK: - Prank Name Update
struct PrankNameUpdate: Codable {
    let status: Int
    let message: String
}

// MARK: - Spinner Response
struct SpinnerResponse: Codable {
    let status: Int
    let message: String
    let data: SpinnerData
}
struct SpinnerData: Codable {
    let link, coverImage, file: String
    let type, name: String
    
    enum CodingKeys: String, CodingKey {
        case link = "Link"
        case coverImage = "CoverImage"
        case file = "File"
        case type = "Type"
        case name = "Name"
    }
}
