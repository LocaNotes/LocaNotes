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
struct MongoUserElement: Codable {
    let id, firstName, lastName, email: String
    let username, password, createdAt, updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName, lastName, email, username, password, createdAt, updatedAt
        case v = "__v"
    }
}

typealias MongoUser = [MongoUserElement]
