//
//  DetailView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct DetailView: View {
    
    let viewModel: NoteViewModel
    let note: Note
    let privacyLabel: PrivacyLabel
    
    @State var noteContent = ""
    
    @State var editing = false
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    init (note: Note, privacyLabel: PrivacyLabel) {
        self.note = note
        self.privacyLabel = privacyLabel
        self.viewModel = NoteViewModel()
    }
    var body: some View {
        switch privacyLabel {
        case PrivacyLabel.privateNote:
            generatePrivateDetail()
        default:
            generatePublicDetail()
        }
    }
    
    func generatePrivateDetail() -> some View {
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
                .disabled(self.noteContent == note.body ? true : false)
                
                Button(action: {
                    self.editing.toggle()
                    UIApplication.shared.endEditing(true)
                    viewModel.updateNoteBody(noteId: note.noteId, body: self.noteContent)
                    self.mode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "pencil")
                }
                .padding()
                .disabled(self.noteContent == note.body ? true : false)
            })
            .padding()
            .onAppear(perform: self.copyNoteContent)
    }
    
    func generatePublicDetail() -> some View {
        TextEditor(text: $noteContent)
            .disabled(true)
            .padding()
            .onAppear(perform: self.copyNoteContent)
    }
    
    private func copyNoteContent() {
        self.noteContent = note.body
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
