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
    
    let userId: String
    
    let commentViewModel: CommentViewModel
    
    @State var comments = [MongoCommentElement]()
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @State var showCommentSheet: Bool = false
    
    @State var showReportToast: Bool = false
    @State var reportToastMessage: String = ""
            
    init (note: Note, privacyLabel: PrivacyLabel) {
        self.note = note
        self.privacyLabel = privacyLabel
        self.viewModel = NoteViewModel()
        self.downvoteViewModel = DownvoteViewModel()
        self.upvoteViewModel = UpvoteViewModel()
        
        userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        
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
        
        self.commentViewModel = CommentViewModel()
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
                        
                        Menu {
                            Button {
                                reportNote(reportOption: ReportOption.offensiveBehavior)
                            } label: {
                                Text(ReportOption.offensiveBehavior.rawValue)
                            }
                            
                            Button {
                                reportNote(reportOption: ReportOption.falseInformation)
                            } label: {
                                Text(ReportOption.falseInformation.rawValue)
                            }
                            
                            Button {
                                reportNote(reportOption: ReportOption.other)
                            } label: {
                                Text(ReportOption.other.rawValue)
                            }
                        } label: {
                            Label("Report", systemImage: "exclamationmark.shield")
                        }
                    }
                    
                    Divider()
                    
                    VStack {
                        ForEach(comments, id: \.id) { comment in
                            CommentView(comment: comment)
                        }
                    }
                    .background(Color.gray)
                }
            }
            .padding()
            
            ZStack(alignment: .bottom) {
                Button(action: {
                    showCommentSheet.toggle()
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
        .alert(isPresented: $showReportToast) {
            makeReportToast(message: reportToastMessage)
        }
        .sheet(isPresented: $showCommentSheet, content: {
            EditCommentView(userId: userId, noteId: note.serverId, postCommentCallback: postCommentCallback(response:error:))
        })
        .onAppear(perform: refresh)
    }
    
    private func refresh() {
        loadComments()
        refreshVoteButtons()
    }
    
    private func makeReportToast(message: String) -> Alert {
        return Alert(title: Text("Toast"), message: Text(message), dismissButton: .cancel())
    }
    
    private func reportNote(reportOption: ReportOption) {
        let closure: ((MongoReportElement?, Error?) -> Void)? = { (response, error) in
            if response == nil {
                reportToastMessage = "Unable to report note. Try again later."
            } else {
                reportToastMessage = "Successfully reported note."
            }
            showReportToast.toggle()
        }
        let reportViewModel = ReportViewModel()
        switch reportOption {
        case .falseInformation:
            reportViewModel.insert(noteId: note.serverId, userId: userId, reportTagId: "6080f14cea85d3a0757e826c", completion: closure)
        case .offensiveBehavior:
            reportViewModel.insert(noteId: note.serverId, userId: userId, reportTagId: "6080f146ea85d3a0757e826b", completion: closure)
        default:
            reportViewModel.insert(noteId: note.serverId, userId: userId, reportTagId: "6080f137ea85d3a0757e826a", completion: closure)
        }
    }
    
    private func loadComments() {
        commentViewModel.queryCommentsFromServerBy(noteId: note.serverId, completion: { (response, error) in
            guard let response = response else {
                print("couldn't load comments")
                return
            }
            comments = response
        })
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
    
    private func postCommentCallback(response: MongoCommentElement?, error: Error?) {
        if response == nil {
            print("could not insert comment into server")
            return
        }
        comments.insert(response!, at: 0)
    }
}

enum ReportOption: String {
    case offensiveBehavior = "Offensive Behavior"
    case falseInformation = "False Information"
    case other = "Other"
}

struct CommentView: View {
    private let comment: MongoCommentElement
    private let userViewModel: UserViewModel
    private let currentUserId: String
//    @State private var showUserDetail: Bool = false
    @State private var user: MongoUserElement
    
    init(comment: MongoCommentElement) {
        self.comment = comment
        userViewModel = UserViewModel()
        currentUserId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        _user = .init(wrappedValue: MongoUserElement(id: "", firstName: "", lastName: "", email: "", username: "", password: "", createdAt: "", updatedAt: "", v: -1))
    }
    
    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: UserDetailView(user: user), label: {
                    Text(user.username)
                })
                .font(.system(size: 12, weight: .light, design: .default))
                .padding(.trailing)
                
                Text(beautifyCreatedAt())
                    .font(.system(size: 12, weight: .light, design: .default))
                Spacer()
                
                overflowButton
            }
            Text(comment.body)
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .lineLimit(nil)
        }
        .padding(.bottom, 10)
        .background(Color.white)
//        .sheet(isPresented: $showUserDetail, content: {
//            UserDetailView(user: user)
//        })
        .onAppear(perform: loadUser)
    }
    
    var overflowButton: some View {
        Group {
            if currentUserId == comment.userID {
                Menu {
                    Button(action: {
                        
                    }) {
                        Label("Edit", systemImage: "paintbrush")
                    }
                    Button(action: {
                        
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private func loadUser() {
        userViewModel.getUserBy(serverId: comment.userID, completion: { (response, error) in
            if response == nil {
                print("could not load user for comment")
                return
            }
            user = response![0]
        })
    }
    
    private func beautifyCreatedAt() -> String {
        let createdAt = comment.createdAt
        
        var result = createdAt.substring(offset: 19)
        result = result.replacingOccurrences(of: "T", with: " ")
        
        return String(result)
    }
}

struct EditCommentView: View {
    //@Binding var commentContent: String
    
    @State var commentContent: String
    
    @Environment(\.presentationMode) var presentationMode
    
    let userId: String
    let noteId: String
    
    let postCommentCallback: RESTService.RestResponseReturnBlock<MongoCommentElement>
    
//    init(commentContent: Binding<String> = Binding.constant(""), userId: String, noteId: String, postCommentCallback: RESTService.RestResponseReturnBlock<MongoCommentElement>) {
//        _commentContent = commentContent
//        self.userId = userId
//        self.noteId = noteId
//        self.postCommentCallback = postCommentCallback
//    }
    
    init(commentContent: String = "", userId: String, noteId: String, postCommentCallback: RESTService.RestResponseReturnBlock<MongoCommentElement>) {
        _commentContent = .init(wrappedValue: commentContent)
        self.userId = userId
        self.noteId = noteId
        self.postCommentCallback = postCommentCallback
    }
    
    var body: some View {
        NavigationView {
            TextEditor(text: $commentContent)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            postComment()
                        }) {
                            Text("Post")
                        }
                    }
                }
        }
    }
    
    private func postComment() {
        let commentViewModel = CommentViewModel()
        commentViewModel.insertComment(userId: userId, noteId: noteId, body: commentContent, completion: postCommentCallback)
        presentationMode.wrappedValue.dismiss()
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
