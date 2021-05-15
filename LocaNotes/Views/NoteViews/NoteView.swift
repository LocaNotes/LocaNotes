//
//  NoteView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct NoteView: View {
    
    @StateObject var viewModel = NoteViewModel()
    
    var layout: NoteViewLayout
    
    // what the user types in the search bar
    @State private var searchText: String = ""
    
    init (layout: NoteViewLayout) {
        self.layout = layout
    }
    
    @State var refreshAnnos: Bool = false
    
    @State private var sort: SortOption = SortOption.new
    
    @State private var filter: FilterOption = FilterOption.all
    
    @State private var isShowingMapView = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isShowingMapView {
                    NoteMapView(viewModel: viewModel, searchText: $searchText, privacyLabel: layout == NoteViewLayout.privateNotes ? .privateNote : .publicNote)
                }
                NoteListView(viewModel: viewModel, searchText: $searchText, isShowingMapView: $isShowingMapView, sort: $sort, filter: $filter, layout: layout)
            }
        }
    }
}

enum NoteViewLayout {
    case privateNotes
    case publicNotes
    case stories
}
