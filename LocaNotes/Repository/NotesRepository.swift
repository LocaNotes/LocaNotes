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
//        self.sqliteDatabaseService = SQLiteDatabaseService()
        self.sqliteDatabaseService = SQLiteDatabaseService.shared
        self.restService = RESTService()
    }
    
    func queryAllNotes() throws -> [Note]? {
        return try sqliteDatabaseService.queryAllNotes()
    }
    
    /**
     Deletes the note in the database specified by the id
     - Parameter id: the id of the note that should be deleted
     - Throws: `SQLiteError.Delete` if the note wasn't deleted
     */
    func deleteNoteById(id: Int32, serverId: String) throws {
        try sqliteDatabaseService.deleteNoteById(id: id)
        
        if (NSString(string: serverId).length > 0) {
            restService.deleteNoteBy(id: serverId, completion: deleteNoteByIdCallback(response:error:))
        }
    }
    
    func deleteNoteByIdCallback(response: MongoNoteElement?, error: Error?) {
        if response == nil {
            if error == nil {
                print("unknown error")
                return
            }
            print("\(error)")
            return
        }
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
    func insertNewPublicNote(userId: Int32, noteTagId: Int32, privacyId: Int32, title: String, latitude: String, longitude: String, body: String, isStory: Int32, UICompletion: (() -> Void)?) throws {
        restService.insertNote(userId: userId, privacyId: privacyId, noteTagId: noteTagId, title: title, latitude: latitude, longitude: longitude, body: body, isStory: (isStory == 1 ? true : false), completion: insertNoteCallback(response:error:), UICompletion: UICompletion)
    }
    
    func insertNewPrivateNote(userId: Int32, noteTagId: Int32, privacyId: Int32, title: String, latitude: String, longitude: String, createdAt: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32, UICompletion: (() -> Void)?) {
        do {
            try sqliteDatabaseService.insertNote(userId: userId, serverId: "", userServerId: "", noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes)
            
            UICompletion?()
        } catch {
            print(error)
        }
    }
    
    func insertNoteLocally(serverId: String, userId: Int32, userServerId: String, noteTagId: Int32, privacyId: Int32, title: String, latitude: String, longitude: String, createdAt: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32) {
        do {
            try sqliteDatabaseService.insertNote(userId: userId, serverId: serverId, userServerId: userServerId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes)
            } catch {
            print(error.localizedDescription)
        }
    }
    
    private func insertNoteCallback(response: MongoNoteElement?, error: Error?) {
        if response == nil {
            if error == nil {
                print("unknown error")
                return
            }
            print("\(error)")
            return
        }
        
        let note = createNoteFor(mongoNoteElement: response!)
                
        do {
            try sqliteDatabaseService.insertNote(userId: note.userId, serverId: note.serverId, userServerId: note.userServerId, noteTagId: note.noteTagId, privacyId: note.privacyId, title: note.title, latitude: note.latitude, longitude: note.longitude, createdAt: note.createdAt, body: note.body, isStory: note.isStory, upvotes: note.upvotes, downvotes: note.downvotes)
        } catch {
            print(error)
        }
    }
    
    /**
     Updates the body of the note with the specified id
     - Parameters:
        - noteId: the id of the note to be updated
        - body: the new body
     */
    func updateNoteBody(noteId: Int32, body: String) throws {
        try sqliteDatabaseService.updateNoteBody(noteId: noteId, body: body)
        
        guard let note = try queryNoteBy(noteId: noteId) else {
            print("couldn't update note body")
            return
        }

        if note.privacyId == 1 {
            restService.updateNoteBody(note: note, completion: updateNoteBodyCallback(response:error:))
        }
    }
    
    func updateNoteBodyCallback(response: MongoNoteElement?, error: Error?) {
        if response == nil {
            if error == nil {
                print("unknown error")
                return
            }
            print("\(error)")
            return
        }
    }
    
    func queryNotesBy(userId: Int32) throws -> [Note]? {
        try sqliteDatabaseService.queryNotesBy(userId: userId)
    }
    
    func queryNoteBy(noteId: Int32) throws -> Note? {
        try sqliteDatabaseService.queryNoteBy(noteId: noteId)
    }
    
    func queryNoteBy(serverId: String) throws -> Note? {
        return try sqliteDatabaseService.queryNoteBy(serverId: serverId)
    }
    
    func createNoteFor(mongoNoteElement: MongoNoteElement) -> Note {
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        let serverId = mongoNoteElement.id
        let userServerId = mongoNoteElement.userID
        
        var privacyId: Int32
        switch (mongoNoteElement.privacyID) {
        case "6061432c9a65a46b36955c44": // public
            privacyId = 1
        case "606143349a65a46b36955c45": // private
            privacyId = 2
        default:
            privacyId = 2
        }
        
        var noteTagId: Int32
        switch (mongoNoteElement.noteTagID) {
        case "606143549a65a46b36955c46": // emergency
            noteTagId = 1
        case "606143599a65a46b36955c47": // dining
            noteTagId = 2
        case "6061435c9a65a46b36955c48": // meme
            noteTagId = 3
        case "606143609a65a46b36955c49": // other
            noteTagId = 4
        default:
            noteTagId = 4
        }
        
        let title = mongoNoteElement.title
        let latitude = String(mongoNoteElement.latitude)
        let longitude = String(mongoNoteElement.longitude)
        let createdAt = mongoNoteElement.createdAt
        let body = mongoNoteElement.body
        
        let isStory = mongoNoteElement.isStory
        var isStoryLocal: Int32
        if (isStory) {
            isStoryLocal = 1
        } else {
            isStoryLocal = 0
        }
        
        let downvotes = Int32(mongoNoteElement.downvotes)
        let upvotes = Int32(mongoNoteElement.upvotes)
        
        let index = createdAt.index(createdAt.startIndex, offsetBy: 19)
        let substring = createdAt[..<index]
        let timestamp = String(substring) + "Z"
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: timestamp)
        let unix = date?.timeIntervalSince1970
        let createdAtUnix = Int32(unix!)
        
        return Note(noteId: -1, serverId: serverId, userServerId: userServerId, userId: userId, privacyId: privacyId, noteTagId: noteTagId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAtUnix, body: body, isStory: isStoryLocal, downvotes: downvotes, upvotes: upvotes)
    }
    
    func queryServerNotesBy(userId: String, completion: RESTService.RestResponseReturnBlock<[MongoNoteElement]>) {
        restService.queryServerNotesBy(userId: userId, completion: completion)
    }
    
    func queryAllServerPublicNotes(completion: RESTService.RestResponseReturnBlock<[MongoNoteElement]>) {
        restService.queryAllServerPublicNotes(completion: completion)
    }
    
    func queryAllPublicNotesFromStorage() throws -> [Note]? {
        return try? sqliteDatabaseService.queryAllPublicNotes()
    }
    
    func checkIfSharedFor(noteId: String, receiverId: String, completion: RESTService.RestResponseReturnBlock<[MongoShareElement]>) {
        restService.checkIfSharedFor(noteId: noteId, receiverId: receiverId, completion: completion)
    }
    
    func getSharedNotesFor(receiverId: String, completion: RESTService.RestResponseReturnBlock<[MongoNoteElement]>) {
        
        // populate table locally
        restService.getSharesFor(receiverId: receiverId, completion: { (response, error) in
            guard let response = response else {
                return
            }
            do {
                for share in response {
                    try self.sqliteDatabaseService.insertShare(serverId: share.id, noteId: share.noteID, receiverId: share.receiverID, createdAt: share.createdAt, updatedAt: share.updatedAt, v: share.v)
                }
                
                // get actual notes
                self.restService.getSharedNotesFor(receiverId: receiverId, completion: completion)
            } catch {
                print("\(error.localizedDescription)")
            }
        })
    }
    
    func checkIfSharedForLocal(noteId: String, receiverId: String) throws -> MongoShareElement {
        return try sqliteDatabaseService.checkIfSharedFor(noteId: noteId, receiverId: receiverId)
    }
    
    func sharePrivateNoteWith(noteId: String, receiverId: String, completion: RESTService.RestResponseReturnBlock<MongoShareElement>) {
        restService.sharePrivateNoteWith(noteId: noteId, receiverId: receiverId, completion: completion)
    }
    
    func pushToServer(note: Note, completion: RESTService.RestResponseReturnBlock<MongoNoteElement>) {
        restService.insertNote(userId: note.userId, privacyId: note.privacyId, noteTagId: note.noteTagId, title: note.title, latitude: note.latitude, longitude: note.longitude, body: note.body, isStory: (note.isStory != 0), completion: { (response, error) in
            do {
                guard let response = response else {
                    completion?(nil, error)
                    return
                }
                try self.updateNote(noteId: note.noteId, serverId: response.id, userServerId: response.userID)
                completion?(response, error)
            } catch {
                completion?(response, error)
            }
        }, UICompletion: {})
    }
    
    func updateNote(noteId: Int32, serverId: String, userServerId: String) throws {
        try sqliteDatabaseService.updateNote(noteId: noteId, serverId: serverId, userServerId: userServerId)
    }
    
    func selectNoteBy(noteId: Int32) throws -> Note {
        return try sqliteDatabaseService.selectNoteBy(noteId: noteId)
    }
}
