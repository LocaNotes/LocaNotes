//
//  MongoFriend.swift
//  LocaNotes
//
//  Created by Anthony C on 5/2/21.
//

import Foundation

// MARK: - MongoFriendElement
struct MongoFriendElement: Codable {
    let id, userID, friendUserID, createdAt: String
    let updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case friendUserID = "friendUserId"
        case createdAt, updatedAt
        case v = "__v"
    }
}
