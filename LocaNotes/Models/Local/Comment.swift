//
//  Comment.swift
//  LocaNotes
//
//  Created by Anthony C on 3/24/21.
//

import Foundation

struct Comment {
    let commentId: Int32
    let noteId: Int32
    let userId: Int32
    let body: NSString
    let timeCommented: Int32 
}

extension Comment: SQLTable {
    
    // represents the sql statement to create the Note table
    static var createStatement: String {
        return """
            CREATE TABLE Comment(
                CommentId INTEGER NOT NULL PRIMARY KEY,
                NoteId INTEGER NOT NULL,
                UserId INTEGER NOT NULL,
                Body TEXT NOT NULL,
                TimeCommented INTEGER NOT NULL,
                FOREIGN KEY(NoteId) REFERENCES Note(NoteId),
                FOREIGN KEY(UserId) REFERENCES User(UserId)
            );
        """
    }
}
