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
    
    let downvoteViewModel: DownvoteViewModel
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    init (note: Note, privacyLabel: PrivacyLabel) {
        self.note = note
        self.privacyLabel = privacyLabel
        self.viewModel = NoteViewModel()
        self.downvoteViewModel = DownvoteViewModel()
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        if let _ = downvoteViewModel.queryFromStorageBy(userId: userId, noteId: note.serverId) {
            _isDownvoted = .init(wrappedValue: true)
        } else {
            _isDownvoted = .init(wrappedValue: false)
        }
        _isUpvoted = .init(wrappedValue: false)
        
        do {
            let num = try String(downvoteViewModel.getNumberOfDownvotesFromStorageBy(noteId: note.serverId))
            _numberOfDownvotes = .init(wrappedValue: num)
        } catch {
            print("could not get number of downvotes")
            _numberOfDownvotes = .init(wrappedValue: "0")
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
                            Text(getNumberOfUpvotes())
                        }
                        
                        HStack {
                            Button(action: {
                                downvote()
                            }) {
                                Image(systemName: "arrow.down")
                                    .foregroundColor(isDownvoted ? .blue : .black)
                            }
                            //Text(getNumberOfDownvotes())
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
        }
        
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        if isUpvoted {
            upvoteViewModel.insert(userId: userId, noteId: note.serverId, completion: { (response, error) in
                if response == nil {
                    print("could not upvote")
                }
                numberOfUpvotes = getNumberOfUpvotes()
            })
        } else {
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
    }
    
    private func downvote() {
        isDownvoted.toggle()
        if isDownvoted == isUpvoted && isDownvoted == true {
            isUpvoted.toggle()
        }
        
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        if isDownvoted {
            downvoteViewModel.insert(userId: userId, noteId: note.serverId, completion: { (response, error) in
                if response == nil {
                    print("could not downvote")
                }
                numberOfDownvotes = getNumberOfDownvotes()
            })
        } else {
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
    }
    
    private func refreshVoteButtons() {
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        if let _ = downvoteViewModel.queryFromStorageBy(userId: userId, noteId: note.serverId) {
            isDownvoted = true
        } else {
            isDownvoted = false
        }
        
        numberOfDownvotes = String(getNumberOfDownvotes())
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
