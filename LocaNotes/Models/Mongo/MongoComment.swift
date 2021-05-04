//
//  MongoComment.swift
//  LocaNotes
//
//  Created by Anthony C on 4/14/21.
//

import Foundation

// MARK: - MongoCommentElement
struct MongoCommentElement: Codable {
    let id, userID, noteID, body: String
    let createdAt, updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case noteID = "noteId"
        case body, createdAt, updatedAt
        case v = "__v"
    }
}
