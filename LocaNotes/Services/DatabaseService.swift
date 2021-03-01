//
//  DatabaseService.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation
import SQLite3

public class DatabaseService {
    
    private var db: SQLiteDatabase!
    
    init() {
        
        do {
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""

            db = try SQLiteDatabase.open(path: "\(path)/locanotes_db.sqlite3")
            print("Opened connection to database: \(path)/locanotes_db.sqlite3")
//            UserDefaults.standard.set(false, forKey: "is_db_created")
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                print("Creating db...")
                
                do {
                    // create User table
                    try db.createTable(table: User.self)
                    
                    // create Note table
                    try db.createTable(table: Note.self)
                    
                    UserDefaults.standard.set(true, forKey: "is_db_created")
                } catch {
                    print(db.errorMessage)
                    return
                }
                
                print("Made db.")
            }
        } catch SQLiteError.OpenDatabase(_) {
            print("Unable to open database.")
        } catch {
            print("Unable to open database: \(error.localizedDescription)")
        }
    }
    
    func queryAllNotes() -> [Note]? {
        return db.queryAllNotes()
    }
    
    func deleteNoteById(id: Int32) throws {
        try db.deleteNoteById(id: id)
    }
    
    func insertNote(latitude: String, longitude: String, timestamp: Int32, body: String) throws {
        try db.insertNote(userId: 1, latitude: latitude, longitude: longitude, timestamp: timestamp, body: body)
    }
}


