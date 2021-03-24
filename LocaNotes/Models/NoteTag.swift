//
//  NoteTag.swift
//  LocaNotes
//
//  Created by Anthony C on 3/24/21.
//

import Foundation

struct NoteTag {
    let noteTagId: Int32
    let label: NSString
}

extension NoteTag: SQLTable {
    
    static var createStatement: String {
        return """
            CREATE TABLE NoteTag(
                NoteTagId INTEGER NOT NULL PRIMARY KEY,
                Label TEXT NOT NULL
            );
        """
    }
}
