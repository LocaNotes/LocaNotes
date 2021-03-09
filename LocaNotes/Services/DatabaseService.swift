//
//  DatabaseService.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation
import SQLite3

/**
 A service used by other classes to access the database.
 */
public class DatabaseService {
    
    // a reference to the database
    private var db: SQLiteDatabase!
    
    init() {
        
        do {
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""

            // try to open a connection to the database
            db = try SQLiteDatabase.open(path: "\(path)/locanotes_db.sqlite3")
            print("Opened connection to database: \(path)/locanotes_db.sqlite3")
            
//            UserDefaults.standard.set(false, forKey: "is_db_created")
            
            // create a database if one hasn't been created
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                print("Creating db...")
                
                do {
                    // create User table
                    try db.createTable(table: User.self)
                    
                    // create Note table
                    try db.createTable(table: Note.self)
                    
                    // set a key saying that the database is made (prevent a new DB getting created every time)
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
    
    /**
     Queries all notes from the database
     - Returns: a list of notes or nothing
     */
    func queryAllNotes() -> [Note]? {
        return db.queryAllNotes()
    }
    
    /**
     Deletes the note in the database specified by the id
     - Parameter id: the id of the note that should be deleted
     - Throws: `SQLiteError.Delete` if the note wasn't deleted
     */
    func deleteNoteById(id: Int32) throws {
        try db.deleteNoteById(id: id)
    }
    
    /**
     Inserts a note with the specified information into the database
     - Parameters:
        - latitude: the latitude of the note
        - longitude: the longitude of the note
        - timestamp: the time that the user tapped "finish"
        - body: the content of the node
     - Throws: `SQLiteError.Insert` if the note could not be inserted
     */
    func insertNote(latitude: String, longitude: String, timestamp: Int32, body: String) throws {
        try db.insertNote(userId: 1, latitude: latitude, longitude: longitude, timestamp: timestamp, body: body)
    }
}


