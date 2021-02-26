//
//  DatabaseService.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation
import SQLite3

class DatabaseService {
    
    private var db: SQLiteDatabase!
    
    init() {
        
        do {
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""

            db = try SQLiteDatabase.open(path: "\(path)/locanotes_db.sqlite3")
            print("Opened connection to database: \(path)/locanotes_db.sqlite3")
            
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                
                do {
                    // create User table
                    try db.createTable(table: User.self)
                    
                    // create Note table
                    try db.createTable(table: Note.self)
                } catch {
                    print(db.errorMessage)
                }
                
                UserDefaults.standard.set(true, forKey: "is_db_created")
            }
        } catch SQLiteError.OpenDatabase(_) {
            print("Unable to open database.")
        } catch {
            print("Unable to open database: \(error.localizedDescription)")
        }
    }
}


