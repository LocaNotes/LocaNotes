//
//  PrivateNoteListView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import SwiftUI

struct PrivateNoteListView: View {
        
    @ObservedObject var viewModel: NoteViewModel
    
    // what the user types in the search bar
    @State private var searchText: String = ""
    
    init (viewModel: NoteViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(searchText: $searchText)
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
                .onAppear(perform: viewModel.refresh)
                .navigationTitle("Private Notes")
//                .navigationBarItems(leading: EditButton(), trailing: Text("Test"))
                .navigationBarItems(leading: EditButton())
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
                Text("\(String(substring(string: note.body, offset: NSString(string: note.body).length / 2)))...")
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
