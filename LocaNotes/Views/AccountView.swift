//
//  AccountView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/17/21.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State private var radius: Double
        
    init() {
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
        let userRadius = UserDefaults.standard.double(forKey: "userRadius")
        self._radius = .init(wrappedValue: userRadius)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: FriendsView()) {
                        Text("Friends")
                    }
                    
                    NavigationLink(destination: SettingsView(), label: {
                        Text("Settings")
                    })
                    
                    Button(action: {
                        withAnimation {
                            viewRouter.currentPage = .loginPage
                        }
                    }) {
                        Text("Log out")
                    }
                }
                Text("Current radius: \(radius) miles")
                Slider(value: $radius, in: 1...100, step: 1.0)
            }
            .navigationBarTitle("Account")
        }
        .onDisappear(perform: updateUserRadius)
    }
    
    private func updateUserRadius() {
        let userViewModel = UserViewModel()
        let userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
        userViewModel.updateUser(radius: self.radius, userId: userId, completion: { (response, error) in
            if response == nil {
                print("update radius error: \(error?.localizedDescription)")
            } else {
                UserDefaults.standard.set(radius, forKey: "userRadius")
            }
        })
    }
}

struct FriendsView: View {
    var body: some View {
        List {
            NavigationLink(destination: FriendsListView(), label: {
                Text("Friends List")
            })
            
            NavigationLink(destination: AddFriendsView(), label: {
                Text("Add Friends")
            })
        }
    }
}

struct FriendsListView: View {
    
    @State private var searchText: String = ""
    
    @State private var friends: [MongoUserElement] = []
    
    private let userViewModel: UserViewModel
    
    private let userId: String
    
    init() {
        userViewModel = UserViewModel()
        userId = UserDefaults.standard.string(forKey: "serverId") ?? ""
    }
    
    var body: some View {
        VStack {
            List(self.searchText.isEmpty ? friends : friends.filter({ user in
                user.username.lowercased().contains(self.searchText.lowercased())
            }), id: \.id) { user in
                UserCell(user: user)
            }
        }
        .navigationTitle("Friends List")
        .onAppear(perform: loadFriends)
    }
    
    private func loadFriends() {
        userViewModel.getFriendListFor(userId: userId, completion: { [self] (response, error) in
            if response == nil {
                friends = []
            } else {
                friends = response!
            }
        })
    }
}

struct AddFriendsView: View {
    @State private var searchText: String = ""
    
    @State private var users: [MongoUserElement] = []
    
    private let userViewModel: UserViewModel
    
    init() {
        userViewModel = UserViewModel()
    }
    
    var body: some View {
        VStack {
            SearchBarView(searchText: $searchText, onCommitCallback: searchForUser)
            List(users, id: \.id) { user in
                UserCell(user: user)
            }
        }
        .navigationTitle("Add Friends")
    }
    
    private func searchForUser() {
        userViewModel.searchForUserBy(username: searchText) { (response, error) in
            if response != nil {
                users = response!
            } else {
                users = []
            }
        }
    }
}

struct UserCell: View {
    
    private let user: MongoUserElement
        
    init(user: MongoUserElement) {
        self.user = user
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: UserDetailView(user: user)) {
                VStack {
                    HStack {
                        Text(user.username)
                            .bold()
                        Spacer()
                    }
                }
            }
        }
    }
}

struct UserDetailView: View {
    private let user: MongoUserElement
    
    private let userViewModel: UserViewModel
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastTitle: String = ""
    @State private var isFriendsWithCurrentUser: Bool = false
    
    private let loggedInUser: String
    
    private let removeFriendError: String
    private let addedFriendError: String
    
    private let removeFriendSuccess: String
    private let addedFriendSuccess: String
    
    init(user: MongoUserElement) {
        self.user = user
        userViewModel = UserViewModel()
        loggedInUser = UserDefaults.standard.string(forKey: "serverId") ?? ""
        removeFriendError = "Could not remove friend."
        addedFriendError = "Could not add friend."
        removeFriendSuccess = "Successfully removed friend."
        addedFriendSuccess = "Successfully added as a friend!"
    }
    
    var body: some View {
        VStack {
            Text(user.username)
                .font(.system(size: 30, weight: .bold))
            List {
                Button(action: {
                    
                }, label: {
                    Text("Send Direct Message")
                })
                
                if isFriendsWithCurrentUser {
                    Button(action: {
                        removeFriend()
                    }) {
                        Text("Remove Friend")
                    }
                } else {
                    Button(action: {
                        addFriend()
                    }) {
                        Text("Add Friend")
                    }
                }
            }
        }
        .alert(isPresented: $showToast) {
            makeToast(title: toastTitle, message: toastMessage)
        }
        .onAppear(perform: checkIfFriend)
    }
    
    private func checkIfFriend() {
        userViewModel.checkIfFriends(frienderId: loggedInUser, friendeeId: user.id, completion: { (response, error) in
            if response == nil {
                isFriendsWithCurrentUser = true
            } else {
                if response!.isEmpty {
                    isFriendsWithCurrentUser = false
                } else {
                    isFriendsWithCurrentUser = true
                }
            }
        })
    }
    
    private func removeFriend() {
        if loggedInUser.isEmpty {
            showErrorToast(error: removeFriendError)
        } else {
            userViewModel.removeFriend(frienderId: loggedInUser, friendeeId: user.id, completion: { (response, error) in
                if response == nil {
                    showErrorToast(error: removeFriendError)
                } else {
                    isFriendsWithCurrentUser = false
                    showSuccessToast(message: removeFriendSuccess)
                }
            })
        }
    }
    
    private func addFriend() {
        if loggedInUser.isEmpty {
            showErrorToast(error: addedFriendError)
        } else {
            userViewModel.addFriend(frienderId: loggedInUser, friendeeId: user.id, completion: { (response, error) in
                if response == nil {
                    showErrorToast(error: addedFriendError)
                } else {
                    isFriendsWithCurrentUser = true
                    showSuccessToast(message: addedFriendSuccess)
                }
            })
        }
    }
    
    private func makeToast(title: String, message: String) -> Alert {
        return Alert(title: Text(title), message: Text(message), dismissButton: .cancel())
    }
    
    private func showErrorToast(error: String) {
        toastTitle = "Error"
        toastMessage = error
        showToast = true
    }
    
    private func showSuccessToast(message: String) {
        toastTitle = "Success"
        toastMessage = message
        showToast = true
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
