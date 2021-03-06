//
//  SettingsView.swift
//  LocaNotes
//
//  Created by Elijah Monzon on 3/26/21.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    private let viewModel: UserViewModel
    private let supportEmail = ["eli.develops@gmail.com"] //Email for app support
    
    @State private var showEmailSheet: Bool = false
    @State private var showPasswordSheet: Bool = false
    @State private var showUsernameSheet: Bool = false
    
    init() {
        viewModel = UserViewModel()
    }
    
    var body: some View {
                
        List {
            Button(action: {
                //update email
                self.showEmailSheet.toggle()
            }, label: {
                Text("Update Email")
            })
            .sheet(isPresented: $showEmailSheet, content: {
                EmailResetScreen()
            })
            
            Button(action: {
                //update password
                self.showPasswordSheet.toggle()
            }, label: {
                Text("Update Password")
            })
            .sheet(isPresented: $showPasswordSheet, content: {
                PasswordResetScreen()
            })
            
            Button(action: {
                self.showUsernameSheet.toggle()
            }, label: {
                Text("Update Username")
            })
            .sheet(isPresented: $showUsernameSheet, content: {
                UsernameResetScreen()
            })
            
            Button(action: {
                
                let url = URL(string: String("mailto:".appending(supportEmail[0])).appending("?subject=LocaNotes:%20Bug%20Report"))
                print(url ?? "something happened with the url :(")
                UIApplication.shared.open(url!)
                
            }, label: {
                Text("Send A Support Request")
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            })
        }
        .navigationTitle("Settings")
    }
    
}

struct EmailResetScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var showAlert = false
    @State var alertBody = ""
    @State var alertTitle = ""
    
    @State var newEmail: String = ""
    @State var confirmEmail: String = ""
    
    var body: some View {
        VStack {
            TextField("New email", text: self.$newEmail)
                .padding()
                .autocapitalization(.none)
            
            TextField("Confirm email", text: self.$confirmEmail)
                .padding()
                .autocapitalization(.none)
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .padding(.trailing, 10)
                        Text("Cancel")
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1))
                .foregroundColor(.red)
                
                Button(action: {
                    resetEmail()
                }) {
                    Text("Reset")
                }
                .frame(minWidth: 0, maxWidth: 90, minHeight: 0, maxHeight: 20)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1))
                .foregroundColor(newEmail == confirmEmail && !newEmail.isEmpty ? Color.green : Color.gray)
                .disabled(newEmail == confirmEmail && !newEmail.isEmpty ? false : true)
            }
        }
        .alert(isPresented: $showAlert) { () -> Alert in
            let button = Alert.Button.default(Text("OK")) {
                presentationMode.wrappedValue.dismiss()
            }
            return Alert(title: Text(alertTitle), message: Text(alertBody), dismissButton: button)
        }
    }
    
    private func resetEmailCallback(response: MongoUserElement?, error: Error?) {
        print("line 156")
        if response == nil {
            alertTitle = "Error"
            if error == nil {
                alertBody = "Unknown Error"
                showAlert.toggle()
                return
            }
            alertBody = "\(error)"
            showAlert.toggle()
            return
        }
        print("line 167")
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        let userRepository = UserRepository()
        print("made user repo")
        do {
            print("updating email locally")
            print(userId)
            print(response!.email)
            try userRepository.updateEmailFor(userId: userId, email: response!.email)
            print("line 173")
        } catch let error {
            // bad error handling since by now it's updated in remote db
            print(error)
            alertBody = "Couldn't update email"
            alertTitle = "Error"
            showAlert.toggle()
        }
        
        alertBody = "Email successfully reset!"
        alertTitle = "Success"
        showAlert.toggle()
    }
    
    private func resetEmail() {
        let restService = RESTService()
        restService.resetEmail(email: self.newEmail, completion: resetEmailCallback(response:error:))
    }
}

struct PasswordResetScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var showAlert = false
    @State var alertBody = ""
    @State var alertTitle = ""
    
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    
    // necessary if the user is logged in, so that the rest service can get the user id
    var email: String
    
    // idea is that if there's a callback then some view is using an environment object, like a view router,
    // to show this view (e.g. forgot password)
    var callback: () -> Void
    
    init(email: String = "", callback: @escaping () -> Void = {
        // do nothing
    }) {
        self.email = email
        self.callback = callback
    }
    
    var body: some View {
        VStack {
            TextField("New password", text: self.$newPassword)
                .padding()
                .autocapitalization(.none)
            
            TextField("Confirm password", text: self.$confirmPassword)
                .padding()
                .autocapitalization(.none)
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    callback()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .padding(.trailing, 10)
                        Text("Cancel")
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1))
                .foregroundColor(.red)
                
                Button(action: {
                    resetPassword()
                }) {
                    Text("Reset")
                }
                .frame(minWidth: 0, maxWidth: 90, minHeight: 0, maxHeight: 20)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1))
                .foregroundColor(newPassword == confirmPassword && !newPassword.isEmpty ? Color.green : Color.gray)
                .disabled(newPassword == confirmPassword && !newPassword.isEmpty ? false : true)
            }
        }
        .alert(isPresented: $showAlert) { () -> Alert in
            let button = Alert.Button.default(Text("OK")) {
                presentationMode.wrappedValue.dismiss()
            }
            return Alert(title: Text(alertTitle), message: Text(alertBody), dismissButton: button)
        }
    }
    
    private func resetPasswordCallback(response: MongoUserElement?, error: Error?) {
        if response == nil {
            alertTitle = "Error"
            if error == nil {
                alertBody = "Unknown Error"
                showAlert.toggle()
                return
            }
            alertBody = "\(error)"
            showAlert.toggle()
            return
        }
        
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        let userRepository = UserRepository()
        do {
            try userRepository.updatePasswordFor(userId: userId, password: response!.password)
        } catch {
            // bad error handling since by now it's updated in remote db
            alertBody = "Couldn't update password"
            alertTitle = "Error"
            showAlert.toggle()
        }
        
        alertBody = "Password successfully reset!"
        alertTitle = "Success"
        showAlert.toggle()
    }
    
    private func resetPassword() {
        let restService = RESTService()
        restService.resetPassword(email: self.email, password: self.newPassword, completion: resetPasswordCallback(response:error:))
    }
}

struct UsernameResetScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var showAlert = false
    @State var alertBody = ""
    @State var alertTitle = ""
    
    @State var newUsername: String = ""
    @State var confirmUsername: String = ""
    
    var body: some View {
        VStack {
            TextField("New username", text: self.$newUsername)
                .padding()
                .autocapitalization(.none)
            
            TextField("Confirm username", text: self.$confirmUsername)
                .padding()
                .autocapitalization(.none)
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .padding(.trailing, 10)
                        Text("Cancel")
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1))
                .foregroundColor(.red)
                
                Button(action: {
                    resetUsername()
                }) {
                    Text("Reset")
                }
                .frame(minWidth: 0, maxWidth: 90, minHeight: 0, maxHeight: 20)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1))
                .foregroundColor(newUsername == confirmUsername && !newUsername.isEmpty ? Color.green : Color.gray)
                .disabled(newUsername == confirmUsername && !newUsername.isEmpty ? false : true)
            }
        }
        .alert(isPresented: $showAlert) { () -> Alert in
            let button = Alert.Button.default(Text("OK")) {
                presentationMode.wrappedValue.dismiss()
            }
            return Alert(title: Text(alertTitle), message: Text(alertBody), dismissButton: button)
        }
    }
    
    private func resetUsernameCallback(response: MongoUserElement?, error: Error?) {
        if response == nil {
            alertTitle = "Error"
            if error == nil {
                alertBody = "Unknown Error"
                showAlert.toggle()
                return
            }
            alertBody = "\(error)"
            showAlert.toggle()
            return
        }
        
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        let userRepository = UserRepository()
        do {
            try userRepository.updateUsernameFor(userId: userId, username: response!.username)
        } catch {
            // bad error handling since by now it's updated in remote db
            alertBody = "Couldn't update username"
            alertTitle = "Error"
            showAlert.toggle()
        }
        
        alertBody = "Username successfully reset!"
        alertTitle = "Success"
        showAlert.toggle()
    }
    
    private func resetUsername() {
        let restService = RESTService()
        restService.resetUsername(username: self.newUsername, completion: resetUsernameCallback(response:error:))
    }
}
