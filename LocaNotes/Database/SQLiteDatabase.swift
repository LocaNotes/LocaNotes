//
//  SQLiteDatabase.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
    case Delete(message: String)
}

class SQLiteDatabase {
    private let dbPointer: OpaquePointer?
    private init (dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
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

extension SQLiteDatabase {
    
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
}

extension SQLiteDatabase {
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

protocol SQLTable {
    static var createStatement: String { get }
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
            
            // get longitude
            guard let queryResultCol2 =  sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                return nil
            }
            let longitude = String(cString: queryResultCol2) as NSString
            
            // get latitude
            guard let queryResultCol3 =  sqlite3_column_text(queryStatement, 3) else {
                print("Query result is nil")
                return nil
            }
            let latitude = String(cString: queryResultCol3) as NSString
            
            // get timestamp
            let timestamp = sqlite3_column_int(queryStatement, 4)
            
            // get body
            guard let queryResultCol5 =  sqlite3_column_text(queryStatement, 5) else {
                print("Query result is nil")
                return nil
            }
            let body = String(cString: queryResultCol5) as NSString
            
            notes.append(Note(noteId: noteId, userId: userId, longitude: longitude, latitude: latitude, timestamp: timestamp, body: body))
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
    
    func insertNote(userId: Int32, latitude: String, longitude: String, timestamp: Int32, body: String) throws {
        let insertSql = "INSERT INTO Note (UserId, Latitude, Longitude, Timestamp, Body) VALUES (?, ?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard
            sqlite3_bind_int(insertStatement, 1, userId) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, latitude, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, longitude, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 4, timestamp) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 5, body, -1, nil) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}
