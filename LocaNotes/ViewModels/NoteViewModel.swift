//
//  NoteViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 2/26/21.
//

import Foundation

public class NoteViewModel: ObservableObject {
        
    var locationViewModel = LocationViewModel()
      
    // all notes
    @Published var notes: [Note] = []
    
    var privateNotes: [Note] = []
    
    // only the notes that are nearby the user
    var nearbyPrivateNotes: [Note] = []
    
    // all public notes except for ones written by the user
    @Published var publicNotes: [Note] = []
    
    var nearbyPublicNotes: [Note] = []
        
    private let notesRepository: NotesRepository
    
    public init() {
        self.notesRepository = NotesRepository()
    }
    
    func queryAllFromStorage() -> [Note]? {
        do {
            return try notesRepository.queryAllNotes()
        } catch {
            print("\(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     Queries all notes from the database and updates `notes` and `nearbyNotes`
     */
    public func refresh() {
//        guard let notes: [Note] = databaseService.queryAllNotes() else {
//            print("query returned nil")
//            return
//        }
        
        guard let notes = self.queryAllFromStorage() else {
            print("queryAllFromStorage returned nil")
            return
        }
        
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
//            let password = try keychainService.getGenericPasswordFor(account: username, service: "storePassword")
        
//        guard let allNotesWrittenByCurrentUser: [Note] = self.queryNotesBy(userId: userId) else {
//            print("queryNotesBy returned nil")
//            return
//        }
        
        for note in notes {
            print("\(note.noteId) | \(note.userId) | \(note.latitude) | \(note.longitude) | \(note.createdAt) | \(note.body.substring(start: 0, offset: note.body.count / 2))")
        }
        
        self.notes = notes
        
        filterForAllPrivateNotes()
        filterForNearbyPrivateNotes()
        
        queryAllPublicNotesFromStorage()
        filterForNearbyPublicNotes()
    }
    
    private func queryNotesBy(userId: Int32) -> [Note]? {
        guard let notes = try? notesRepository.queryNotesBy(userId: userId) else {
            return nil
        }
        return notes
    }
    
    private func queryNoteBy(noteId: Int32) -> Note? {
        guard let note = try? notesRepository.queryNoteBy(noteId: noteId) else {
            return nil
        }
        return note
    }
    
    func queryServerNotesBy(userId: String, completion: RESTService.RestResponseReturnBlock<[MongoNoteElement]>) {
        notesRepository.queryServerNotesBy(userId: userId, completion: completion)
    }
    
    func queryNoteBy(serverId: String) throws -> Note? {
        return try notesRepository.queryNoteBy(serverId: serverId)
    }
    
    func queryAllServerPublicNotes(completion: RESTService.RestResponseReturnBlock<[MongoNoteElement]>) {
        notesRepository.queryAllServerPublicNotes(completion: completion)
    }
    
    /**
     Deletes a note from the database, and if successful, deletes the note from `notes` and then `nearbyNotes`
     - Parameter offsets: an index set containing the index of the note to delete
     */
    func deleteNote(at offsets: IndexSet) {
        let noteIdToDelete: Int32 = notes[offsets.first!].noteId
        do {
            let note = notes[offsets.first!]
            try notesRepository.deleteNoteById(id: note.noteId, serverId: note.serverId)
            notes.remove(atOffsets: offsets)
        } catch {
            print("couldn't delete: \(error)")
        }
        
        // now delete the note from nearby notes
        for (i, note) in nearbyPrivateNotes.enumerated() {
            if note.noteId == noteIdToDelete {
                nearbyPrivateNotes.remove(at: i)
            }
        }
    }
    
    /**
     Deletes a note from the database, and if successful, deletes the note from `nearbyNotes` and then `notes`
     - Parameter offsets: an index set containing the index of the note to delete
     */
    func deleteNearbyNote(at offsets: IndexSet) {
        let noteIdToDelete: Int32 = nearbyPrivateNotes[offsets.first!].noteId
        do {
            let note = notes[offsets.first!]
            try notesRepository.deleteNoteById(id: note.noteId, serverId: note.serverId)
            nearbyPrivateNotes.remove(atOffsets: offsets)
        } catch {
            print("Couldn't delete nearby note: \(error)")
        }
        
        // now delete the note from notes
        for (i, note) in notes.enumerated() {
            if note.noteId == noteIdToDelete {
                notes.remove(at: i)
            }
        }
    }
    
    /**
     Returns a substring up to the specified index of the specified string
     - Parameters:
        - string: the string to take a substring of
        - offset: the ending index of the substring
     */
    private func substring(string: String, offset: Int) -> String.SubSequence {
        let index = string.index(string.startIndex, offsetBy: offset)
        let substring = string[..<index]
        return substring
    }
    
    /**
     Gets the user's latitude, longtitude, and a timestamp and invokes the database service to insert a note into the database
     - Parameter body: the body text of the note
     */
    func insertNewNote(body: String, noteTagId: Int32, privacyId: Int32, UICompletion: (() -> Void)?) {
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        let title = String(substring(string: body, offset: NSString(string: body).length / 2))
        let latitude = String(locationViewModel.userLatitude)
        let longitude = String(locationViewModel.userLongitude)
        let createdAt = Int32(NSDate().timeIntervalSince1970)
        let isStory = Int32(0)
        let upvotes = Int32(0)
        let downvotes = Int32(0)
        
        switch privacyId {
        case 2:
            insertNewPublicNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes, UICompletion: UICompletion)
        default:
            insertNewPrivateNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes, UICompletion: UICompletion)
        }
    }
    
    func insertNewPublicNote(userId: Int32, noteTagId: Int32, privacyId: Int32, title: String, latitude: String, longitude: String, createdAt: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32, UICompletion: (() -> Void)?) {
        do {
            try notesRepository.insertNewPublicNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, body: body, isStory: isStory, UICompletion: UICompletion)
        } catch {
            print("couldn't insert: \(error)")
        }
    }
    
    func insertNewPrivateNote(userId: Int32, noteTagId: Int32, privacyId: Int32, title: String, latitude: String, longitude: String, createdAt: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32, UICompletion: (() -> Void)?) {
        notesRepository.insertNewPrivateNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes, UICompletion: UICompletion)
    }
    
    func insertNotesFromServer(notes: [MongoNoteElement]) {
        for note in notes {
            let serverId = note.id
            let userServerId = note.userID
            let privacyServerId = note.privacyID
            let noteTagServerId = note.noteTagID
            let title = note.title
            let latitude = String(note.latitude)
            let longitude = String(note.longitude)
            let body = note.body
            let isStory = Int32(note.isStory == true ? 1 : 0)
            let downvotes = Int32(note.downvotes)
            let upvotes = Int32(note.upvotes)
            let createdAt = note.createdAt
            
            let index = createdAt.index(createdAt.startIndex, offsetBy: 19)
            let substring = createdAt[..<index]
            let timestamp = String(substring) + "Z"
            
            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: timestamp)
            let unix = date?.timeIntervalSince1970
            let postedAt = Int32(unix!)
            
            do {
                // first check if note is already in db
                if try queryNoteBy(serverId: serverId) == nil {
                    
                    // get privacyId from db by privacyServerId
                    let privacyViewModel = PrivacyViewModel()
                    guard let privacy = privacyViewModel.queryPrivacyBy(serverId: privacyServerId) else {
                        return
                    }
                    
                    // get noteTagId from db by noteTagServerId
                    let noteTagViewModel = NoteTagViewModel()
                    guard let noteTag = noteTagViewModel.queryBy(serverId: noteTagServerId) else {
                        return
                    }
                    
                    // get userId from DB by userServerId
                    let userViewModel = UserViewModel()
                    guard let user = try userViewModel.queryUserBy(serverId: userServerId) else {
                        return
                    }
                        
                    try notesRepository.insertNoteLocally(
                        serverId: serverId,
                        userId: user.userId,
                        userServerId: userServerId,
                        noteTagId: noteTag.noteTagId,
                        privacyId: privacy.privacyId,
                        title: title,
                        latitude: latitude,
                        longitude: longitude,
                        createdAt: postedAt,
                        body: body,
                        isStory: isStory,
                        upvotes: upvotes,
                        downvotes: downvotes
                    )
                }
            } catch {
                print(error)
                print("\(error.localizedDescription)")
            }
        }
    }
    
    /**
     Invokes the database service to update the body of the note with the specified id
     - Parameters:
        - noteId: the id of the note to be updated
        - body: the new body
     */
    func updateNoteBody(noteId: Int32, body: String) {
        do {
            try notesRepository.updateNoteBody(noteId: noteId, body: body)
        } catch {
            print("Couldn't update note: \(error)")
        }
    }
    
    /**
     Filters `notes` for all notes that are nearby the user. Puts the notes that are nearby the user in `nearbyNotes`. A note is considered nearby the user if
     the note is within the user's set radius.
     */
    func filterForNearbyPrivateNotes() {
        nearbyPrivateNotes.removeAll()
        for note in privateNotes {
            let userFilterRadiusInMeters = 80467.2 // 50 miles
            
            guard let latitude = Double(String(note.latitude)) else { return }
            guard let longitude = Double(String(note.longitude)) else { return }
            
            let distance = locationViewModel.getDistanceBetweenNoteAndUser(latitude: latitude, longitude: longitude)
                        
            if (distance < userFilterRadiusInMeters) {
                nearbyPrivateNotes.append(note)
            }
        }
    }
    
    func queryAllPublicNotesFromStorage() {
        do {
            guard let publicNotes = try notesRepository.queryAllPublicNotesFromStorage() else {
                return
            }
            self.publicNotes = publicNotes
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func filterForNearbyPublicNotes() {
        let userFilterRadiusInMeters = 80467.2 // 50 miles
        self.nearbyPublicNotes = self.publicNotes.filter { note in
            guard let latitude = Double(String(note.latitude)) else { return false }
            guard let longitude = Double(String(note.longitude)) else { return false }
            let distance = locationViewModel.getDistanceBetweenNoteAndUser(latitude: latitude, longitude: longitude)
            return distance < userFilterRadiusInMeters
        }
    }
    
    func filterForAllPrivateNotes() {
        let privacyViewModel = PrivacyViewModel()
        guard let privacies = privacyViewModel.queryAllFromStorage() else {
            print("error filtering for private notes")
            self.privateNotes = []
            return
        }
        var privacyId: Int32 = Int32(-1)
        for privacy in privacies {
            if privacy.label.lowercased() == "private" {
                privacyId = privacy.privacyId
            }
        }
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        self.privateNotes = notes.filter { $0.userId == userId && $0.privacyId == privacyId }
    }
}
