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
    let userId: Int32
    let serverId: String
    let firstName, lastName, email: String
    let username, password: String
    let createdAt: Int32
}

extension User: SQLTable {
    
    // represents the sql statement to create the User table
    static var createStatement: String {
        return """
            CREATE TABLE User(
                UserId INTEGER NOT NULL PRIMARY KEY,
                ServerId INTEGER NOT NULL,
                FirstName VARCHAR(20) NOT NULL,
                LastName VARCHAR(20) NOT NULL,
                Email VARCHAR(40) NOT NULL,
                Username VARCHAR(40) NOT NULL,
                Password VARCHAR(40) NOT NULL,
                CreatedAt INTEGER NOT NULL
            );
        """
    }
}
