//
//  MongoNote.swift
//  LocaNotes
//
//  Created by Anthony C on 3/29/21.
//

import Foundation

// MARK: - NoteElement
struct MongoNoteElement: Codable {
    let id, userID, privacyID, noteTagID: String
    let title: String
    let latitude, longitude: Double
    let body: String
    let isStory: Bool
    let downvotes, upvotes: Int
    let createdAt, updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case privacyID = "privacyId"
        case noteTagID = "noteTagId"
        case title, latitude, longitude, body, isStory, downvotes, upvotes, createdAt, updatedAt
        case v = "__v"
    }
}
