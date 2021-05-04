//
//  UserViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 3/17/21.
//

import Foundation

public class UserViewModel {
    
    let userRepository: UserRepository
        
    init() {
        self.userRepository = UserRepository()
    }
    
    func createUserByMongoUser(mongoUser: MongoUserElement) -> User? {
        let serverId = mongoUser.id
        let firstName = mongoUser.firstName
        let lastName = mongoUser.lastName
        let email = mongoUser.email
        let username = mongoUser.username
        let password = mongoUser.password
        
        let createdAt = mongoUser.createdAt
        let substring = createdAt.substring(offset: 19)
        let timestamp = String(substring) + "Z"
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: timestamp)
        let unix = date?.timeIntervalSince1970
        let createdAtUnix = Int32(unix!)
                        
        do {
            try userRepository.insertUser(serverId: serverId, firstName: firstName, lastName: lastName, email: email, username: username, password: password, createdAt: createdAtUnix)
        } catch {
            print("error inserting user: \(error)")
        }
        
        return self.selectUserByUsernameAndPassword(username: username as String, password: password as String) ?? nil
    }
    
    func selectUserByUsernameAndPassword(username: String, password: String) -> User? {
        var user: User?
        do {
            user = try userRepository.selectUserByUsernameAndPassword(username: username, password: password)
        } catch {
            print("error fetching new user: \(error)")
        }
        return user
    }
    
    func mongoUserDoesExistInSqliteDatabase(mongoUserElement: MongoUserElement) -> User? {
        guard let user = selectUserByUsernameAndPassword(username: mongoUserElement.username, password: mongoUserElement.password) else {
            return nil
        }
        return user
    }
    
    func forgotPasswordSendEmail(email: String, completion: RESTService.RestLoginReturnBlock<MongoUserElement>) {
        userRepository.forgotPasswordSendEmail(email: email, completion: completion)
    }
    
    func queryUserBy(serverId: String) throws -> User? {
        return try userRepository.queryUserBy(serverId: serverId)
    }
    
    func insert(serverId: String, firstName: String, lastName: String, email: String, username: String, password: String, createdAt: Int32) throws {
        try userRepository.insertUser(serverId: serverId, firstName: firstName, lastName: lastName, email: email, username: username, password: password, createdAt: createdAt)
    }
    
    func queryAllServerUsers(completion: RESTService.RestResponseReturnBlock<[MongoUserElement]>) {
        userRepository.queryAllServerUsers(completion: completion)
    }
    
    func insertUsersFromServer(users: [MongoUserElement]) {
        for user in users {
            let tempUser = mongoUserDoesExistInSqliteDatabase(mongoUserElement: user)
            if tempUser == nil {
                createUserByMongoUser(mongoUser: user)
            }
        }
    }
    
    func getUserBy(serverId: String, completion: RESTService.RestResponseReturnBlock<[MongoUserElement]>) {
        userRepository.getUserBy(serverId: serverId, completion: completion)
    }
    
    func searchForUserBy(username: String, completion: RESTService.RestResponseReturnBlock<[MongoUserElement]>) {
        userRepository.searchForUserBy(username: username, completion: completion)
    }
    
    func getFriendListFor(userId: String, completion: RESTService.RestResponseReturnBlock<[MongoUserElement]>) {
        userRepository.getFriendListFor(userId: userId, completion: completion)
    }
    
    func addFriend(frienderId: String, friendeeId: String, completion: RESTService.RestResponseReturnBlock<MongoFriendElement>) {
        userRepository.addFriend(frienderId: frienderId, friendeeId: friendeeId, completion: completion)
    }
    
    func removeFriend(frienderId: String, friendeeId: String, completion: RESTService.RestResponseReturnBlock<MongoFriendElement>) {
        userRepository.removeFriend(frienderId: frienderId, friendeeId: friendeeId, completion: completion)
    }
    
    func checkIfFriends(frienderId: String, friendeeId: String, completion: RESTService.RestResponseReturnBlock<[MongoFriendElement]>) {
        userRepository.checkIfFriends(frienderId: frienderId, friendeeId: friendeeId, completion: completion)
    }
    
    func updateUser(radius: Double, userId: String, completion: RESTService.RestResponseReturnBlock<MongoUserElement>) {
        userRepository.updateUser(radius: radius, userId: userId, completion: completion)
    }
}
