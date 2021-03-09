//
//  CreateNoteView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/28/21.
//

import SwiftUI

struct CreateNoteView: View {
        
    var noteViewModel: NoteViewModel
    
    // used in the toggle to show the user's preference between public or private
    @State private var publiclyVisible = false
    
    // what the user types in the text editor
    @State private var noteContent = ""
    
    init (noteViewModel: NoteViewModel) {
        self.noteViewModel = noteViewModel
    }
    
    var body: some View {
        VStack {
            Text("New Note")
            Form {
                Toggle(isOn: $publiclyVisible, label: {
                    Text("Public or Private?")
                })
                TextEditor(text: $noteContent)
            }
            Button(action: {insertNote()}) {
                Text("Finish")
            }
        }
    }
    
    // is it worth using the NotificationCenter instead of invoking the call?
    private func insertNote() {
        noteViewModel.insertNote(body: noteContent)
    }
}

struct CreateNoteView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNoteView(noteViewModel: NoteViewModel())
    }
}
