//
//  NoteViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 2/26/21.
//

import Foundation

public class NoteViewModel: ObservableObject {
//    @Published var noteId: Int32 = 0
//    @Published var userId: Int32 = 0
//    @Published var longitude: NSString = ""
//    @Published var latitude: NSString = ""
//    @Published var timestamp: Int32 = 0
//    @Published var body: NSString = ""
        
    var locationViewModel = LocationViewModel()
      
    @Published var notes: [Note] = []
    
    public let databaseService: DatabaseService
    
    public init() {
        self.databaseService = DatabaseService()
    }
    
    public func refresh() {
        guard let notes: [Note] = databaseService.queryAllNotes() else {
            print("query returned nil")
            return
        }
        for note in notes {
            print("\(note.noteId) | \(note.userId) | \(note.longitude) | \(note.latitude) | \(note.timestamp) | \(note.body)")
        }
        
        self.notes = notes
        
    }
    
    func deleteNote(at offsets: IndexSet) {
        do {
            try databaseService.deleteNoteById(id: notes[offsets.first!].noteId)
            notes.remove(atOffsets: offsets)
        } catch {
            print("couldn't delete: \(error)")
        }
    }
    
    func insertNote(body: String) {
        let latitude = String(locationViewModel.userLatitude)
        let longitude = String(locationViewModel.userLongitude)
        let timestamp = NSDate().timeIntervalSince1970
        do {
            try databaseService.insertNote(latitude: latitude, longitude: longitude, timestamp: Int32(timestamp), body: body)
        } catch {
            print("couldn't insert: \(error)")
        }
    }
}
