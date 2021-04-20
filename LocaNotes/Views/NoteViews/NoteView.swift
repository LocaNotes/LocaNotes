//
//  NoteView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct NoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    
    var privacyLabel: PrivacyLabel
    
    // what the user types in the search bar
    @State private var searchText: String = ""
    
    init (viewModel: NoteViewModel, privacyLabel: PrivacyLabel) {
        self.viewModel = viewModel
        self.privacyLabel = privacyLabel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                NoteMapView(viewModel: viewModel, searchText: $searchText, privacyLabel: privacyLabel)
                NoteListView(viewModel: viewModel, searchText: $searchText, privacyLabel: privacyLabel)
            }
        }
    }
}

//struct NoteView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteView()
//    }
//}
