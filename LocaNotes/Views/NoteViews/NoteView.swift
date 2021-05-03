//
//  NoteView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct NoteView: View {
    @StateObject var viewModel = NoteViewModel()
    
    var privacyLabel: PrivacyLabel
    
    // what the user types in the search bar
    @State private var searchText: String = ""
    
    init (privacyLabel: PrivacyLabel) {
        self.privacyLabel = privacyLabel
    }
    
    @State var refreshAnnos: Bool = false
    
    @State private var sort: SortOption = SortOption.new
    
    @State private var filter: FilterOption = FilterOption.all
    
    var body: some View {
        NavigationView {
            VStack {
                NoteMapView(viewModel: viewModel, searchText: $searchText, privacyLabel: privacyLabel)
                NoteListView(viewModel: viewModel, searchText: $searchText, sort: $sort, filter: $filter, privacyLabel: privacyLabel)
            }
        }
    }
}



//struct NoteView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteView()
//    }
//}
