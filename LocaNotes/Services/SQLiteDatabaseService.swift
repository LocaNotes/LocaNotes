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
public class SQLiteDatabaseService {
    
    // a reference to the database
    private var db: SQLiteDatabase!
    
    static let shared = SQLiteDatabaseService()
    
    private init() {
                
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
                    
                    // create NoteTag table
                    try db.createTable(table: NoteTag.self)
                    let restService = RESTService()
                    restService.queryNoteTag { [self] (response, error) in
                        if response != nil {
                            for noteTag in response! {
                                let serverId = noteTag.id
                                let label = noteTag.label
                                do {
                                    try db.insertNoteTag(serverId: serverId, label: label)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                    
                    // create Privacy table
                    try db.createTable(table: Privacy.self)
//                    let privacyViewModel = PrivacyViewModel()
                    restService.queryPrivacy { [self] (response, error) in
                        if response != nil {
                            for privacy in response! {
                                let serverId = privacy.id
                                let label = privacy.label
                                do {
                                    try db.insertPrivacy(serverId: serverId, label: label)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
                    
                    // create Note table
                    try db.createTable(table: Note.self)
                    
                    // create Comment table
                    try db.createTable(table: Comment.self)
                    
                    // create Downvote table
                    try db.createTable(table: Downvote.self)
                    
                    // create Upvote table
                    try db.createTable(table: Upvote.self)
                    
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
    func queryAllNotes() throws -> [Note]? {
        return try db.queryAllNotes()
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
        - userId: the id of the user that created the note
        - serverId: the id of the note in the server's database
        - userServerId: the server's id of the user that created the note
        - noteTagId: the tag of the note
        - privacyId: the privacy setting of the note
        - title: the title of the note
        - latitude: the latitude of the note
        - longitude: the longitude of the note
        - timestamp: the time that the user tapped "finish"
        - body: the content of the node
        - isStory: represents if the note is a story
        - upvotes: the number of upvotes the note has
        - downvotes: the number of downvotes the notes has
     - Throws: `SQLiteError.Insert` if the note could not be inserted
     */
    func insertNote(userId: Int32, serverId: String, userServerId: String, noteTagId: Int32, privacyId: Int32, title: String, latitude: String, longitude: String, createdAt: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32) throws {
        try db.insertNote(serverId: serverId, userServerId: userServerId, userId: userId, noteTagId: noteTagId, privacyId: privacyId, latitude: latitude, longitude: longitude, createdAt: createdAt, title: title, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes)
    }
    
    /**
     Updates the body of the note with the specified id
     - Parameters:
        - noteId: the id of the note to be updated
        - body: the new body
     */
    func updateNoteBody(noteId: Int32, body: String) throws {
        try db.updateNoteBody(noteId: noteId, body: body)
    }
    
    func insertUser(serverId: String, firstName: String, lastName: String, email: String, username: String, password: String, createdAt: Int32) throws {
        try db.insertUser(serverId: serverId, firstName: firstName, lastName: lastName, email: email, username: username, password: password, createdAt: createdAt)
    }
    
    func selectUserByUsernameAndPassword(username: String, password: String) throws -> User? {
        return try db.selectUserByUsernameAndPassword(username: username, password: password)
    }
    
    func queryNotesBy(userId: Int32) throws -> [Note]? {
        try db.queryNotesBy(userId: userId)
    }
    
    func queryNoteBy(noteId: Int32) throws -> Note? {
        try db.queryNoteBy(noteId: noteId)
    }
    
    func queryNoteBy(serverId: String) throws -> Note? {
        return try db.getNoteByServerId(noteServerId: serverId)
    }
    
    func getUserBy(userId: Int32) throws -> User? {
        return try db.getUserBy(userId: userId)
    }
    
    func queryUserBy(serverId: String) throws -> User? {
        return try db.queryUserBy(serverId: serverId)
    }
    
    func updateUsernameFor(userId: Int32, username: String) throws {
        try db.updateUsernameFor(userId: userId, username: username)
    }
    
    func updateEmailFor(userId: Int32, email: String) throws {
        print("line 139")
        try db.updateEmailFor(userId: userId, email: email)
    }
    
    func updatePasswordFor(userId: Int32, password: String) throws {
        try db.updatePasswordFor(userId: userId, password: password)
    }
    
    func insertComment(serverId: String, noteId: Int32, noteServerId: String, userId: Int32, userServerId: String, body: String, timeCommented: Int32) throws {
        try db.insertComment(serverId: serverId, noteId: noteId, noteServerId: noteServerId, userId: userId, userServerId: userServerId, body: body, timeCommented: timeCommented)
    }
    
    func queryLocalCommentBy(serverId: String) throws -> Comment? {
        return try db.queryLocalCommentBy(serverId: serverId)
    }
    
    func queryPrivacyBy(serverId: String) throws -> Privacy? {
        return try db.queryPrivacyBy(serverId: serverId)
    }
    
    func queryNoteTagBy(serverId: String) throws -> NoteTag? {
        return try db.queryNoteTagBy(serverId: serverId)
    }
    
    func queryAllPublicNotes() throws -> [Note]? {
        return try db.queryAllPublicNotes()
    }
    
    func queryAllPrivacies() throws -> [Privacy]? {
        return try db.queryAllPrivacies()
    }
    
    func queryAllDownvotes() throws -> [Downvote]? {
        return try db.queryAllDownvotes()
    }
    
    func insertDownvote(serverId: String, userServerId: String, noteServerId: String, createdAt: String, updatedAt: String, v: Int32) throws {
        return try db.insertDownvote(serverId: serverId, userServerId: userServerId, noteServerId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
    }
    
    func queryDownvoteBy(userId: String, noteId: String) throws -> Downvote? {
        return try db.queryDownvoteBy(userId: userId, noteId: noteId)
    }
    
    func deleteDownvoteBy(serverId: String) throws {
        return try db.deleteDownvoteBy(serverId: serverId)
    }
    
    func getNumberOfDownvotesBy(noteId: String) throws -> Int {
        return try db.getNumberOfDownvotesBy(noteId: noteId)
    }
    
    func queryAllUpvotes() throws -> [Upvote]? {
        return try db.queryAllUpvotes()
    }

    func insertUpvote(serverId: String, userServerId: String, noteServerId: String, createdAt: String, updatedAt: String, v: Int32) throws {
        return try db.insertUpvote(serverId: serverId, userServerId: userServerId, noteServerId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
    }

    func queryUpvoteBy(userId: String, noteId: String) throws -> Upvote? {
        return try db.queryUpvoteBy(userId: userId, noteId: noteId)
    }

    func deleteUpvoteBy(serverId: String) throws {
        return try db.deleteUpvoteBy(serverId: serverId)
    }

    func getNumberOfUpvotesBy(noteId: String) throws -> Int {
        return try db.getNumberOfUpvotesBy(noteId: noteId)
    }
}


