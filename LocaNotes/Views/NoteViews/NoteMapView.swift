//
//  NoteMapView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI
import CoreLocation

struct NoteMapView: View {
    @ObservedObject var viewModel: NoteViewModel
    
    // user location
    @State private var centerCoor = CLLocationCoordinate2D()
    
    // users nearby notes
    @State private var nearbyAnnoNotes = [Annotation]()
    
    // selected annotation on map
    @State private var selectedNote: Annotation?
    
    // whether the user is trying to show details of an annotation
    @State private var showingDetails = false
    
    @Binding var searchText: String
    
    var privacyLabel: PrivacyLabel
    
    var body: some View {
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
        var nearbyNotes: [Note]
        switch self.privacyLabel {
        case PrivacyLabel.privateNote:
            nearbyNotes = viewModel.nearbyPrivateNotes
        default:
            nearbyNotes = viewModel.nearbyPublicNotes
        }
        
        nearbyAnnoNotes.removeAll()
        for note in (nearbyNotes) {
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

//struct NoteMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteMapView()
//    }
//}

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
