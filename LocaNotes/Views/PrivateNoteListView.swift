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
    @State private var nearbyNotes = [MKPointAnnotation]()
    ////@State private var loca = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @State private var selectedNote: MKPointAnnotation?
    
    @State private var showingDetails = false

    init (viewModel: NoteViewModel) {
        self.viewModel = viewModel
        
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
                            //create a new annotation at this location (//! precursor to viewing notes as annotations)
                            let newLocation = MKPointAnnotation()
                            newLocation.title = "example"
                            newLocation.coordinate = self.centerCoor
                            self.nearbyNotes.append(newLocation)
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
                .alert(isPresented: $showingDetails, content: {
                    Alert(title: Text(selectedNote?.title ?? "Unknown"), message: Text(selectedNote?.subtitle ?? "Missing note information."), primaryButton: .default(Text("OK")),secondaryButton: .default(Text("Expand")){
                        //edit this note
                        //NavigationLink("Open", destination: PrivateNoteDetailView(note: viewModel.nearbyNotes[0]))
                    })
                })
                
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
                Text(substring(string: String(note.body), offset: note.body.length / 2))
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
}
