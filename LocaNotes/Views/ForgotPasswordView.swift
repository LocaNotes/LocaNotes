//
//  ForgotPasswordView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/29/21.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @EnvironmentObject var viewRouter: ForgotPasswordViewRouter
    
    @State private var email = ""
    
    @State private var selection: String? = "enter email"
    
    var body: some View {
        switch viewRouter.currentPage {
        case .enterEmail:
            ForgotPasswordEnterEmailView(email: self.$email)
                .transition(.slide)
        case .enterTemporaryPassword:
            ForgotPasswordEnterTemporaryPasswordView(email: self.$email)
                .transition(.slide)
        case .resetPassword:
            ForgotPasswordResetPasswordView(email: self.$email, callback: {
                viewRouter.currentPage = .enterEmail
            })
                .transition(.slide)
        }
    }
}

struct ForgotPasswordEnterEmailView: View {
    
    @Environment(\.presentationMode) var presentationMode
                
    @Binding var email: String
        
    @State private var showAlert = false
    
    @EnvironmentObject var viewRouter: ForgotPasswordViewRouter
    
    var body: some View {
        
        VStack {
            Text("First, enter your email and we'll send you a temporary password.")
            
            Divider()
            
            TextField("Email", text: self.$email)
                .autocapitalization(.none)
            
            Divider()
            
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
                    forgotPasswordSendEmail()
                }) {
                    Text("Submit")
                }
                .frame(minWidth: 0, maxWidth: 90, minHeight: 0, maxHeight: 20)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1))
                .foregroundColor(.green)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text("Unable to reset password right now"), dismissButton: .cancel())
        }
    }
    
    private func forgotPasswordCallback(response: MongoUserElement?, error: Error?) {
        print("forgot password callbakc")
        if response == nil {
            if error == nil {
                return
            }
            showAlert.toggle()
            return
        }
        
        DispatchQueue.main.async {
            withAnimation {
                viewRouter.currentPage = .enterTemporaryPassword
            }
        }
    }
    
    private func forgotPasswordSendEmail() {
        let userRepository = UserRepository()
        userRepository.forgotPasswordSendEmail(email: self.email, completion: forgotPasswordCallback(response:error:))
    }
}

struct ForgotPasswordEnterTemporaryPasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var temporaryPassword = ""
    
    @State private var showAlert = false
    
    @Binding var email: String
            
    @EnvironmentObject var viewRouter: ForgotPasswordViewRouter
    
    var body: some View {
        VStack {
            Text("We sent a temporary password to your email. Enter it here:")
                .padding(.bottom, 40)
            
            TextField("Temporary password", text: $temporaryPassword)
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    viewRouter.currentPage = .enterEmail
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
                    submitTemporaryPassword()
                }) {
                    Text("Submit")
                }
                .frame(minWidth: 0, maxWidth: 90, minHeight: 0, maxHeight: 20)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 1))
                .foregroundColor(.green)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text("Unable to reset password right now"), dismissButton: .cancel())
        }
    }
    
    private func submitTemporaryPasswordCallback(response: MongoUserElement?, error: Error?) {
        if response == nil {
            if error == nil {
                return
            }
            showAlert.toggle()
            return
        }
        
        print("switch to reset password")
        DispatchQueue.main.async {
            withAnimation {
                viewRouter.currentPage = .resetPassword
            }
        }
    }
    
    private func submitTemporaryPassword() {
        let userRepository = UserRepository()
        userRepository.forgotPasswordSendTemporaryPassword(email: self.email, temporaryPassword: self.temporaryPassword, completion: submitTemporaryPasswordCallback(response:error:))
    }
}

struct ForgotPasswordResetPasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var newPassword = ""
    
    @State private var confirmNewPassword = ""
    
    @Binding private var email: String
    
    private var callback: () -> Void
    
    init(email: Binding<String>, callback: @escaping () -> Void) {
        _email = email
        self.callback = callback
    }
    
    var body: some View {
        PasswordResetScreen(email: self.email, callback: callback)
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
