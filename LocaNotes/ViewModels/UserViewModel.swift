//
//  UserViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 3/17/21.
//

import Foundation

public class UserViewModel: ObservableObject {
            
    init(username: String, password: String) {
        do {
            user = try sqliteDatabaseService.selectUserByUsernameAndPassword(username: username, password: password) ?? User(firstName: "", lastName: "", email: "", username: "", password: "", timeCreated: -1)
        } catch {
            print("failed")
        }
    }
    
    init() {
        print("tony")
    }
    
    // this user
    @Published var user: User = User(firstName: "", lastName: "", email: "", username: "", password: "", timeCreated: -1)
    
    let sqliteDatabaseService = SQLiteDatabaseService()
    
    func setUser(userId: Int32, firstName: NSString, lastName: NSString, email: NSString, username: NSString, password: NSString, timeCreated: Int32) {
        user = User(firstName: firstName, lastName: lastName, email: email, username: username, password: password, timeCreated: timeCreated)
    }
    
    func createUserByMongoUser(mongoUser: MongoUser) {
        //let userId = Int32(-1)
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

        user = User(firstName: firstName, lastName: lastName, email: email, username: username, password: password, timeCreated: timeCreated)
        
        do {
            try sqliteDatabaseService.insertUser(firstName: firstName as String, lastName: lastName as String, email: email as String, username: username as String, password: password as String, timeCreated: timeCreated)
        } catch {
            print("error inserting user: \(error)")
        }
    }
}
