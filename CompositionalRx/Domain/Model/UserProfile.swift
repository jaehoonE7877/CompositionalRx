//
//  UserProfile.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/11/02.
//

import Foundation

struct UserProfile: Codable {
    let user: User
}

struct User: Codable {
    let photo: String
    let email: String
    let username: String
}
