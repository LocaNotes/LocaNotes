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
    
    public let databaseService: SQLiteDatabaseService
    
    public init() {
        self.databaseService = SQLiteDatabaseService()
    }
    
    /**
     Queries all notes from the database and updates `notes` and `nearbyNotes`
     */
    public func refresh() {
        guard let notes: [Note] = databaseService.queryAllNotes() else {
            print("query returned nil")
            return
        }
        for note in notes {
            print("\(note.noteId) | \(note.userId) | \(note.latitude) | \(note.longitude) | \(note.timeCreated) | \(note.body)")
        }
        
        self.notes = notes
        
        filterForNearbyNotes()
    }
    
    /**
     Deletes a note from the database, and if successful, deletes the note from `notes` and then `nearbyNotes`
     - Parameter offsets: an index set containing the index of the note to delete
     */
    func deleteNote(at offsets: IndexSet) {
        let noteIdToDelete: Int32 = notes[offsets.first!].noteId
        do {
            try databaseService.deleteNoteById(id: notes[offsets.first!].noteId)
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
            try databaseService.deleteNoteById(id: noteIdToDelete)
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
     Gets the user's latitude, longtitude, and a timestamp and invokes the database service to insert a note into the database
     - Parameter body: the body text of the note
     */
    func insertNote(body: String) {
        let userId = Int32(1)
        let latitude = String(locationViewModel.userLatitude)
        let longitude = String(locationViewModel.userLongitude)
        let timestamp = NSDate().timeIntervalSince1970
        let isStory = Int32(0)
        let upvotes = Int32(0)
        let downvotes = Int32(0)
        
        insertNote(userId: userId, latitude: latitude, longitude: longitude, timeCreated: Int32(timestamp), body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes)
    }
    
    func insertNote(userId: Int32, latitude: String, longitude: String, timeCreated: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32) {
        do {
            try databaseService.insertNote(userId: userId, latitude: latitude, longitude: longitude, timestamp: timeCreated, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes)
        } catch {
            print("couldn't insert: \(error)")
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
            try databaseService.updateNoteBody(noteId: noteId, body: body)
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
