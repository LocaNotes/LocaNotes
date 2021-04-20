//
//  PublicNoteListView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct PublicNoteListView: View {
    @ObservedObject var viewModel: NoteViewModel
    
    // what the user types in the search bar
    @State private var searchText: String = ""
    
    init (viewModel: NoteViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                MapNoteView(viewModel: viewModel, searchText: $searchText, privacyLabel: PrivacyLabel.publicNote)
                ListNoteView(viewModel: viewModel, searchText: $searchText, privacyLabel: PrivacyLabel.publicNote)
            }
    //        .navigationBarItems(leading: Button("Refresh", action: {
    //            updateAnnos() //! doesn't always refresh properly :(
    //        }), trailing: EditButton())
    //        .onAppear(perform: viewModel.refresh)
    //        .navigationTitle("Notes")
        }
    }
}

//struct PublicNoteListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PublicNoteListView()
//    }
//}
