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
    
    func insertNoteTag(label: String) throws {
        let insertSql = "INSERT INTO NoteTag (Label) VALUES (?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard
            sqlite3_bind_text(insertStatement, 1, label, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    func insertPrivacy(label: String) throws {
        let insertSql = "INSERT INTO Privacy (Label) VALUES (?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard
            sqlite3_bind_text(insertStatement, 1, label, -1, SQLITE_TRANSIENT) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
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
    
    func queryAllNotes() throws -> [Note]? {
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

            // get server id
            guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let serverId = String(cString: queryResultCol1)

            // get user server id
            guard let queryResultCol2 = sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let userServerId = String(cString: queryResultCol2)

            // get user id
            let userId = sqlite3_column_int(queryStatement, 3)

            // get note tag id
            let noteTagId = sqlite3_column_int(queryStatement, 4)

            // get privacy id
            let privacyId = sqlite3_column_int(queryStatement, 5)

            // get latitude
            guard let queryResultCol6 = sqlite3_column_text(queryStatement, 6) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let latitude = String(cString: queryResultCol6)

            // get longitude
            guard let queryResultCol7 = sqlite3_column_text(queryStatement, 7) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let longitude = String(cString: queryResultCol7)

            // get timestamp
            let createdAt = sqlite3_column_int(queryStatement, 8)
            
            // get title
            guard let queryResultCol9 = sqlite3_column_text(queryStatement, 9) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let title = String(cString: queryResultCol9)

            // get body
            guard let queryResultCol10 = sqlite3_column_text(queryStatement, 10) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let body = String(cString: queryResultCol10)

            // get isStory
            let isStory = sqlite3_column_int(queryStatement, 11)

            // get upvotes
            let upvotes = sqlite3_column_int(queryStatement, 12)

            // get downvotes
            let downvotes = sqlite3_column_int(queryStatement, 13)
            
            let note = Note(
                noteId: noteId,
                serverId: serverId,
                userServerId: userServerId,
                userId: userId,
                privacyId: privacyId,
                noteTagId: noteTagId,
                title: title, 
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                body: body,
                isStory: isStory,
                downvotes: downvotes,
                upvotes: upvotes
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
    
    func insertNote(serverId: String, userServerId: String, userId: Int32, noteTagId: Int32, privacyId: Int32, latitude: String, longitude: String, createdAt: Int32, title: String, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32) throws {
        let insertSql = "INSERT INTO Note (ServerId, UserServerId, UserId, NoteTagId, PrivacyId, Latitude, Longitude, CreatedAt, Title, Body, IsStory, Upvotes, Downvotes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard
            sqlite3_bind_text(insertStatement, 1, serverId, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, userServerId, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 3, userId) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 4, noteTagId) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 5, privacyId) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 6, latitude, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 7, longitude, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 8, createdAt) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 9, title, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 10, body, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 11, isStory) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 12, upvotes) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 13, downvotes) == SQLITE_OK
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
    
    func insertUser(serverId: String, firstName: String, lastName: String, email: String, username: String, password: String, createdAt: Int32) throws {
        
        let insertSql = "INSERT INTO User (ServerId, FirstName, LastName, Email, Username, Password, CreatedAt) VALUES (?, ?, ?, ?, ?, ?, ?);"
        
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard
            sqlite3_bind_text(insertStatement, 1, serverId, -1, SQLITE_TRANSIENT) ==  SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 2, firstName, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, lastName, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, email, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 5, username, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 6, password, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 7, createdAt) == SQLITE_OK
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
            let serverId = String(cString: queryResultCol1)
            
            guard let queryResultCol2 = sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                return nil
            }
            let firstName = String(cString: queryResultCol2)
            
            guard let queryResultCol3 = sqlite3_column_text(queryStatement, 3) else {
                print("Query result is nil")
                return nil
            }
            let lastName = String(cString: queryResultCol3)
            
            guard let queryResultCol4 = sqlite3_column_text(queryStatement, 4) else {
                print("Query result is nil")
                return nil
            }
            let email = String(cString: queryResultCol4)
            
//            guard let queryResultCol4 = sqlite3_column_text(queryStatement, 5) else {
//                print("Query result is nil")
//                return
//            }
//            let username = String(cString: queryResultCol4) as NSString
//
//            guard let queryResultCol5 = sqlite3_column_text(queryStatement, 6) else {
//                print("Query result is nil")
//                return
//            }
//            let password = String(cString: queryResultCol5) as NSString
            
            let createdAt = sqlite3_column_int(queryStatement, 7)
            
            user = User(userId: id, serverId: serverId, firstName: firstName, lastName: lastName, email: email, username: username, password: password, createdAt: createdAt)
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

            // get server id
            guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let serverId = String(cString: queryResultCol1)

            // get user server id
            guard let queryResultCol2 = sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let userServerId = String(cString: queryResultCol2)

            // get user id
            let userId = sqlite3_column_int(queryStatement, 3)

            // get note tag id
            let noteTagId = sqlite3_column_int(queryStatement, 4)

            // get privacy id
            let privacyId = sqlite3_column_int(queryStatement, 5)

            // get latitude
            guard let queryResultCol6 = sqlite3_column_text(queryStatement, 6) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let latitude = String(cString: queryResultCol6)

            // get longitude
            guard let queryResultCol7 = sqlite3_column_text(queryStatement, 7) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let longitude = String(cString: queryResultCol7)

            // get timestamp
            let createdAt = sqlite3_column_int(queryStatement, 8)
            
            // get title
            guard let queryResultCol9 = sqlite3_column_text(queryStatement, 9) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let title = String(cString: queryResultCol9)

            // get body
            guard let queryResultCol10 = sqlite3_column_text(queryStatement, 10) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let body = String(cString: queryResultCol10)

            // get isStory
            let isStory = sqlite3_column_int(queryStatement, 11)

            // get upvotes
            let upvotes = sqlite3_column_int(queryStatement, 12)

            // get downvotes
            let downvotes = sqlite3_column_int(queryStatement, 13)
            
            let note = Note(
                noteId: noteId,
                serverId: serverId,
                userServerId: userServerId,
                userId: userId,
                privacyId: privacyId,
                noteTagId: noteTagId,
                title: title,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                body: body,
                isStory: isStory,
                downvotes: downvotes,
                upvotes: upvotes
            )
            
            notes.append(note)
        }
        return notes
    }
    
    func queryNoteBy(noteId: Int32) throws -> Note? {
        let querySql = "SELECT * FROM Note WHERE NoteId = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, noteId) == SQLITE_OK else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        var note: Note? = nil
        if sqlite3_step(queryStatement) == SQLITE_ROW {

            // get note id
            let noteId = sqlite3_column_int(queryStatement, 0)

            // get server id
            guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let serverId = String(cString: queryResultCol1)

            // get user server id
            guard let queryResultCol2 = sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let userServerId = String(cString: queryResultCol2)

            // get user id
            let userId = sqlite3_column_int(queryStatement, 3)

            // get note tag id
            let noteTagId = sqlite3_column_int(queryStatement, 4)

            // get privacy id
            let privacyId = sqlite3_column_int(queryStatement, 5)

            // get latitude
            guard let queryResultCol6 = sqlite3_column_text(queryStatement, 6) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let latitude = String(cString: queryResultCol6)

            // get longitude
            guard let queryResultCol7 = sqlite3_column_text(queryStatement, 7) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let longitude = String(cString: queryResultCol7)

            // get timestamp
            let createdAt = sqlite3_column_int(queryStatement, 8)
            
            // get title
            guard let queryResultCol9 = sqlite3_column_text(queryStatement, 9) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let title = String(cString: queryResultCol9)

            // get body
            guard let queryResultCol10 = sqlite3_column_text(queryStatement, 10) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let body = String(cString: queryResultCol10)

            // get isStory
            let isStory = sqlite3_column_int(queryStatement, 11)

            // get upvotes
            let upvotes = sqlite3_column_int(queryStatement, 12)

            // get downvotes
            let downvotes = sqlite3_column_int(queryStatement, 13)

            note = Note(noteId: noteId, serverId: serverId, userServerId: userServerId, userId: userId, privacyId: privacyId, noteTagId: noteTagId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, downvotes: downvotes, upvotes: upvotes)
        }
        return note
    }
}

extension SQLiteDatabase {
    func insertComment(noteId: Int32, userId: Int32, body: String, timeCommented: Int32) throws {
        let insertSql = "INSERT INTO Comment (NoteId, UserId, Body, TimeCommented) VALUES (?, ?, ?, ?);"
        
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        guard
            sqlite3_bind_int(insertStatement, 1, noteId) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 2, userId) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 3, body, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 4, timeCommented) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}

extension SQLiteDatabase {
    func getUserBy(userId: Int32) throws -> User? {
        let querySql = "SELECT * FROM User WHERE UserId = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard
            sqlite3_bind_int(queryStatement, 1, userId) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        
        var user: User
        
        if sqlite3_step(queryStatement) == SQLITE_ROW {
            
            let id = sqlite3_column_int(queryStatement, 0)
            
            guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let serverId = String(cString: queryResultCol1)
            
            guard let queryResultCol2 = sqlite3_column_text(queryStatement, 2) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let firstName = String(cString: queryResultCol2)
            
            guard let queryResultCol3 = sqlite3_column_text(queryStatement, 3) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let lastName = String(cString: queryResultCol3)
            
            guard let queryResultCol4 = sqlite3_column_text(queryStatement, 4) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let email = String(cString: queryResultCol4)
            
            guard let queryResultCol5 = sqlite3_column_text(queryStatement, 5) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let username = String(cString: queryResultCol5)

            guard let queryResultCol6 = sqlite3_column_text(queryStatement, 6) else {
                print("Query result is nil")
                throw SQLiteError.Step(message: errorMessage)
            }
            let password = String(cString: queryResultCol6)
            
            let timeCreated = sqlite3_column_int(queryStatement, 7)
            
            user = User(userId: id, serverId: serverId, firstName: firstName, lastName: lastName, email: email, username: username, password: password, createdAt: timeCreated)
        } else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("returning user")
        return user
    }
}

extension SQLiteDatabase {
    func updateEmailFor(userId: Int32, email: String) throws {
        let updateSql = "UPDATE User SET Email = ? WHERE UserId = ?;"
        
        let updateStatement = try prepareStatement(sql: updateSql)
        defer {
            sqlite3_finalize(updateStatement)
        }
        print("binding")
        guard
            sqlite3_bind_text(updateStatement, 1, email, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(updateStatement, 2, userId) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        print("stepping")
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            print("throwing")
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("set email")
    }
}

extension SQLiteDatabase {
    func updatePasswordFor(userId: Int32, password: String) throws {
        let updateSql = "UPDATE User SET Password = ? WHERE UserId = ?;"
        
        let updateStatement = try prepareStatement(sql: updateSql)
        defer {
            sqlite3_finalize(updateStatement)
        }
        guard
            sqlite3_bind_text(updateStatement, 1, password, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(updateStatement, 2, userId) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}

extension SQLiteDatabase {
    func updateUsernameFor(userId: Int32, username: String) throws {
        let updateSql = "UPDATE User SET Username = ? WHERE UserId = ?;"
        
        let updateStatement = try prepareStatement(sql: updateSql)
        defer {
            sqlite3_finalize(updateStatement)
        }
        guard
            sqlite3_bind_text(updateStatement, 1, username, -1, SQLITE_TRANSIENT) == SQLITE_OK &&
            sqlite3_bind_int(updateStatement, 2, userId) == SQLITE_OK
        else {
            throw SQLiteError.Bind(message: errorMessage)
        }
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}

