//
//  UserRepository.swift
//  LocaNotes
//
//  Created by Anthony C on 3/27/21.
//

import Foundation

class UserRepository {
    let sqliteDatabaseService: SQLiteDatabaseService
    let restService: RESTService
    
    init() {
        self.sqliteDatabaseService = SQLiteDatabaseService()
        self.restService = RESTService()
    }
    
    func insertUser(firstName: String, lastName: String, email: String, username: String, password: String, timeCreated: Int32) throws {
        try sqliteDatabaseService.insertUser(firstName: firstName, lastName: lastName, email: email, username: username, password: password, timeCreated: timeCreated)
    }

    func selectUserByUsernameAndPassword(username: String, password: String) throws -> User? {
        return try sqliteDatabaseService.selectUserByUsernameAndPassword(username: username, password: password)
    }

    func updateUsernameFor(userId: Int) throws {
        try sqliteDatabaseService.updateUsernameFor(userId: userId)
    }

    func updateEmailFor(userId: Int) throws {
        try sqliteDatabaseService.updateEmailFor(userId: userId)
    }

    func updatePasswordFor(userId: Int) throws {
        try sqliteDatabaseService.updatePasswordFor(userId: userId)
    }
}
