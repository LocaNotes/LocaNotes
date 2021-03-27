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
        let firstName = NSString(string: mongoUser.firstName)
        let lastName = NSString(string: mongoUser.lastName)
        let email = NSString(string: mongoUser.email)
        let username = NSString(string: mongoUser.username)
        let password = NSString(string: mongoUser.password)
        
        let createdAt = mongoUser.createdAt
        let index = createdAt.index(createdAt.startIndex, offsetBy: 19)
        let substring = createdAt[..<index]
        let timestamp = String(substring) + "Z"
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: timestamp)
        let unix = date?.timeIntervalSince1970
        let timeCreated = Int32(unix!)
        
        do {
            try userRepository.insertUser(firstName: firstName as String, lastName: lastName as String, email: email as String, username: username as String, password: password as String, timeCreated: timeCreated)
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
}
