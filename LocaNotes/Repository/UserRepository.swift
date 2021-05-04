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
//        self.sqliteDatabaseService = SQLiteDatabaseService()
        self.sqliteDatabaseService = SQLiteDatabaseService.shared
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
    
    func getUserBy(serverId: String, completion: RESTService.RestResponseReturnBlock<[MongoUserElement]>) {
        restService.getUserBy(serverId: serverId, completion: completion)
    }
    
    func getUserBy(email: String) throws -> User? {
        return try sqliteDatabaseService.getUserBy(email: email)
    }
    
    func forgotPasswordSendEmail(email: String, completion: RESTService.RestLoginReturnBlock<MongoUserElement>) {
        restService.forgotPasswordSendEmail(email: email, completion: completion)
    }
    
    func forgotPasswordSendTemporaryPassword(email: String, temporaryPassword: String, completion: RESTService.RestLoginReturnBlock<MongoUserElement>) {
        restService.forgotPasswordSendTemporaryPassword(email: email, temporaryPassword: temporaryPassword, completion: completion)
    }
    
    func queryUserBy(serverId: String) throws -> User? {
        return try sqliteDatabaseService.queryUserBy(serverId: serverId)
    }
    
    func queryAllServerUsers(completion: RESTService.RestResponseReturnBlock<[MongoUserElement]>) {
        restService.queryAllServerUsers(completion: completion)
    }
    
    func searchForUserBy(username: String, completion: RESTService.RestResponseReturnBlock<[MongoUserElement]>) {
        restService.searchForUserBy(username: username, completion: completion)
    }
    
    func getFriendListFor(userId: String, completion: RESTService.RestResponseReturnBlock<[MongoUserElement]>) {
        restService.getFriendListFor(userId: userId, completion: completion)
    }
    
    func addFriend(frienderId: String, friendeeId: String, completion: RESTService.RestResponseReturnBlock<MongoFriendElement>) {
        restService.addFriend(frienderId: frienderId, friendeeId: friendeeId, completion: completion)
    }
    
    func removeFriend(frienderId: String, friendeeId: String, completion: RESTService.RestResponseReturnBlock<MongoFriendElement>) {
        restService.removeFriend(frienderId: frienderId, friendeeId: friendeeId, completion: completion)
    }
    
    func checkIfFriends(frienderId: String, friendeeId: String, completion: RESTService.RestResponseReturnBlock<[MongoFriendElement]>) {
        restService.checkIfFriends(frienderId: frienderId, friendeeId: friendeeId, completion: completion)
    }
    
    func updateUser(radius: Double, userId: String, completion: RESTService.RestResponseReturnBlock<MongoUserElement>) {
        restService.updateUser(radius: radius, userId: userId, completion: completion)
    }
}
