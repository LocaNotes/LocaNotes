//
//  NoteListView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct NoteListView: View {
    
    @EnvironmentObject var noteViewModel: NoteViewModel
    
    @Binding var searchText: String
    
    @Binding var isShowingMapView: Bool
        
    @Binding var sortOption: SortOption
    @Binding var filterOption: FilterOption
        
    private var layout: NoteViewLayout
        
    private var privateNotes: [Note] {
        return noteViewModel.privateNotes
    }
    
    private var sharedNotes: [Note] {
        return noteViewModel.sharedNotes
    }
    
    private var nearbyPrivateNotes: [Note] {
        return noteViewModel.nearbyPrivateNotes
    }
    
    private var filteredSortedPrivateNotes: [Note] {
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
    
    init(viewModel: NoteViewModel, searchText: Binding<String>, isShowingMapView: Binding<Bool>, sort: Binding<SortOption>, filter: Binding<FilterOption>, layout: NoteViewLayout) {
        self._searchText = searchText
        self._isShowingMapView = isShowingMapView
        self._sortOption = sort
        self._filterOption = filter
        self.layout = layout
    }
    
    var body: some View {
        SearchBarView(searchText: $searchText)
            .frame(width: UIScreen.main.bounds.width + 20, height: 40, alignment: .bottom)
        
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
            .navigationBarItems(leading: HeaderButtons(sort: $sortOption, filter: $filterOption, isShowingMapView: $isShowingMapView), trailing: EditButton())
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
            .navigationBarItems(leading: HeaderButtons(sort: $sortOption, filter: $filterOption, isShowingMapView: $isShowingMapView), trailing: EditButton())
            .onAppear(perform: noteViewModel.refresh)
        )
    }
    
    func generateStoriesList() -> some View {
        List {
            Section(header: Text("Nearby")) {
                generateRows(notes: nearbyStories)
            }
            Section(header: Text("Friends")) {
                generateRows(notes: sharedStories)
            }
            Section(header: Text("My stories")) {
                generateRows(notes: myStories)
            }
        }
        .navigationBarItems(leading: HeaderButtons(sort: $sortOption, filter: $filterOption, isShowingMapView: $isShowingMapView), trailing: EditButton())
        .onAppear(perform: noteViewModel.refresh)
    }
    
    struct HeaderButtons: View {
        @Binding var sort: SortOption
        @Binding var filter: FilterOption
        @Binding var isShowingMapView: Bool
        
        var body: some View {
            HStack {
                FilterSortButtons(sort: $sort, filter: $filter)
                Button(action: {
                    withAnimation {
                        isShowingMapView.toggle()
                    }
                }) {
                    Image(systemName: "map.fill")
                }
            }
        }
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
                    Image(systemName: "line.horizontal.3.decrease.circle.fill")
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
        
        notes = filter(notes: notes)
        notes = sort(notes: notes)
                
        return (
            ForEach (notes.filter({ note in
                self.searchText.isEmpty ? true :
                    note.body.lowercased().contains(self.searchText.lowercased())
            }), id: \.noteId) { note in
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
    
    private let layout: NoteViewLayout
    
    private let userViewModel: UserViewModel
    private let noteTagViewModel: NoteTagViewModel
    
    @State private var author = MongoUserElement(
        id: "",
        firstName: "",
        lastName: "",
        email: "",
        username: "",
        password: "",
        createdAt: "",
        updatedAt: "",
        v: -1,
        radius: -1
    )
    
    @State private var noteTag = ""
    
    init(note: Note, layout: NoteViewLayout) {
        self.note = note
        self.layout = layout
        userViewModel = UserViewModel()
        noteTagViewModel = NoteTagViewModel()
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: DetailView(note: note, author: author, noteTag: noteTag, layout: layout)) {
                VStack {
                    HStack {
                        Text(author.username)
                            .bold()
                        Spacer()
                    }
                    HStack {
                        Text("\(note.body.substring(offset: note.body.count / 2))...")
                            .lineLimit(2)
                        Spacer()
                    }
                }
            }
        }.onAppear(perform: loadNote)
    }
    
    private func loadNote() {
        loadAuthor()
        loadNoteTag()
    }
    
    private func loadAuthor() {
        userViewModel.getUserBy(serverId: note.userServerId, completion: { (response, error) in
            if response == nil {
                print("could not query user from server")
                return
            }
            if response!.count > 0 {
                author = response![0]
            }
        })
    }
    
    private func loadNoteTag() {
        do {
            let query = try noteTagViewModel.queryBy(noteTagId: note.noteTagId)
            guard let noteTag = query else {
                return
            }
            self.noteTag = noteTag.label
        } catch {
            print("could not query note tag")
        }
    }
}
