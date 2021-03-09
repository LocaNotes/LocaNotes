//
//  User.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation

/**
 Represents the User table in the database
 */
struct User {
    let id: Int32
    let firstName: NSString
    let lastName: NSString
    let email: NSString
    let username: NSString
    let password: NSString
}

extension User: SQLTable {
    
    // represents the sql statement to create the User table
    static var createStatement: String {
        return """
            CREATE TABLE User(
                UserId INTEGER NOT NULL PRIMARY KEY,
                FirstName VARCHAR(20) NOT NULL,
                LastName VARCHAR(20) NOT NULL,
                Email VARCHAR(40) NOT NULL,
                Username VARCHAR(40) NOT NULL,
                Password VARCHAR(40) NOT NULL
            );
        """
    }
}
