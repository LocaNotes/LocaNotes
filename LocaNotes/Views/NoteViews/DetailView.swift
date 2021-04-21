//
//  DetailView.swift
//  LocaNotes
//
//  Created by Anthony C on 4/19/21.
//

import SwiftUI

struct DetailView: View {
    
    let viewModel: NoteViewModel
    let note: Note
    let privacyLabel: PrivacyLabel
    
    @State var noteContent = ""
    
    @State var editing = false
        
    @State var isDownvoted: Bool
    @State var isUpvoted: Bool
    
    @State var numberOfDownvotes: String
    @State var numberOfUpvotes: String
    
    let downvoteViewModel: DownvoteViewModel
    let upvoteViewModel: UpvoteViewModel
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    init (note: Note, privacyLabel: PrivacyLabel) {
        self.note = note
        self.privacyLabel = privacyLabel
        self.viewModel = NoteViewModel()
        self.downvoteViewModel = DownvoteViewModel()
        self.upvoteViewModel = UpvoteViewModel()
        
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        
        // determine whether the downvote button should be marked as upvoted
        if let _ = downvoteViewModel.queryFromStorageBy(userId: userId, noteId: note.serverId) {
            _isDownvoted = .init(wrappedValue: true)
        } else {
            _isDownvoted = .init(wrappedValue: false)
        }
        
        // determine whether the upvote button should be marked as upvoted
        if let _ = upvoteViewModel.queryFromStorageBy(userId: userId, noteId: note.serverId) {
            _isUpvoted = .init(wrappedValue: true)
        } else {
            _isUpvoted = .init(wrappedValue: false)
        }
        
        // get the number of downvotes
        do {
            let num = try String(downvoteViewModel.getNumberOfDownvotesFromStorageBy(noteId: note.serverId))
            _numberOfDownvotes = .init(wrappedValue: num)
        } catch {
            print("could not get number of downvotes")
            _numberOfDownvotes = .init(wrappedValue: "0")
        }
        
        // get the number of upvotes
        do {
            let num = try String(upvoteViewModel.getNumberOfUpvotesFromStorageBy(noteId: note.serverId))
            _numberOfUpvotes = .init(wrappedValue: num)
        } catch {
            print("could not get number of upvotes")
            _numberOfUpvotes = .init(wrappedValue: "0")
        }
    }
    
    var body: some View {
        switch privacyLabel {
        case PrivacyLabel.privateNote:
            generatePrivateDetail()
        default:
            generatePublicDetail()
        }
    }
    
    func generatePrivateDetail() -> some View {
        TextEditor(text: $noteContent)
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    UIApplication.shared.endEditing(true)
                }) {
                    Image(systemName: "xmark")
                }
                .padding()
                
                Button(action: {
                    self.copyNoteContent()
                    UIApplication.shared.endEditing(true)
                }) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .padding()
                .disabled(self.noteContent == note.body ? true : false)
                
                Button(action: {
                    self.editing.toggle()
                    UIApplication.shared.endEditing(true)
                    viewModel.updateNoteBody(noteId: note.noteId, body: self.noteContent)
                    self.mode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "pencil")
                }
                .padding()
                .disabled(self.noteContent == note.body ? true : false)
            })
            .padding()
            .onAppear(perform: self.copyNoteContent)
    }
    
    func generatePublicDetail() -> some View {
        VStack {
            ScrollView {
                VStack {
                    Text(note.body)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Divider()
                    
                    HStack {
                        HStack {
                            Button(action: {
                                upvote()
                            }) {
                                Image(systemName: "arrow.up")
                                    .foregroundColor(isUpvoted ? .red : .black)
                            }
                            Text(numberOfUpvotes)
                        }
                        
                        HStack {
                            Button(action: {
                                downvote()
                            }) {
                                Image(systemName: "arrow.down")
                                    .foregroundColor(isDownvoted ? .blue : .black)
                            }
                            Text(numberOfDownvotes)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            
            ZStack(alignment: .bottom) {
                Button(action: {
                    
                }) {
                    Text("Comment...")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.purple)
            .shadow(color: Color.black, radius: 10, x: 0, y: 10)
            //.alignmentGuide(.bottom) { d in d[.bottom] / 2 }
        }
        .onAppear(perform: refreshVoteButtons)
    }
    
    private func getNumberOfUpvotes() -> String {
        do {
            let num = try upvoteViewModel.getNumberOfUpvotesFromStorageBy(noteId: note.serverId)
            return String(num)
        } catch {
            print("could not get number of upvotes")
            return "0"
        }
    }
    
    private func getNumberOfDownvotes() -> String {
        do {
            let num = try downvoteViewModel.getNumberOfDownvotesFromStorageBy(noteId: note.serverId)
            return String(num)
        } catch {
            print("could not get number of downvotes")
            return "0"
        }
    }
    
    private func upvote() {
        isUpvoted.toggle()
        if isUpvoted == isDownvoted && isUpvoted == true {
            isDownvoted.toggle()
            deleteDownvote()
        }
        
        if isUpvoted {
            insertUpvote()
        } else {
            deleteUpvote()
        }
    }
    
    private func downvote() {
        isDownvoted.toggle()
        if isDownvoted == isUpvoted && isDownvoted == true {
            isUpvoted.toggle()
            deleteUpvote()
        }
        
        if isDownvoted {
            insertDownvote()
        } else {
            deleteDownvote()
        }
    }
    
    private func insertUpvote() {
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        upvoteViewModel.insert(userId: userId, noteId: note.serverId, completion: { (response, error) in
            if response == nil {
                print("could not upvote")
            }
            numberOfUpvotes = getNumberOfUpvotes()
        })
    }
    
    private func deleteUpvote() {
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        guard let upvote = upvoteViewModel.queryFromStorageBy(userId: userId, noteId: note.serverId) else {
            print("could not undo upvote")
            return
        }
        upvoteViewModel.delete(upvoteId: upvote.id, completion: { (response, error) in
            if response == nil {
                print("could not undo upvote")
            }
            numberOfUpvotes = getNumberOfUpvotes()
        })
    }
    
    private func insertDownvote() {
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        downvoteViewModel.insert(userId: userId, noteId: note.serverId, completion: { (response, error) in
            if response == nil {
                print("could not downvote")
            }
            numberOfDownvotes = getNumberOfDownvotes()
        })
    }
    
    private func deleteDownvote() {
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        guard let downvote = downvoteViewModel.queryFromStorageBy(userId: userId, noteId: note.serverId) else {
            print("could not undo downvote")
            return
        }
        downvoteViewModel.delete(downvoteId: downvote.id, completion: { (response, error) in
            if response == nil {
                print("could not undo downvote")
            }
            numberOfDownvotes = getNumberOfDownvotes()
        })
    }
    
    private func refreshVoteButtons() {
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        
        // refresh downvote button
        if let _ = downvoteViewModel.queryFromStorageBy(userId: userId, noteId: note.serverId) {
            isDownvoted = true
        } else {
            isDownvoted = false
        }
        
        // refresh upvote button
        if let _ = upvoteViewModel.queryFromStorageBy(userId: userId, noteId: note.serverId) {
            isUpvoted = true
        } else {
            isUpvoted = false
        }
        
        // refresh downvote counter
        numberOfDownvotes = getNumberOfDownvotes()
        
        // refresh upvote counter
        numberOfUpvotes = getNumberOfUpvotes()
    }
    
    private func copyNoteContent() {
        self.noteContent = note.body
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
