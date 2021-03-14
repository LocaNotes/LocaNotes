//
//  PrivateNoteDetailView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import SwiftUI

struct PrivateNoteDetailView: View {
    
    let viewModel: NoteViewModel
    
    // the note that this view shows
    let note: Note
    
    @State var noteContent: String = ""
    
    @State var editing = false
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    init (note: Note) {
        viewModel = NoteViewModel()
        self.note = note
        self.noteContent = String(note.body)
    }
    
    var body: some View {
        TextEditor(text: $noteContent)
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    UIApplication.shared.endEditing(true)
                }) {
                    Image(systemName: "xmark")
                }
                .padding()
                Button(action: {
                    self.copyNoteContent()
                    UIApplication.shared.endEditing(true)
                }) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .padding()
                .disabled(self.noteContent == String(note.body) ? true : false)
                Button(action: {
                    self.editing.toggle()
                    UIApplication.shared.endEditing(true)
                    viewModel.updateNoteBody(noteId: note.noteId, body: self.noteContent)
                    self.mode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "pencil")
                }
                .padding()
                .disabled(self.noteContent == String(note.body) ? true : false)
            })
            .padding()
            .onAppear(perform: self.copyNoteContent)
    }
    
    private func copyNoteContent() {
        self.noteContent = String(note.body)
    }
}

struct PrivateNoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PrivateNoteDetailView(note: Note(noteId: 1, userId: 1, latitude: "23.9889", longitude: "82.2322", timestamp: 23, body: "test"))
    }
}
