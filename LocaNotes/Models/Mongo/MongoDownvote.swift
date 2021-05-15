//
//  MongoDownvote.swift
//  LocaNotes
//
//  Created by Anthony C on 4/20/21.
//
import Foundation

// MARK: - MongoDownvote
struct MongoDownvoteElement: Codable {
    let downvoteId: Int32?
    let id, userID, noteID, createdAt: String
    let updatedAt: String
    let v: Int32

    enum CodingKeys: String, CodingKey {
        case downvoteId
        case id = "_id"
        case userID = "userId"
        case noteID = "noteId"
        case createdAt, updatedAt
        case v = "__v"
    }
}

extension MongoDownvoteElement: SQLTable {
    
    // represents the sql statement to create the Note table
    static var createStatement: String {
        return """
            CREATE TABLE Downvote(
                DownvoteId INTEGER NOT NULL PRIMARY KEY,
                ServerId TEXT NOT NULL,
                UserServerId TEXT NOT NULL,
                NoteServerId TEXT NOT NULL,
                CreatedAt TEXT NOT NULL,
                UpdatedAt TEXT NOT NULL,
                V INTEGER NOT NULL,
                FOREIGN KEY(UserServerId) REFERENCES User(ServerId),
                FOREIGN KEY(NoteServerId) REFERENCES Note(ServerId)
            );
        """
    }
}
