//
//  MongoReport.swift
//  LocaNotes
//
//  Created by Anthony C on 4/22/21.
//

import Foundation

// MARK: - MongoReportElement
struct MongoReportElement: Codable {
    let reportId: Int32?
    let id, noteID, userID, reportTagID: String
    let createdAt, updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case reportId
        case id = "_id"
        case noteID = "noteId"
        case userID = "userId"
        case reportTagID = "reportTagId"
        case createdAt, updatedAt
        case v = "__v"
    }
}

typealias MongoReport = [MongoReportElement]
