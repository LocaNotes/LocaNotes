//
//  ReportTag.swift
//  LocaNotes
//
//  Created by Anthony C on 3/24/21.
//

import Foundation

struct ReportTag {
    let reportTagId: Int32
    let label: NSString
}

extension ReportTag: SQLTable {
    
    // represents the sql statement to create the Note table
    static var createStatement: String {
        return """
            CREATE TABLE ReportTag(
                ReportTagId INTEGER NOT NULL PRIMARY KEY,
                Label TEXT NOT NULL
            );
        """
    }
}
