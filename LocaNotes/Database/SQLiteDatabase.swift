//
//  SQLiteDatabase.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation
import SQLite3

/**
    Used to represent error messafges from SQLite
 */
enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
    case Delete(message: String)
}

/**
    Used for accessing the database.
 */
class SQLiteDatabase {
    
    // need to use this for insertion--don't ask me why
    let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
    
    // a C pointer to the open database
    private let dbPointer: OpaquePointer?
    
    private init (dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    // computed property that holds the error message from the DB
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    /**
        Opens a connection to the SQLite database
        - Paremeter path: the path to the database on local storage
        - Throws: `SQLiteError.openDatabase` if SQLite could not open the database
        - Returns: a pointer to the database
     */
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer?
        
        // 1 attempt to open database at the provided path
        if sqlite3_open(path, &db) == SQLITE_OK  {
            
            // 2 return a new instance of SQLiteDatabase if successful
            return SQLiteDatabase(dbPointer: db)
        } else {
            
            // 3 otherwise, defer closing if the status code is anything but SQLITE_OK and throw an error
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

protocol SQLTable {
    static var createStatement: String { get }
}

extension SQLiteDatabase {
    
    /**
     Prepares a SQLite statement
     - Parameter sql: the sql string  to  be prepared
     - Throws: `SQLiteError.Prepare` if SQLite could not prepare the statement
     - Returns: a pointer to a preapared statement
     */
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
}

extension SQLiteDatabase {
    
    /**
     Creates a table in the database.
     - Parameter table: a table for the database
     - Throws: `SQLiteError.step` if SQLite could not create the table
     */
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        
        defer {
            sqlite3_finalize(createTableStatement)
        }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("\(table) table created.")
    }
}

extension SQLiteDatabase {
    
    func queryAllNotes() -> [Note]? {
        let querySql  = "SELECT * FROM Note;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        var notes: [Note] = []
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            // get note id
            let noteId = sqlite3_column_int(queryStatement, 0)
            
            // get user id
            let userId = sqlite3_column_int(queryStatement, 1)
            
            // get latitude
            guard let queryResultCol2 =  sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                return nil
            }
            let latitude = String(cString: queryResultCol2) as NSString
            
            // get longitude
            guard let queryResultCol3 =  sqlite3_column_text(queryStatement, 3) else {
                print("Query result is nil")
                return nil
            }
            let longitude = String(cString: queryResultCol3) as NSString
            
            // get timestamp
            let timeCreated = sqlite3_column_int(queryStatement, 4)
            
            // get body
            guard let queryResultCol5 =  sqlite3_column_text(queryStatement, 5) else {
                print("Query result is nil")
                return nil
            }
            let body = String(cString: queryResultCol5) as NSString
            
            // get isStory
            let isStory = sqlite3_column_int(queryStatement, 6)
            
            // get upvotes
            let upvotes = sqlite3_column_int(queryStatement, 7)
            
            // get downvotes
            let downvotes = sqlite3_column_int(queryStatement, 8)
            
            let note = Note(
                noteId: noteId,
                userId: userId,
                latitude: latitude,
                longitude: longitude,
                timeCreated: timeCreated,
                body: body,
                isStory: isStory,
                upvotes: upvotes,
                downvotes: downvotes
            )
            
            notes.append(note)
        }
        return notes
    }
}

extension SQLiteDatabase {
    
    func deleteNoteById(id: Int32) throws {
        
        let deleteStatementString = "DELETE FROM Note WHERE NoteId = ?;"
                
        guard let deleteStatement = try? prepareStatement(sql: deleteStatementString) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        defer {
            sqlite3_finalize(deleteStatement)
        }
        
        // bind the id to the statement (1-based index)
        sqlite3_bind_int(deleteStatement, 1, id)
        
        if sqlite3_step(deleteStatement) != SQLITE_DONE {
            throw SQLiteError.Delete(message: errorMessage)
        }
    }
}

extension SQLiteDatabase {
    
    func insertNote(userId: Int32, latitude: String, longitude: String, timestamp: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32) throws {
        let insertSql = "INSERT INTO Note (UserId, Latitude, Longitude, TimeCreated, Body, IsStory, Upvotes, Downvotes) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard
            sqlite3_bind_int(insertStatement, 1, userId) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, latitude, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, longitude, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 4, timestamp) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 5, body, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 6, isStory) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 7, upvotes) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 8, downvotes) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}

extension SQLiteDatabase {
    
    func updateNoteBody(noteId: Int32, body: String) throws {
        let updateSql = "UPDATE Note SET Body = ? WHERE NoteId = ?;"
        let updateStatement = try prepareStatement(sql: updateSql)
        defer {
            sqlite3_finalize(updateStatement)
        }
        guard
            sqlite3_bind_text(updateStatement, 1, body, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(updateStatement, 2, noteId) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}

extension SQLiteDatabase {
    
    func insertUser(firstName: String, lastName: String, email: String, username: String, password: String, timeCreated: Int32) throws {
        
        let insertSql = "INSERT INTO User (FirstName, LastName, Email, Username, Password, TimeCreated) VALUES (?, ?, ?, ?, ?, ?);"
        
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard
            sqlite3_bind_text(insertStatement, 1, firstName, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, lastName, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, email, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, username, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 5, password, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 6, timeCreated) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}

extension SQLiteDatabase {
    
    func selectUserByUsernameAndPassword(username: String, password: String) throws -> User? {
        let querySql = "SELECT * FROM User WHERE Username LIKE ? AND Password LIKE ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard
            sqlite3_bind_text(queryStatement, 1, username, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(queryStatement, 2, password, -1, SQLITE_TRANSIENT) == SQLITE_OK 
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        var user: User
        
        if sqlite3_step(queryStatement) == SQLITE_ROW {
            
            let id = sqlite3_column_int(queryStatement, 0)
            
            guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                print("Query result is nil")
                return nil
            }
            let firstName = String(cString: queryResultCol1) as NSString
            
            guard let queryResultCol2 = sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                return nil
            }
            let lastName = String(cString: queryResultCol2) as NSString
            
            guard let queryResultCol3 = sqlite3_column_text(queryStatement, 3) else {
                print("Query result is nil")
                return nil
            }
            let email = String(cString: queryResultCol3) as NSString
            
//            guard let queryResultCol4 = sqlite3_column_text(queryStatement, 4) else {
//                print("Query result is nil")
//                return
//            }
//            let username = String(cString: queryResultCol4) as NSString
//
//            guard let queryResultCol5 = sqlite3_column_text(queryStatement, 5) else {
//                print("Query result is nil")
//                return
//            }
//            let password = String(cString: queryResultCol5) as NSString
            
            let timeCreated = sqlite3_column_int(queryStatement, 6)
            
            user = User(userId: id, firstName: firstName, lastName: lastName, email: email, username: username as NSString, password: password as NSString, timeCreated: timeCreated)
        } else {
            throw SQLiteError.Step(message: errorMessage)
        }
        return user
    }
}

extension SQLiteDatabase {
    
    func queryNotesBy(userId: Int32) throws -> [Note] {
        let querySql = "SELECT * FROM Note WHERE UserId = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, userId) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        var notes: [Note] = []
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            // get note id
            let noteId = sqlite3_column_int(queryStatement, 0)
            
            // get user id
            let userId = sqlite3_column_int(queryStatement, 1)
            
            // get latitude
            guard let queryResultCol2 =  sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let latitude = String(cString: queryResultCol2) as NSString
            
            // get longitude
            guard let queryResultCol3 =  sqlite3_column_text(queryStatement, 3) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let longitude = String(cString: queryResultCol3) as NSString
            
            // get timestamp
            let timeCreated = sqlite3_column_int(queryStatement, 4)
            
            // get body
            guard let queryResultCol5 =  sqlite3_column_text(queryStatement, 5) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let body = String(cString: queryResultCol5) as NSString
            
            // get isStory
            let isStory = sqlite3_column_int(queryStatement, 6)
            
            // get upvotes
            let upvotes = sqlite3_column_int(queryStatement, 7)
            
            // get downvotes
            let downvotes = sqlite3_column_int(queryStatement, 8)
            
            let note = Note(
                noteId: noteId,
                userId: userId,
                latitude: latitude,
                longitude: longitude,
                timeCreated: timeCreated,
                body: body,
                isStory: isStory,
                upvotes: upvotes,
                downvotes: downvotes
            )
            
            notes.append(note)
        }
        return notes
    }
}
