//
//  PrivateNoteDetailView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/25/21.
//

import SwiftUI

struct PrivateNoteDetailView: View {
    
    // the note that this view shows
    let note: Note
    
    var body: some View {
        Text(String(note.body))
    }
}

struct PrivateNoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PrivateNoteDetailView(note: Note(noteId: 1, userId: 1, latitude: "23.9889", longitude: "82.2322", timestamp: 23, body: "test"))
    }
}
