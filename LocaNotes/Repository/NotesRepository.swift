//
//  NotesRepository.swift
//  LocaNotes
//
//  Created by Anthony C on 3/27/21.
//

import Foundation

class NotesRepository {
    let sqliteDatabaseService: SQLiteDatabaseService
    let restService: RESTService
    
    init() {
        self.sqliteDatabaseService = SQLiteDatabaseService()
        self.restService = RESTService()
    }
    
    func queryAllNotes() -> [Note]? {
        return sqliteDatabaseService.queryAllNotes()
    }
    
    /**
     Deletes the note in the database specified by the id
     - Parameter id: the id of the note that should be deleted
     - Throws: `SQLiteError.Delete` if the note wasn't deleted
     */
    func deleteNoteById(id: Int32) throws {
        try sqliteDatabaseService.deleteNoteById(id: id)
    }
    
    /**
     Inserts a note with the specified information into the database
     - Parameters:
        - userId: the id of the user that created the note
        - noteTagId: the tag of the note
        - privacyId: the privacy setting of the note
        - latitude: the latitude of the note
        - longitude: the longitude of the note
        - timestamp: the time that the user tapped "finish"
        - body: the content of the node
        - isStory: represents if the note is a story
        - upvotes: the number of upvotes the note has
        - downvotes: the number of downvotes the notes has
     - Throws: `SQLiteError.Insert` if the note could not be inserted
     */
    func insertNote(userId: Int32, noteTagId: Int32, privacyId: Int32, latitude: String, longitude: String, timeCreated: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32) throws {
        try sqliteDatabaseService.insertNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, latitude: latitude, longitude: longitude, timeCreated: timeCreated, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes)
    }
    
    /**
     Updates the body of the note with the specified id
     - Parameters:
        - noteId: the id of the note to be updated
        - body: the new body
     */
    func updateNoteBody(noteId: Int32, body: String) throws {
        try sqliteDatabaseService.updateNoteBody(noteId: noteId, body: body)
    }
    
    func queryNotesBy(userId: Int) throws -> [Note]? {
        try sqliteDatabaseService.queryNotesBy(userId: userId)
    }
}
