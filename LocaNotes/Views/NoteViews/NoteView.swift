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
    
    @State var refreshAnnos: Bool = false
    
    @State private var sort: SortOption = SortOption.new
    
    @State private var filter: FilterOption = FilterOption.all
    
    var body: some View {
        NavigationView {
            VStack {
                NoteMapView(viewModel: viewModel, searchText: $searchText, privacyLabel: privacyLabel)
                NoteListView(viewModel: viewModel, searchText: $searchText, sort: $sort, filter: $filter, privacyLabel: privacyLabel)
            }
            .navigationBarItems(leading: FilterSort(sort: $sort, filter: $filter), trailing: EditButton())
//            .navigationBarItems(leading: navButtons(sort: $sort, filter: $filter, refreshAnnos: $refreshAnnos, callback: {
//                self.refreshAnnos.toggle()
//            }), trailing: EditButton())
        }
    }
    
    struct FilterSort: View {
        @Binding var sort: SortOption
        @Binding var filter: FilterOption
        
        var body: some View {
            HStack {
                Menu {
                    Picker(selection: $filter, label: Text("Filter options")) {
                        Text("All").tag(FilterOption.all)
                        Text("Emergency").tag(FilterOption.emergency)
                        Text("Dining").tag(FilterOption.dining)
                        Text("Meme").tag(FilterOption.meme)
                        Text("Other").tag(FilterOption.other)
                        Divider()
                    }
                } label: {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
                
                Menu {
                    Picker(selection: $sort, label: Text("Sorting options")) {
                        Text("New").tag(SortOption.new)
                        Text("Most Upvotes").tag(SortOption.mostUpvotes)
                        Text("Most Downvotes").tag(SortOption.mostDownvotes)
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
    }
    
    struct navButtons: View {
        @Binding var sort: SortOption
        @Binding var filter: FilterOption
        @Binding var refreshAnnos: Bool
        
        let callback: () -> Void
        
        var body: some View {
            HStack {
                FilterSort(sort: $sort, filter: $filter)
                Button(action: {
                    callback()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}



//struct NoteView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteView()
//    }
//}
