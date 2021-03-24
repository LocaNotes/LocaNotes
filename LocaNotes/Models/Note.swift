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
    let noteId: Int32
    let userId: Int32
    let noteTagId: Int32
    let privacyId: Int32
    let latitude: NSString
    let longitude: NSString
    let timeCreated: Int32 // unix
    let body: NSString
    let isStory: Int32
    let upvotes: Int32
    let downvotes: Int32
}

extension Note: SQLTable {
    
    // represents the sql statement to create the Note table
    static var createStatement: String {
        return """
            CREATE TABLE Note(
                NoteId INTEGER NOT NULL PRIMARY KEY,
                UserId INTEGER NOT NULL,
                NoteTagId INTEGER NOT NULL,
                PrivacyId INTEGER NOT NULL,
                Latitude TEXT NOT NULL,
                Longitude TEXT NOT NULL,
                TimeCreated INTEGER NOT NULL,
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
