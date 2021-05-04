//
//  MongoShare.swift
//  LocaNotes
//
//  Created by Anthony C on 5/3/21.
//

import Foundation

// MARK: - MongoShareElement
struct MongoShareElement: Codable, SQLTable {
    let shareId: Int?
    let id, noteID, receiverID, createdAt: String
    let updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case shareId
        case id = "_id"
        case noteID = "noteId"
        case receiverID = "receiverId"
        case createdAt, updatedAt
        case v = "__v"
    }
    
    static var createStatement: String {
        return """
            CREATE TABLE Share(
                ShareId INTEGER NOT NULL PRIMARY KEY,
                ServerId TEXT NOT NULL,
                NoteId TEXT NOT NULL,
                ReceiverId TEXT NOT NULL,
                CreatedAt TEXT NOT NULL,
                UpdatedAt TEXT NOT NULL,
                V INTEGER NOT NULL
            );
        """
    }
}
