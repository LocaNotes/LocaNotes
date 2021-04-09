//
//  PrivateNoteListView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import SwiftUI
import MapKit

struct PrivateNoteListView: View {
        
    @ObservedObject var viewModel: NoteViewModel
    
    // what the user types in the search bar
    @State private var searchText: String = ""
    
    // user location
    @State private var centerCoor = CLLocationCoordinate2D()
    
    // users nearby notes
    @State private var nearbyNotes = [Annotation]()
    ////@State private var loca = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @State private var selectedNote: Annotation?

    
    @State private var showingDetails = false

    init (viewModel: NoteViewModel) {
        self.viewModel = viewModel
        
        print(self.viewModel.notes.count)
        //TODO: GET THIS TO WORK
        //NotificationCenter.default.addObserver(self, selector: Selector(("updateAnnos")), name: NSNotification.Name(rawValue: "updateAnnos"), object: nil)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                //----------------Map Notes-------------------------//
                ZStack{
                    MapView(centerCoordinate: $centerCoor,selectedAnno: $selectedNote, showingDetails: $showingDetails, annotations: nearbyNotes)
                        .edgesIgnoringSafeArea(.all)
                        
                    ////Map(coordinateRegion: $loca, showsUserLocation: true, userTrackingMode: .constant(.follow))
                    Circle()
                        .fill(Color.blue)
                        .opacity(0.3)
                        .frame(width: 32, height: 32)
                    VStack {
                        Spacer()
                        HStack{
                        Button(action: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateAnnos"), object: nil, userInfo: nil)
                            //create a new annotation at this location (//! precursor to viewing notes as annotations)
                            updateAnnos()
                            /*let newLocation = MKPointAnnotation()
                            newLocation.title = "example"
                            newLocation.coordinate = self.centerCoor
                            self.nearbyNotes.append(newLocation)*/
                        }) {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2 - 100, alignment: .center)
                .onAppear(perform: updateAnnos)
                
                //.alert(isPresented: $showingDetails, content: { Alert(title: Text(selectedNote?.title ?? "Unknown"), message: Text(selectedNote?.subtitle ?? "Missing note information."), primaryButton: .default(Text("OK")),secondaryButton:                     .default(Text("expand"), action: {
                            //NoteCell(note: annoToNote(selectedNote!))
                     //   })
                        //edit this note
                        //NavigationLink("Open", destination: PrivateNoteDetailView(note: viewModel.nearbyNotes[0]))
                 //   )})
                
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
                .navigationBarItems(trailing: EditButton())
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
        let annotation = Annotation(MKPointAnnotation())
        annotation.title = String(substring(string: note.body, offset: (note.body.count > 15 ? 15 : note.body.count)))
        annotation.subtitle = String(note.body)
        annotation.coordinate = CLLocationCoordinate2D(latitude: Double(note.latitude)!, longitude: Double(note.longitude)!)
        annotation.id = note.noteId
        annotation.userid = note.userId
        annotation.timestamp = note.timestamp
        return annotation
    }
    
    /**
     converts an annotation to a note
     - Parameters:
        - annotation: the annotation to be converted into a note
     - Returns:annotation representing the note
     */
    private func annoToNote(_ annotation: Annotation) -> Note{
        let note = Note(noteId: annotation.id, userId: annotation.userid, latitude: String(annotation.coordinate.latitude), longitude: String(annotation.coordinate.longitude), timestamp: annotation.timestamp, body: String(annotation.subtitle!))
        return note
    }
    
    private func updateAnnos(/*notification: NSNotification*/){
        nearbyNotes = [Annotation]()
        for note in (self.viewModel.nearbyNotes) {
            self.nearbyNotes.append(noteToAnno(note))
            print(note.body)
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
