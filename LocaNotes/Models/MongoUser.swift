//
//  MongoUser.swift
//  LocaNotes
//
//  Created by Anthony C on 3/16/21.
//

import Foundation

/**
 Represents a user from the MongoDB database
 */
struct MongoUser: Codable {
    let _id: String
    let firstName: String
    let lastName: String
    let email: String
    let username: String
    let password: String
    let createdAt: String
    let updatedAt: String
    let __v: Int
}
