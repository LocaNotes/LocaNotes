//
//  NoteViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 2/26/21.
//

import Foundation

public class NoteViewModel: ObservableObject {
      
    // all notes
    @Published var notes: [Note] = []
    
    // private notes that the user has written
    @Published var privateNotes: [Note] = []
    
    // only the private notes that are nearby the user
    @Published var nearbyPrivateNotes: [Note] = []
    
    // private notes shared to the user
    @Published var sharedNotes: [Note] = []
    
    // all public notes except for ones written by the user
    @Published var publicNotes: [Note] = []
    
    @Published var nearbyPublicNotes: [Note] = []
    
    // nearby public stories
    @Published var nearbyStories: [Note] = []
     
    // private or public stories that the user's friends wrote 
    @Published var sharedStories: [Note] = []
    
    // user's stories
    @Published var myStories: [Note] = []
        
    private let notesRepository: NotesRepository
    private let locationViewModel: LocationViewModel
    
    public init() {
        self.notesRepository = NotesRepository()
        self.locationViewModel = LocationViewModel()
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
        guard let notes = self.queryAllFromStorage() else {
            print("queryAllFromStorage returned nil")
            return
        }
        
        DispatchQueue.main.async {
            self.notes = notes
        }
        
        self.filterForAllPrivateNotes()
        self.filterForNearbyPrivateNotes()
        self.filterForSharedNotes()
        
        self.queryAllPublicNotesFromStorage()
        self.filterForNearbyPublicNotes()
        
        self.filterForNearbyStories()
        self.filterForSharedStories()
        self.filterForMyStories()
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
    
    func queryAllServerPublicRegularNotes(completion: RESTService.RestResponseReturnBlock<[MongoNoteElement]>) {
        notesRepository.queryAllServerPublicRegularNotes(completion: completion)
    }
    
    /**
     Deletes a note from the database, and if successful, deletes the note from `notes` and then `nearbyNotes`
     - Parameter offsets: an index set containing the index of the note to delete
     */
    func deleteNote(at offsets: IndexSet) {
        let noteIdToDelete = privateNotes[offsets.first!].noteId
        do {
            let note = privateNotes[offsets.first!]
            
            try notesRepository.deleteNoteById(id: note.noteId, serverId: note.serverId)
            privateNotes.remove(atOffsets: offsets)
            
            // now delete the note from nearby notes
            for (i, note) in nearbyPrivateNotes.enumerated() {
                if note.noteId == noteIdToDelete {
                    nearbyPrivateNotes.remove(at: i)
                }
            }
        } catch {
            print("couldn't delete: \(error.localizedDescription)")
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
        for (i, note) in privateNotes.enumerated() {
            if note.noteId == noteIdToDelete {
                privateNotes.remove(at: i)
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
    func insertNewNote(body: String, noteTagId: Int32, privacyId: Int32, isStory: Int, UICompletion: (() -> Void)?) {
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        let title = String(substring(string: body, offset: NSString(string: body).length / 2))
        let latitude = String(locationViewModel.userLatitude)
        let longitude = String(locationViewModel.userLongitude)
        let createdAt = Int32(NSDate().timeIntervalSince1970)
        let isStory = Int32(isStory)
        let upvotes = Int32(0)
        let downvotes = Int32(0)
        
        switch (privacyId, isStory) {
        case (1, 0):
            // is private and not a story
            insertNewPrivateNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes, UICompletion: UICompletion)
        default:
            insertNewPublicNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes, UICompletion: UICompletion)
//        case (2, _):
//            fallthrough
//        case (1, 1):
            
            
        }
    }
    
    func insertNewPublicNote(userId: Int32, noteTagId: Int32, privacyId: Int32, title: String, latitude: String, longitude: String, createdAt: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32, UICompletion: (() -> Void)?) {
        do {
            try notesRepository.insertNewPublicNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, body: body, isStory: isStory == 1 ? true : false, UICompletion: UICompletion)
        } catch {
            print("couldn't insert: \(error)")
        }
    }
    
    func insertNewPrivateNote(userId: Int32, noteTagId: Int32, privacyId: Int32, title: String, latitude: String, longitude: String, createdAt: Int32, body: String, isStory: Int32, upvotes: Int32, downvotes: Int32, UICompletion: (() -> Void)?) {
        notesRepository.insertNewPrivateNote(userId: userId, noteTagId: noteTagId, privacyId: privacyId, title: title, latitude: latitude, longitude: longitude, createdAt: createdAt, body: body, isStory: isStory, upvotes: upvotes, downvotes: downvotes, UICompletion: UICompletion)
        self.refresh()
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
                        
                    notesRepository.insertNoteLocally(
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
        DispatchQueue.main.async {
            self.nearbyPrivateNotes.removeAll()
            for note in self.privateNotes {
                let userRadius = UserDefaults.standard.double(forKey: "userRadius")
                // convert to meters
                let userFilterRadiusInMeters = userRadius * 1609.344
                
                guard let latitude = Double(String(note.latitude)) else { return }
                guard let longitude = Double(String(note.longitude)) else { return }
                
                let distance = self.locationViewModel.getDistanceBetweenNoteAndUser(latitude: latitude, longitude: longitude)
                            
                if (distance < userFilterRadiusInMeters) {
                    self.nearbyPrivateNotes.append(note)
                }
            }
        }
    }
    
    func queryAllPublicNotesFromStorage() {
        do {
            guard let publicNotes = try notesRepository.queryAllPublicNotesFromStorage() else {
                return
            }
            DispatchQueue.main.async {
                self.publicNotes = publicNotes.filter {
                    $0.isStory == 0
                }
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func filterForNearbyPublicNotes() {
        DispatchQueue.main.async {
            let userRadius = UserDefaults.standard.double(forKey: "userRadius")
            // convert to meters
            let userFilterRadiusInMeters = userRadius * 1609.344
            self.nearbyPublicNotes = self.publicNotes.filter { note in
                guard let latitude = Double(String(note.latitude)) else { return false }
                guard let longitude = Double(String(note.longitude)) else { return false }
                let distance = self.locationViewModel.getDistanceBetweenNoteAndUser(latitude: latitude, longitude: longitude)
                return distance < userFilterRadiusInMeters
            }
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
        let filteredNotes = self.notes.filter {
            if $0.isStory == 0 {
                return $0.userId == userId && $0.privacyId == privacyId
            } else {
                return false
            }
        }
        DispatchQueue.main.async {
            self.privateNotes = filteredNotes
        }
    }
    
    func filterForSharedNotes() {
        let userServerId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        let filteredNotes = self.notes.filter {
            if $0.isStory == 0 {
                do {
                    let _ = try self.checkIfSharedForLocal(noteId: $0.serverId, receiverId: userServerId)
                    return true
                } catch {
                    return false
                }
            } else {
                return false
            }
        }
        DispatchQueue.main.async {
            self.sharedNotes = filteredNotes
        }
    }
    
    func checkIfSharedForLocal(noteId: String, receiverId: String) throws -> MongoShareElement {
        return try notesRepository.checkIfSharedForLocal(noteId: noteId, receiverId: receiverId)
    }
    
    func checkIfSharedFor(noteId: String, receiverId: String, completion: RESTService.RestResponseReturnBlock<[MongoShareElement]>) {
        notesRepository.checkIfSharedFor(noteId: noteId, receiverId: receiverId, completion: completion)
    }
    
    func getSharedNotesFor(receiverId: String) {
        notesRepository.getSharedNotesFor(receiverId: receiverId, completion: { (response, error) in
            if response == nil {
                return
            }
            self.insertNotesFromServer(notes: response!)
            self.refresh()
        })
    }
    
    func sharePrivateNoteWith(noteId: String, receiverId: String, completion: RESTService.RestResponseReturnBlock<MongoShareElement>) {
        notesRepository.sharePrivateNoteWith(noteId: noteId, receiverId: receiverId, completion: completion)
    }
    
    func pushToServer(note: Note, completion: RESTService.RestResponseReturnBlock<MongoNoteElement>) {
        notesRepository.pushToServer(note: note, completion: completion)
    }
    
    func selectNoteBy(noteId: Int32) throws -> Note {
        return try notesRepository.selectNoteBy(noteId: noteId)
    }
    
    func filterForNearbyStories() {
        DispatchQueue.main.async {
            self.nearbyStories.removeAll()
        }
        
        // convert to meters
        let userRadius = UserDefaults.standard.double(forKey: "userRadius")
        let userFilterRadiusInMeters = userRadius * 1609.344
        
        let temp = filterForStories(validate: { note in
            
            // add nearby public stories
            guard let latitude = Double(String(note.latitude)) else { return false }
            guard let longitude = Double(String(note.longitude)) else { return false }
            let distance = self.locationViewModel.getDistanceBetweenNoteAndUser(latitude: latitude, longitude: longitude)
            if note.privacyId == 2 {
                if (distance < userFilterRadiusInMeters) {
                    return true
                }
            }
            return false
        })
        
        DispatchQueue.main.async {
            self.nearbyStories = temp
        }
    }
    
    func filterForSharedStories() {
        DispatchQueue.main.async {
            self.sharedStories.removeAll()
        }
        
        let queue = DispatchQueue.global()
        let userServerId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        let userViewModel = UserViewModel()
        
        // we have to do this operation off the ui thread, or else the semaphores will freeze it up
        queue.async {
            let temp = self.filterForStories(validate: { note in
                let semaphore = DispatchSemaphore(value: 0)
                var validNote: Bool = false
                queue.async {
                    if note.userServerId.count > 0 {
                        userViewModel.checkIfFriends(frienderId: userServerId, friendeeId: note.userServerId, completion: { response, error in
                            if response != nil {
                                if response!.count > 0 {
                                    validNote = true
                                }
                            }
                            semaphore.signal()
                        })
                    }
                    
                }
                let _ = semaphore.wait(timeout: .now() + 2.0)
                
                if validNote {
                    return true
                }
                return false
            })
            
            DispatchQueue.main.async {
                self.sharedStories = temp
            }
        }
    }
    
    func filterForMyStories() {
        DispatchQueue.main.async {
            self.myStories.removeAll()
        }
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let temp = filterForStories(validate: { note in
            
            // add stories that the user themself has written
            if note.userId == userId {
                return true
            }
            return false
        })
        
        DispatchQueue.main.async {
            self.myStories = temp
        }
    }
    
    func filterForStories(validate: (Note) -> Bool) -> [Note] {
        let now = Double(NSDate().timeIntervalSince1970)
        var temp: [Note] = []
        for note in self.notes {
            let createdAt = Double(note.createdAt)
            let difference = now - createdAt
            
            // only show stories if they are no older than 24 hours
            if difference < 86400 {
                if note.isStory == 1 {
                    if validate(note) {
                        temp.append(note)
                    }
                }
            }
        }
        return temp
    }
}
