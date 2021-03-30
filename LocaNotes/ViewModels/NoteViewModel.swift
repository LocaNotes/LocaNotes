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
    
    // only the notes that are nearby the user
    @Published var nearbyNotes: [Note] = []
    
    private let notesRepository: NotesRepository
    
    public init() {
        self.notesRepository = NotesRepository()
    }
    
    /**
     Queries all notes from the database and updates `notes` and `nearbyNotes`
     */
    public func refresh() {
//        guard let notes: [Note] = databaseService.queryAllNotes() else {
//            print("query returned nil")
//            return
//        }
        
        
        
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
//            let password = try keychainService.getGenericPasswordFor(account: username, service: "storePassword")
        
        guard let notes: [Note] = self.queryNotesBy(userId: userId) else {
            print("query returned nil")
            return
        }
        
        for note in notes {
            print("\(note.noteId) | \(note.userId) | \(note.latitude) | \(note.longitude) | \(note.createdAt) | \(note.body)")
        }
        
        self.notes = notes
        
        filterForNearbyNotes()
        
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
        for (i, note) in nearbyNotes.enumerated() {
            if note.noteId == noteIdToDelete {
                nearbyNotes.remove(at: i)
            }
        }
    }
    
    /**
     Deletes a note from the database, and if successful, deletes the note from `nearbyNotes` and then `notes`
     - Parameter offsets: an index set containing the index of the note to delete
     */
    func deleteNearbyNote(at offsets: IndexSet) {
        let noteIdToDelete: Int32 = nearbyNotes[offsets.first!].noteId
        do {
            let note = notes[offsets.first!]
            try notesRepository.deleteNoteById(id: note.noteId, serverId: note.serverId)
            nearbyNotes.remove(atOffsets: offsets)
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
        case 1:
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
    func filterForNearbyNotes() {
        nearbyNotes.removeAll()
        for note in notes {
            let userFilterRadiusInMeters = 80467.2 // 50 miles
            
            guard let latitude = Double(String(note.latitude)) else { return }
            guard let longitude = Double(String(note.longitude)) else { return }
            
            let distance = locationViewModel.getDistanceBetweenNoteAndUser(latitude: latitude, longitude: longitude)
                        
            if (distance < userFilterRadiusInMeters) {
                nearbyNotes.append(note)
            }
        }
    }
}
