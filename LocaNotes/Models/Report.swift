//
//  Report.swift
//  LocaNotes
//
//  Created by Anthony C on 3/24/21.
//

import Foundation

struct Report {
    let reportId: Int32
    let noteId: Int32
    let userId: Int32
    let reportTagId: Int32
    let timeReported: Int32
}

extension Report: SQLTable {
    
    // represents the sql statement to create the Note table
    static var createStatement: String {
        return """
            CREATE TABLE Report(
                ReportId INTEGER NOT NULL PRIMARY KEY,
                NoteId INTEGER NOT NULL,
                UserId INTEGER NOT NULL,
                ReportTagId INTEGER NOT NULL,
                TimeReported INTEGER NOT NULL,
                FOREIGN KEY(NoteId) REFERENCES Note(NoteId),
                FOREIGN KEY(UserId) REFERENCES User(UserId),
                FOREIGN KEY(ReportTagId) REFERENCES ReportTag(ReportTagId)
            );
        """
    }
}
