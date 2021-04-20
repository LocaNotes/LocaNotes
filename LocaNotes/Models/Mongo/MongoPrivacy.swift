//
//  MongoPrivacy.swift
//  LocaNotes
//
//  Created by Anthony C on 4/14/21.
//

import Foundation

// MARK: - MongoPrivacyElement
struct MongoPrivacyElement: Codable {
    let id, label, createdAt, updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case label, createdAt, updatedAt
        case v = "__v"
    }
}

typealias MongoPrivacy = [MongoPrivacyElement]
