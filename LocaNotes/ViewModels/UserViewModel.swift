//
//  UserViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 3/17/21.
//

import Foundation

public class UserViewModel: ObservableObject {
    
    // this user
    @Published var user: User = User(id: -1, firstName: "", lastName: "", email: "", username: "", password: "", timeCreated: -1)
    
    func setUser(userId: Int32, firstName: NSString, lastName: NSString, email: NSString, username: NSString, password: NSString, timeCreated: Int32) {
        user = User(id: userId, firstName: firstName, lastName: lastName, email: email, username: username, password: password, timeCreated: timeCreated)
    }
}
