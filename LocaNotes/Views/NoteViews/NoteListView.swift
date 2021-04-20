//
//  NoteListView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct NoteListView: View {
    @ObservedObject var viewModel: NoteViewModel
    
    @Binding var searchText: String
    
    var privacyLabel: PrivacyLabel
    
    var body: some View {
        SearchBarView(searchText: $searchText)
            .frame(width: UIScreen.main.bounds.width+20, height: 40, alignment: .bottom)
        
        switch privacyLabel {
        case PrivacyLabel.privateNote:
            generatePrivateList()
        case PrivacyLabel.publicNote:
            generatePublicList()
        }
    }
    
    func generatePublicList() -> some View {
        let nearbyNotes: [Note] = viewModel.nearbyPublicNotes
        return (
            List {
                if !nearbyNotes.isEmpty {
                    Section(header: Text("Nearby")) {
                        generateRow(nearbyOnly: true)
                    }
                }
                Section(header: Text("All")) {
                    generateRow(nearbyOnly: false)
                }
            }
            .onAppear(perform: viewModel.refresh)
        )
    }
    
    func generatePrivateList() -> some View {
        let nearbyNotes: [Note] = viewModel.nearbyPrivateNotes
        return (
            List {
                if !nearbyNotes.isEmpty {
                    Section(header: Text("Nearby")) {
                        generateRow(nearbyOnly: true)
                    }
                }
                Section(header: Text("All")) {
                    generateRow(nearbyOnly: false)
                }
            }
            .navigationBarItems(trailing: EditButton())
            .onAppear(perform: viewModel.refresh)
        )
    }
    
    func generateRow(nearbyOnly: Bool) -> some View {
        var notes: [Note]
        switch (nearbyOnly, self.privacyLabel) {
        case (true, PrivacyLabel.privateNote):
            notes = viewModel.nearbyPrivateNotes
        case (true, PrivacyLabel.publicNote):
            notes = viewModel.nearbyPublicNotes
        case (false, PrivacyLabel.privateNote):
            notes = viewModel.privateNotes
        case (false, PrivacyLabel.publicNote):
            notes = viewModel.publicNotes
        }
                
        return (
            ForEach (notes.filter({ note in
                self.searchText.isEmpty ? true :
                    String(note.body).lowercased().contains(self.searchText.lowercased())
            }), id: \.noteId) { note in
                NoteCell(note: note, privacyLabel: privacyLabel)
            }
            .onDelete(perform: viewModel.deleteNote)
        )
    }
}

struct NoteCell: View {
    
    let note: Note
    
    var privacyLabel: PrivacyLabel
    
    var body: some View {
        NavigationLink(destination: DetailView(note: note, privacyLabel: privacyLabel)) {
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

//struct NoteListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteListView()
//    }
//}
