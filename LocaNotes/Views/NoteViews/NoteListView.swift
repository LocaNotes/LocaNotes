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
    
    @State private var sort: SortOption = SortOption.new
    
    @State private var filter: FilterOption = FilterOption.all
    
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
            .navigationBarItems(leading: FilterSort(sort: $sort, filter: $filter))
            .onAppear(perform: viewModel.refresh)
        )
    }
    
    func generatePrivateList() -> some View {
        print(sort)
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
            .navigationBarItems(leading: FilterSort(sort: $sort, filter: $filter), trailing: EditButton())
            .onAppear(perform: viewModel.refresh)
        )
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
//                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
                
                Menu {
                    Picker(selection: $sort, label: Text("Sorting options")) {
                        Text("New").tag(SortOption.new)
                        Text("Most Upvotes").tag(SortOption.mostUpvotes)
                        Text("Most Downvotes").tag(SortOption.mostDownvotes)
                    }
                } label: {
//                    Label("Sort", systemImage: "arrow.up.arrow.down")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
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
        
        notes = filter(notes: notes)
        notes = sort(notes: notes)
                
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
    
    func filter(notes: [Note]) -> [Note] {
        switch filter {
        case .all:
            return notes
        case .emergency:
            return notes.filter { $0.noteTagId == 4 }
        case .dining:
            return notes.filter { $0.noteTagId == 3 }
        case .meme:
            return notes.filter { $0.noteTagId == 2 }
        case .other:
            return notes.filter { $0.noteTagId == 1 }
        }
    }
    
    func sort(notes: [Note]) -> [Note] {
        var sortedNotes: [Note] = notes
        switch sort {
        case .new:
            sortedNotes.sort { $0.createdAt > $1.createdAt }
        case .mostUpvotes:
            sortedNotes.sort { $0.upvotes > $1.upvotes }
        case .mostDownvotes:
            sortedNotes.sort { $0.downvotes > $1.downvotes }
        }
        return sortedNotes
    }
}

enum FilterOption {
    case all
    case dining
    case emergency
    case meme
    case other
}

enum SortOption {
    case new
    case mostUpvotes
    case mostDownvotes
}

struct NoteCell: View {
    
    let note: Note
    
    var privacyLabel: PrivacyLabel
    
    var body: some View {
        VStack {
            NavigationLink(destination: DetailView(note: note, privacyLabel: privacyLabel)) {
                HStack {
                    Text(String(note.userId))
                    Text("\(String(substring(string: note.body, offset: NSString(string: note.body).length / 2)))...")
                }
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
