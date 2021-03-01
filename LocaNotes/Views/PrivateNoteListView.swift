//
//  PrivateNoteListView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import SwiftUI

struct PrivateNoteListView: View {
        
    @ObservedObject var viewModel: NoteViewModel
    
    init (viewModel: NoteViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.notes, id: \.noteId) { note in
                    NoteCell(note: note)
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .navigationTitle("private notes")
            .navigationBarItems(leading: EditButton(), trailing: Text("Test"))
        }
        .onAppear(perform: viewModel.refresh)
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
    
    private func substring(string: String, offset: Int) -> String.SubSequence {
        let index = string.index(string.startIndex, offsetBy: offset)
        let substring = string[..<index]
        return substring
    }
}
