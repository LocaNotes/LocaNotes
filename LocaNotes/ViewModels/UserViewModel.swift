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
        let index = createdAt.index(createdAt.startIndex, offsetBy: 19)
        let substring = createdAt[..<index]
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
}
