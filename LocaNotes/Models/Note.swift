//
//  Note.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation

struct Note {
    let noteId: Int32
    let userId: Int32
    let longitude: NSString
    let latitude: NSString
    let timestamp: Int32 // unix
    let body: NSString
}

extension Note: SQLTable {
    static var createStatement: String {
        return """
            CREATE TABLE Note(
                NoteId INTEGER NOT NULL PRIMARY KEY,
                UserId INTEGER NOT NULL,
                Latitude VARCHAR(10) NOT NULL,
                Longitude VARCHAR(10) NOT NULL,
                Timestamp INT NOT NULL,
                Body VARCHAR(500) NOT NULL,
                FOREIGN KEY(UserId) REFERENCES User(UserId)
            );
        """
    }
}
