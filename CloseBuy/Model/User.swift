//
//  User.swift
//  CloseBuy
//
//  Created by Connor A Lynch on 30/08/2021.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable {
    @DocumentID var id: String?
    
    let userDetails: UserDetails
    let businessDetails: BusinessDetails?
    let profileDetails: ProfileDetails
    
    var accountCreatedAt: Timestamp = Timestamp.init()
}

struct ProfileDetails: Codable {
    var profileImageURL: String
    var bannerImageURL: String
    var caption: String
}

struct UserDetails: Codable {
    var fullname: String
    var userName: String
    var emailAddress: String
}

struct BusinessDetails: Codable {
    
}
