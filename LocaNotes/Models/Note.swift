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
    let latitude: NSString
    let longitude: NSString
    let timestamp: Int32 // unix
    let body: NSString
}

extension Note: SQLTable {
    
    // represents the sql statement to create the Note table
    static var createStatement: String {
//        return """
//            CREATE TABLE Note(
//                NoteId INTEGER NOT NULL PRIMARY KEY,
//                UserId INTEGER NOT NULL,
//                Latitude VARCHAR(20) NOT NULL,
//                Longitude VARCHAR(20) NOT NULL,
//                Timestamp INT NOT NULL,
//                Body VARCHAR(500) NOT NULL,
//                FOREIGN KEY(UserId) REFERENCES User(UserId)
//            );
//        """
        return """
            CREATE TABLE Note(
                NoteId INTEGER NOT NULL PRIMARY KEY,
                UserId INTEGER NOT NULL,
                Latitude TEXT NOT NULL,
                Longitude TEXT NOT NULL,
                Timestamp INTEGER NOT NULL,
                Body TEXT NOT NULL,
                FOREIGN KEY(UserId) REFERENCES User(UserId)
            );
        """
    }
}
