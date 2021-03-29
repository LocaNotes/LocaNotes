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
    
    func insertUser(serverId: String, firstName: String, lastName: String, email: String, username: String, password: String, createdAt: Int32) throws {
        try sqliteDatabaseService.insertUser(serverId: serverId, firstName: firstName, lastName: lastName, email: email, username: username, password: password, createdAt: createdAt)
    }

    func selectUserByUsernameAndPassword(username: String, password: String) throws -> User? {
        return try sqliteDatabaseService.selectUserByUsernameAndPassword(username: username, password: password)
    }

    func updateUsernameFor(userId: Int32, username: String) throws {
        try sqliteDatabaseService.updateUsernameFor(userId: userId, username: username)
    }

    func updateEmailFor(userId: Int32, email: String) throws {
        print("line 32")
        try sqliteDatabaseService.updateEmailFor(userId: userId, email: email)
    }

    func updatePasswordFor(userId: Int32, password: String) throws {
        try sqliteDatabaseService.updatePasswordFor(userId: userId, password: password)
    }
    
    func getUserBy(userId: Int32) throws -> User? {
        return try sqliteDatabaseService.getUserBy(userId: userId)
    }
}
