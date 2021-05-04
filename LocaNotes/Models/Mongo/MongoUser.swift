// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let user = try? newJSONDecoder().decode(User.self, from: jsonData)

import Foundation

struct MongoUserElement: Codable {
    let id, firstName, lastName, email: String
    let username, password, createdAt, updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName, lastName, email, username, password, createdAt, updatedAt
        case v = "__v"
    }
}
