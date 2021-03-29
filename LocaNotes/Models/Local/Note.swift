//
//  Note.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation

/**
 Represents the note table in the database
 */
struct Note {
    let noteId: Int
    let serverId: String
    let userId, privacyId, noteTagId: Int
    let title: String
    let latitude, longitude: Double
    let createdAt: Int
    let body: String
    let isStory: Int
    let downvotes, upvotes: Int
}

extension Note: SQLTable {
    
    // represents the sql statement to create the Note table
    static var createStatement: String {
        return """
            CREATE TABLE Note(
                NoteId INTEGER NOT NULL PRIMARY KEY,
                ServerId TEXT NOT NULL,
                UserId INT NOT NULL,
                NoteTagId INT NOT NULL,
                PrivacyId INT NOT NULL,
                Latitude TEXT NOT NULL,
                Longitude TEXT NOT NULL,
                CreatedAt INT NOT NULL,
                Title TEXT NOT NULL,
                Body TEXT NOT NULL,
                IsStory INT NOT NULL,
                Upvotes INT NOT NULL,
                Downvotes INT NOT NULL,
                FOREIGN KEY(UserId) REFERENCES User(UserId),
                FOREIGN KEY(NoteTagId) REFERENCES NoteTag(NoteTagId),
                FOREIGN KEY(PrivacyId) REFERENCES Privacy(PrivacyId)
            );
        """
    }
}
