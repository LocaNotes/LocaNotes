//
//  MongoReportTag.swift
//  LocaNotes
//
//  Created by Anthony C on 4/21/21.
//

import Foundation

// MARK: - MongoReportTagElement
struct MongoReportTagElement: Codable {
    let reportTagId: Int32?
    let id, label, createdAt, updatedAt: String
    let v: Int32

    enum CodingKeys: String, CodingKey {
        case reportTagId
        case id = "_id"
        case label, createdAt, updatedAt
        case v = "__v"
    }
}

extension MongoReportTagElement: SQLTable {
    static var createStatement: String {
        return """
            CREATE TABLE ReportTag(
                ReportTagId INTEGER NOT NULL PRIMARY KEY,
                ServerId TEXT NOT NULL,
                Label TEXT NOT NULL,
                CreatedAt TEXT NOT NULL,
                UpdatedAt TEXT NOT NULL,
                V INTEGER NOT NULL
            );
        """
    }
}
