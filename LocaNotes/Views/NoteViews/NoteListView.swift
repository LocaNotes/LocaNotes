//
//  NoteListView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct NoteListView: View {
//    @ObservedObject var viewModel: NoteViewModel
    
    @EnvironmentObject var noteViewModel: NoteViewModel
    
    @Binding var searchText: String
        
    @Binding var sortOption: SortOption
    @Binding var filterOption: FilterOption
        
//    private var privacyLabel: PrivacyLabel
    private var layout: NoteViewLayout
        
    private var privateNotes: [Note] {
//        return viewModel.privateNotes
        return noteViewModel.privateNotes
    }
    
    private var sharedNotes: [Note] {
        return noteViewModel.sharedNotes
    }
    
    private var nearbyPrivateNotes: [Note] {
//        return viewModel.nearbyPrivateNotes
        return noteViewModel.nearbyPrivateNotes
    }
    
    private var filteredSortedPrivateNotes: [Note] {
//        var notes = viewModel.privateNotes
        var notes = noteViewModel.privateNotes
        notes = filter(notes: notes)
        notes = sort(notes: notes)
        return notes
    }
    
    private var publicNotes: [Note] {
        return noteViewModel.publicNotes
    }
    
    private var nearbyPublicNotes: [Note] {
        return noteViewModel.nearbyPublicNotes
    }
    
    private var nearbyStories: [Note] {
        return noteViewModel.nearbyStories
    }
    
    private var sharedStories: [Note] {
        return noteViewModel.sharedStories
    }
    
    private var myStories: [Note] {
        return noteViewModel.myStories
    }
    
//    init(viewModel: NoteViewModel, searchText: Binding<String>, sort: Binding<SortOption>, filter: Binding<FilterOption>, privacyLabel: PrivacyLabel) {
////        self.viewModel = NoteViewModel()
//        self._searchText = searchText
//        self._sortOption = sort
//        self._filterOption = filter
//        self.privacyLabel = privacyLabel
//    }
    
    init(viewModel: NoteViewModel, searchText: Binding<String>, sort: Binding<SortOption>, filter: Binding<FilterOption>, layout: NoteViewLayout) {
        self._searchText = searchText
        self._sortOption = sort
        self._filterOption = filter
        self.layout = layout
    }
    
    var body: some View {
        SearchBarView(searchText: $searchText)
            .frame(width: UIScreen.main.bounds.width + 20, height: 40, alignment: .bottom)
        
//        switch privacyLabel {
//        case PrivacyLabel.privateNote:
//            generatePrivateList()
//        case PrivacyLabel.publicNote:
//            generatePublicList()
//        }
        switch layout {
        case NoteViewLayout.privateNotes:
            generatePrivateList()
        case NoteViewLayout.publicNotes:
            generatePublicList()
        case NoteViewLayout.stories:
            generateStoriesList()
        }
    }
    
    func generatePublicList() -> some View {
//        let nearbyNotes: [Note] = viewModel.nearbyPublicNotes
        let nearbyNotes: [Note] = noteViewModel.nearbyPublicNotes
        return (
            List {
                if !nearbyNotes.isEmpty {
                    Section(header: Text("Nearby")) {
                        generateRows(notes: nearbyPublicNotes)
                    }
                }
                Section(header: Text("Public Notes")) {
                    generateRows(notes: publicNotes)
                }
            }
            .navigationBarItems(leading: FilterSortButtons(sort: $sortOption, filter: $filterOption))
//            .onAppear(perform: viewModel.refresh)
            .onAppear(perform: noteViewModel.refresh)
        )
    }
    
    func generatePrivateList() -> some View {
        return (
            List {
                if !nearbyPrivateNotes.isEmpty {
                    Section(header: Text("Nearby")) {
                        generateRows(notes: nearbyPrivateNotes)
                    }
                }
                Section(header: Text("Private Notes")) {
                    generateRows(notes: privateNotes)
                }
                if !sharedNotes.isEmpty {
                    Section(header: Text("Shared with me")) {
                        generateRows(notes: sharedNotes)
                    }
                }
            }
            .navigationBarItems(leading: FilterSortButtons(sort: $sortOption, filter: $filterOption), trailing: EditButton())
//            .onAppear(perform: viewModel.refresh)
            .onAppear(perform: noteViewModel.refresh)
        )
    }
    
    func generateStoriesList() -> some View {
        List {
            Section(header: Text("Nearby stories")) {
                generateRows(notes: nearbyStories)
            }
            Section(header: Text("Shared with me")) {
                generateRows(notes: sharedStories)
            }
            Section(header: Text("My stories")) {
                generateRows(notes: myStories)
            }
        }
        .navigationBarItems(leading: FilterSortButtons(sort: $sortOption, filter: $filterOption), trailing: EditButton())
        .onAppear(perform: noteViewModel.refresh)
    }
    
    struct FilterSortButtons: View {
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
    
    func generateRows(notes: [Note]) -> some View {
        var notes = notes
//        switch (nearbyOnly, self.privacyLabel) {
//        case (true, PrivacyLabel.privateNote):
////            notes = viewModel.nearbyPrivateNotes
//            notes = noteViewModel.nearbyPrivateNotes
//        case (true, PrivacyLabel.publicNote):
////            notes = viewModel.nearbyPublicNotes
//            notes = noteViewModel.nearbyPublicNotes
//        case (false, PrivacyLabel.privateNote):
////            notes = viewModel.privateNotes
//            notes = noteViewModel.privateNotes
//        case (false, PrivacyLabel.publicNote):
////            notes = viewModel.publicNotes
//            notes = noteViewModel.publicNotes
//        }
        
//        switch (nearbyOnly, self.layout) {
//        case (true, NoteViewLayout.privateNotes):
//            notes = noteViewModel.nearbyPrivateNotes
//        case (true, NoteViewLayout.publicNotes):
//            notes = noteViewModel.nearbyPublicNotes
//        case (false, NoteViewLayout.privateNotes):
//            notes = noteViewModel.privateNotes
//        case (false, NoteViewLayout.publicNotes):
//            notes = noteViewModel.publicNotes
//        case (_, NoteViewLayout.stories):
//            notes = noteViewModel.stories
//        }
        
        notes = filter(notes: notes)
        notes = sort(notes: notes)
                
        return (
            ForEach (notes.filter({ note in
                self.searchText.isEmpty ? true :
                    note.body.lowercased().contains(self.searchText.lowercased())
            }), id: \.noteId) { note in
//                NoteCell(note: note, privacyLabel: privacyLabel)
                NoteCell(note: note, layout: self.layout)
            }
            .onDelete(perform: deletePrivateNote)
        )
    }
    
    private func deletePrivateNote(at offsets: IndexSet) {
        let loggedInUserId = UserDefaults.standard.string(forKey: "serverId")
        let selectedNoteId = filteredSortedPrivateNotes[offsets.first!].noteId
        var index: Int = -1
        for i in 0..<privateNotes.count {
            let note = privateNotes[i]
            let id = note.noteId
            if id == selectedNoteId {
                index = i
                
                // If loggedInUserId isnt the same as the note's author, then the note is shared
                // and we shouldn't delete it. userServerId could be empty if it's a private note
                // and not shared
                if loggedInUserId != note.userServerId && !note.userServerId.isEmpty {
                    return
                }
            }
        }
        if index > -1 {
//            viewModel.deleteNote(at: IndexSet(integer: index))
            noteViewModel.deleteNote(at: IndexSet(integer: index))
        }
    }
    
    func filter(notes: [Note]) -> [Note] {
        switch filterOption {
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
        switch sortOption {
        case .new:
            sortedNotes.sort { $0.createdAt > $1.createdAt }
        case .mostUpvotes:
            sortedNotes.sort {
                do {
                    let upvoteViewModel = UpvoteViewModel()
                    let count0 = try upvoteViewModel.getNumberOfUpvotesFromStorageBy(noteId: $0.serverId)
                    let count1 = try upvoteViewModel.getNumberOfUpvotesFromStorageBy(noteId: $1.serverId)
                    return count0 > count1
                } catch {
                    return false
                }
            }
        case .mostDownvotes:
            sortedNotes.sort {
                do {
                    let downvoteViewModel = DownvoteViewModel()
                    let count0 = try downvoteViewModel.getNumberOfDownvotesFromStorageBy(noteId: $0.serverId)
                    let count1 = try downvoteViewModel.getNumberOfDownvotesFromStorageBy(noteId: $1.serverId)
                    return count0 > count1
                } catch {
                    return false
                }
            }
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
    
    private let note: Note
    
//    private let privacyLabel: PrivacyLabel
    private let layout: NoteViewLayout
    
    private let userViewModel: UserViewModel
    
    @State private var username = ""
        
//    init(note: Note, privacyLabel: PrivacyLabel) {
//        self.note = note
//        self.privacyLabel = privacyLabel
//        userViewModel = UserViewModel()
////        userViewModel.getUserBy(serverId: note.userServerId, completion: { [self] (response, error) in
////            if response == nil {
////                print("could not query user from server")
////                return
////            }
////            username = response![0].username
////        })
//    }
    
    init(note: Note, layout: NoteViewLayout) {
        self.note = note
        self.layout = layout
        userViewModel = UserViewModel()
    }
    
    var body: some View {
        VStack {
//            NavigationLink(destination: DetailView(note: note, privacyLabel: privacyLabel)) {
            NavigationLink(destination: DetailView(note: note, layout: layout)) {
                VStack {
                    HStack {
                        Text(username)
                            .italic()
                        Spacer()
                    }
                    HStack {
                        Text("\(note.body.substring(offset: note.body.count / 2))...")
                            .lineLimit(2)
                        Spacer()
                    }
                }
            }
        }.onAppear(perform: loadUser)
    }
    
    private func loadUser() {
        userViewModel.getUserBy(serverId: note.userServerId, completion: { (response, error) in
            if response == nil {
                print("could not query user from server")
                return
            }
            if response!.count > 0 {
                username = response![0].username
            }
            
        })
    }
}

//struct NoteListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteListView()
//    }
//}
