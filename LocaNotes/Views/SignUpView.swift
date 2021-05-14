//
//  SignUpView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/29/21.
//

import SwiftUI

struct SignUp: View {
    
    @EnvironmentObject private var viewRouter: ViewRouter
    
    private let textFieldInputValidationService = TextFieldInputValidationService()

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var mail = ""
    @State private var username = ""
    @State private var pass = ""
    @State private var repass = ""
    
    @State private var firstNameIsValid = true
    @State private var lastNameIsValid = true
    @State private var emailIsValid = true
    @State private var usernameIsValid = true
    @State private var passwordIsValid = true
    
    @State private var passwordError = ""
    
    @State private var didReceiveRestError = false
    @State private var restResponse = ""
    
    @Binding var index: Int
        
    private struct FirstName: View {
        
        @Binding var firstName: String
        @Binding var isValid: Bool
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "person")
                        .foregroundColor(.black)
                    TextField("First name", text: self.$firstName)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 20)
                Text("First Name has to be at least one character")
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .opacity(isValid ? 0 : 1)
            }
            Divider()
        }
    }
    
    private struct LastName: View {
        
        @Binding var lastName: String
        @Binding var isValid: Bool
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "person.3")
                        .foregroundColor(.black)
                    TextField("Last name", text: self.$lastName)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 20)
                Text("Last Name has to be at least one character")
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .opacity(isValid ? 0 : 1)
            }
            Divider()
        }
    }
    
    private struct Email: View {
        
        @Binding var email: String
        @Binding var isValid: Bool
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    TextField("Email", text: self.$email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 20)
                Text("Invalid Email")
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .opacity(isValid ? 0 : 1)
            }
            Divider()
        }
    }
    
    private struct Username: View {
        
        @Binding var username: String
        @Binding var isValid: Bool
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.black)
                    TextField("Username", text: self.$username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 20)
                Text("Username has to be at least one character")
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .opacity(isValid ? 0 : 1)
            }
            Divider()
        }
    }
    
    private struct Password: View {
        
        @Binding var password: String
        @Binding var isValid: Bool
        @Binding var error: String
        
        var hint: String
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "lock")
                        .foregroundColor(.black)
                    
                    SecureField(hint, text: self.$password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                }
                .padding(.vertical, 20)
                
                Text(error)
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .opacity(isValid ? 0 : 1)
            }
            Divider()
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                FirstName(firstName: self.$firstName, isValid: self.$firstNameIsValid)
                                
                LastName(lastName: self.$lastName, isValid: self.$lastNameIsValid)
                                
                Email(email: self.$mail, isValid: self.$emailIsValid)
                                
                Username(username: self.$username, isValid: self.$usernameIsValid)
                                
                Password(password: self.$pass, isValid: self.$passwordIsValid, error: self.$passwordError, hint: "Password")
                                                
                Password(password: self.$repass, isValid: self.$passwordIsValid, error: self.$passwordError, hint: "Re-enter Password")
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top, 25)
            
            Button(action: {
                createUser()
            }) {
                Text("SIGN UP")
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
            Alert(title: Text("Sign up error"), message: Text(restResponse), dismissButton: .cancel())
        }
    }
    
    private func createUserCallback(response: MongoUserElement?, error: Error?) {
        
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
        guard let user = userViewModel.createUserByMongoUser(mongoUser: response!) else {
            restResponse = "Try logging in"
            didReceiveRestError.toggle()
            return
        }
        
        UserDefaults.standard.set(user.username, forKey: "username")
        UserDefaults.standard.set(user.userId, forKey: "userId")
        UserDefaults.standard.set(user.serverId, forKey: "serverId")
        DispatchQueue.main.async {
            withAnimation {
//                viewRouter.currentPage = .loginPage
                self.index = 0
            }
        }
    }
    
    private func passwordsDoMatch() -> Bool {
        if self.pass != self.repass {
            passwordError = "Passwords don't match"
            passwordIsValid = false
            return false
        }
        return true
    }
    
    private func validateInputs() -> Bool {
        firstNameIsValid = textFieldInputValidationService.validateFirstName(firstName: self.firstName)
        lastNameIsValid = textFieldInputValidationService.validateLastName(lastName: self.lastName)
        emailIsValid = textFieldInputValidationService.validateEmail(email: self.mail)
        usernameIsValid = textFieldInputValidationService.validateUsername(username: self.username)
        passwordIsValid = textFieldInputValidationService.validatePassword(password: self.pass)
        
        if !passwordIsValid {
            passwordError = "Password has to be at least one character"
        }
        
        let doPasswordsMatch = passwordsDoMatch()
        return firstNameIsValid && lastNameIsValid && emailIsValid && usernameIsValid && passwordIsValid && doPasswordsMatch
    }
    
    private func createUser() {
        if validateInputs() {
            let restService = RESTService()
            restService.createUser(firstName: firstName, lastName: lastName, email: mail, username: username, password: pass, completion: createUserCallback(response:error:))
        }
    }
}
