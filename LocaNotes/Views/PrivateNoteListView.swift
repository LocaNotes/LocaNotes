//
//  PrivateNoteListView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import SwiftUI
import CoreLocation

struct PrivateNoteListView: View {
        
    @ObservedObject var viewModel: NoteViewModel
    
    // what the user types in the search bar
    @State private var searchText: String = ""
    
    // user location
    @State private var centerCoor = CLLocationCoordinate2D()
    
    // users nearby notes
    @State private var nearbyAnnoNotes = [Annotation]()
    
    // selected annotation on map
    @State private var selectedNote: Annotation?
    
    // whether the user is trying to show details of an annotation
    @State private var showingDetails = false

    init (viewModel: NoteViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                //----------------Map Notes-------------------------//
                ZStack{
                    MapView(centerCoordinate: $centerCoor,selectedAnno: $selectedNote, showingDetails: $showingDetails, annotations: nearbyAnnoNotes)
                        .edgesIgnoringSafeArea(.all)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2 - 100, alignment: .center)
               .alert(isPresented: $showingDetails, content: { Alert(title: Text(selectedNote?.title ?? "Unknown"), message: Text(selectedNote?.subtitle ?? "Missing note information."), primaryButton: .default(Text("Open"), action: {
                //NoteCell(note: annoToNote(selectedNote!))
                    showingDetails = true
                    searchForMapNote()
                    showingDetails = false
               }),secondaryButton: .cancel())})
                .onAppear(perform: updateAnnos)
                .onDisappear(perform: updateAnnos)
                
                
                //----------------List Notes-------------------------//
                SearchBarView(searchText: $searchText)
                    .frame(width: UIScreen.main.bounds.width+20, height: 40, alignment: .bottom)
                    
                List {
                    if !viewModel.nearbyNotes.isEmpty {
                        Section(header: Text("Nearby")) {
                            ForEach (viewModel.nearbyNotes.filter({ note in
                                self.searchText.isEmpty ? true :
                                    String(note.body).lowercased().contains(self.searchText.lowercased())
                            }), id: \.noteId) { note in
                                NoteCell(note: note)
                            }
                            .onDelete(perform: viewModel.deleteNearbyNote)
                        }
                    }
                    Section(header: Text("All")) {
                        ForEach (viewModel.notes.filter({ note in
                            self.searchText.isEmpty ? true :
                                String(note.body).lowercased().contains(self.searchText.lowercased())
                        }), id: \.noteId) { note in
                            NoteCell(note: note)
                        }
                        .onDelete(perform: viewModel.deleteNote)
                    }
                    
                }
                .navigationBarItems(leading: Button("Refresh", action: {
                    updateAnnos() //! doesn't always refresh properly :(
                }), trailing: EditButton())
                .onAppear(perform: viewModel.refresh)
                .navigationTitle("Notes")
                //                .navigationBarItems(leading: EditButton(), trailing: Text("Test"))
                
            }
        }
    }
    
    /**
     converts a note to an annotation
     - Parameters:
        - note: the note to be converted into an annotation
     - Returns:annotation representing the note
     */
    private func noteToAnno(_ note: Note) -> Annotation{
        let annotation = Annotation()
        annotation.title = String(substring(string: note.body, offset: (note.body.count > 15 ? 15 : note.body.count)))
        annotation.subtitle = String(note.body)
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(note.latitude)!, longitude: Double(note.longitude)!)
        annotation.id = note.noteId
        annotation.userId = note.userId
        annotation.userServerId = note.userServerId
        annotation.createdAt = note.createdAt
        annotation.serverId = note.serverId
        annotation.noteTagId = note.noteTagId
        annotation.privacyId = note.privacyId
        annotation.isStory = note.isStory
        annotation.downvotes = note.downvotes
        annotation.upvotes = note.upvotes
        return annotation
    }
    
    /**
     converts an annotation to a note
     - Parameters:
        - annotation: the annotation to be converted into a note
     - Returns:annotation representing the note
     */
    private func annoToNote(_ annotation: Annotation) -> Note{
        let note = Note(noteId: annotation.id,
                        serverId: annotation.serverId,
                        userServerId: annotation.userServerId,
                        userId: annotation.userId,
                        privacyId: annotation.privacyId,
                        noteTagId: annotation.noteTagId,
                        title: annotation.title!,
                        latitude: String(annotation.coordinate.latitude),
                        longitude: String(annotation.coordinate.longitude),
                        createdAt: annotation.createdAt,
                        body: annotation.subtitle!,
                        isStory: annotation.isStory,
                        downvotes: annotation.downvotes,
                        upvotes: annotation.upvotes)
        return note
    }
    
    /* Updates annotations on map */
    private func updateAnnos(){
        nearbyAnnoNotes.removeAll()
        for note in (viewModel.nearbyNotes) {
            nearbyAnnoNotes.append(noteToAnno(note))
            print(note.body)
        }
    }
    
    /* Sets search text to the note being viewed on the map */
    private func searchForMapNote(){
       // print(showingDetails)
        // print(selectedNote != nil)
        if (showingDetails && selectedNote != nil){
            searchText = selectedNote!.subtitle!
        }
    }
}

struct PrivateNoteListView_Previews: PreviewProvider {
    static var previews: some View {
        PrivateNoteListView(viewModel: NoteViewModel())
    }
}

struct NoteCell: View {
    
    let note: Note
    
    var body: some View {
        NavigationLink(destination: PrivateNoteDetailView(note: note)) {
            HStack {
                Text(String(note.userId))
                Text("\(String(substring(string: note.body, offset: NSString(string: note.body).length / 2)))...")
            }
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
