//
//  Note.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation

struct Note {
    let id: Int32
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
                NoteId INT NOT NULL INDENTITY PRIMARY KEY,
                UserId INT NOT NULL FOREIGN KEY REFERENCES User(UserId),
                Latitude VARCHAR(10) NOT NULL,
                Longitude VARCHAR(10) NOT NULL,
                Timestamp INT NOT NULL,
                Body VARCHAR(500) NOT NULL
            );
        """
    }
}
