//
//  LoginView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/15/21.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
        
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: .init(colors: [Color("Color"), Color("Color-1"), Color("Color-2")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            if UIScreen.main.bounds.height > 800 {
                Home()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    Home()
                }
            }
        }
    }
}

struct Home: View {
    @State var index = 0
    
    @State var showForgotPasswordScreen = false
    
    @StateObject var viewRouter = ForgotPasswordViewRouter()
    
    var body: some View {
        VStack {
//            Image("hart_icon")
//                .resizable()
//                .frame(width: 200, height: 180)
            
            HStack {
                
                Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5)) {
                        self.index = 0
                    }
                }) {
                    Text("Existing")
                        .foregroundColor(self.index == 0 ? .black : .white)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .frame(width: (UIScreen.main.bounds.width - 50) / 2)
                }
                .background(self.index == 0 ? Color.white: Color.clear)
                .clipShape(Capsule())
                
                Button(action: {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5)) {
                        self.index = 1
                    }
                }) {
                    Text("New User")
                        .foregroundColor(self.index == 1 ? .black : .white)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .frame(width: (UIScreen.main.bounds.width - 50) / 2)
                }
                .background(self.index == 1 ? Color.white: Color.clear)
                .clipShape(Capsule())
            }
            .background(Color.black.opacity(0.1))
            .clipShape(Capsule())
            .padding(.top, 25)
            
            if self.index == 0 {
                Login()
            } else {
                SignUp(index: self.$index)
            }
            
            if self.index == 0 {
                Button(action: {
                    showForgotPasswordScreen.toggle()
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $showForgotPasswordScreen, content: {
                    ForgotPasswordView().environmentObject(viewRouter)
                })
                .padding(.top, 20)
            }
        }
        .padding()
    }
}

struct Login: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var noteViewModel: NoteViewModel
    
    @State var username = ""
    @State var pass = ""
    
    @State var didReceiveRestError = false
    @State var restResponse = ""
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    TextField("Enter username", text: self.$username)
                        .autocapitalization(.none)
                }
                .padding(.vertical, 20)
                
                Divider()
                
                HStack(spacing: 15 ) {
                    Image(systemName: "lock")
                        .resizable()
                        .frame(width: 15, height: 18)
                        .foregroundColor(.black)
                    
                    SecureField("Enter password", text: self.$pass)
                        .autocapitalization(.none)
                }
                .padding(.vertical, 20)
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top, 25)
            
            Button(action: {
                authenticateUser()
                
            }) {
                Text("LOGIN")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 100)
            }
            .background(LinearGradient(gradient: .init(colors: [Color("Color-2"), Color("Color-1"), Color("Color")]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(8)
            .offset(y: -40)
            .padding(.bottom, -40)
            .shadow(radius: 15)
        }
        .alert(isPresented: $didReceiveRestError) {
            Alert(title: Text("Log in error"), message: Text(restResponse), dismissButton: .cancel())
        }
    }
    
    private func authenticateCallback(response: [MongoUserElement]?, error: Error?) {
        if response == nil {
            if error == nil {
                restResponse = "Unknown Error"
                didReceiveRestError.toggle()
                return
            }
            restResponse = "\(error)"
            didReceiveRestError.toggle()
            return
        }
        
        let userViewModel = UserViewModel()
        var user: User?
        user = userViewModel.mongoUserDoesExistInSqliteDatabase(mongoUserElement: response![0])
        if user == nil {
            user = userViewModel.createUserByMongoUser(mongoUser: response![0])
            if user == nil {
                restResponse = "Try again"
                didReceiveRestError.toggle()
                return
            }
        }
    
        UserDefaults.standard.set(user?.username, forKey: "username")
        UserDefaults.standard.set(user?.serverId, forKey: "serverId")
        UserDefaults.standard.set(user?.userId, forKey: "userId")
        UserDefaults.standard.set(response?[0].radius, forKey: "userRadius")
        DispatchQueue.main.async {
            withAnimation {
                viewRouter.currentPage = .mainPage
            }
        }
        
        let noteViewModel = NoteViewModel()
        guard let serverId = user?.serverId else {
            return
        }
        noteViewModel.queryServerNotesBy(userId: serverId, completion: queryNotesFromServerCallback(response:error:))
    }
    
    private func authenticateUser() {
        
        let restService = RESTService()
        restService.authenticateUser(username: self.username, password: self.pass, completion: authenticateCallback(response:error:))
    }
    
    private func queryNotesFromServerCallback(response: [MongoNoteElement]?, error: Error?) {
        if response == nil {
            if error == nil {
                restResponse = "Able to log in but received Unknown Error"
                didReceiveRestError.toggle()
                return
            }
            restResponse = "\(error?.localizedDescription)"
            didReceiveRestError.toggle()
            return
        }
        
        let noteViewModel = NoteViewModel()
        noteViewModel.insertNotesFromServer(notes: response!)
        
        let userViewModel = UserViewModel()
        userViewModel.queryAllServerUsers(completion: queryAllServerUsersCallback(response:error:))
    }
    
    private func queryAllServerUsersCallback(response: [MongoUserElement]?, error: Error?) {
        if response == nil {
            if error == nil {
                restResponse = "Unknown Error"
                didReceiveRestError.toggle()
                return
            }
            restResponse = "\(error)"
            didReceiveRestError.toggle()
            return
        }
        
        let userViewModel = UserViewModel()
        userViewModel.insertUsersFromServer(users: response!)
        
        let noteViewModel = NoteViewModel()
        noteViewModel.queryAllServerPublicRegularNotes(completion: queryAllServerPublicRegularNotesCallback(response:error:))
    }
    
    private func queryAllServerPublicRegularNotesCallback(response: [MongoNoteElement]?, error: Error?) {
        if response == nil {
            if error == nil {
                restResponse = "Able to log in but received Unknown Error"
                didReceiveRestError.toggle()
                return
            }
            restResponse = "\(error)"
            didReceiveRestError.toggle()
            return
        }
        
        let noteViewModel = NoteViewModel()
        noteViewModel.insertNotesFromServer(notes: response!)
//        let serverId = response![0].userID
        
//        let commentViewModel = CommentViewModel()
//        commentViewModel.queryCommentsFromServerBy(userId: serverId, completion: queryCommentsFromServerCallback(response:error:))
//        commentViewModel.queryAllFromServer(completion: queryCommentsFromServerCallback(response:error:))
        
        let downvoteViewModel = DownvoteViewModel()
        downvoteViewModel.queryAllFromServer(completion: queryDownvotesFromServerCallback(response:error:))
    }
    
//    private func queryCommentsFromServerCallback(response: [MongoCommentElement]?, error: Error?) {
//        if response == nil {
//            if error == nil {
//                restResponse = "Able to log in but received Unknown Error"
//                didReceiveRestError.toggle()
//                return
//            }
//            restResponse = "\(error)"
//            didReceiveRestError.toggle()
//            return
//        }
//
//        let commentsViewModel = CommentViewModel()
//        commentsViewModel.insertCommentsFromServer(comments: response!)
//
//        let downvoteViewModel = DownvoteViewModel()
//        downvoteViewModel.queryAllFromServer(completion: queryDownvotesFromServerCallback(response:error:))
//    }
    
    private func queryDownvotesFromServerCallback(response: [MongoDownvoteElement]?, error: Error?) {
        if response == nil {
            if error == nil {
                restResponse = "Able to log in but received Unknown Error"
                didReceiveRestError.toggle()
                return
            }
            restResponse = "\(error?.localizedDescription)"
            didReceiveRestError.toggle()
            return
        }
        
        let downvoteViewModel = DownvoteViewModel()
        downvoteViewModel.queryAllFromServer(completion: { (response, error) in
            if response == nil {
                if error == nil {
                    restResponse = "Able to log in but received Unknown Error"
                    didReceiveRestError.toggle()
                    return
                }
                restResponse = "\(error?.localizedDescription)"
                didReceiveRestError.toggle()
                return
            }
            
            for downvote in response! {
                let serverId = downvote.id
                let userServerId = downvote.userID
                let noteServerId = downvote.noteID
                let createdAt = downvote.createdAt
                let updatedAt = downvote.updatedAt
                let v = downvote.v
                do {
                    try downvoteViewModel.insertIntoStorage(serverId: serverId, userId: userServerId, noteId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            let upvoteViewModel = UpvoteViewModel()
            upvoteViewModel.queryAllFromServer(completion: queryUpvotesFromServerCallback(response:error:))
        })
    }
    
    private func queryUpvotesFromServerCallback(response: [Upvote]?, error: Error?) {
        if response == nil {
            if error == nil {
                restResponse = "Able to log in but received Unknown Error"
                didReceiveRestError.toggle()
                return
            }
            restResponse = "\(error?.localizedDescription)"
            didReceiveRestError.toggle()
            return
        }

        let upvoteViewModel = UpvoteViewModel()
        upvoteViewModel.queryAllFromServer(completion: { (response, error) in
            if response == nil {
                if error == nil {
                    restResponse = "Able to log in but received Unknown Error"
                    didReceiveRestError.toggle()
                    return
                }
                restResponse = "\(error?.localizedDescription)"
                didReceiveRestError.toggle()
                return
            }
            
            for upvote in response! {
                let serverId = upvote.id
                let userServerId = upvote.userID
                let noteServerId = upvote.noteID
                let createdAt = upvote.createdAt
                let updatedAt = upvote.updatedAt
                let v = upvote.v
                do {
                    try upvoteViewModel.insertIntoStorage(serverId: serverId, userId: userServerId, noteId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            //let noteViewModel = NoteViewModel()
            let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
            noteViewModel.getSharedNotesFor(receiverId: userId)
        })
    }
}

