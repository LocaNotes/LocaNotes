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
                SignUp()
            }
            
            if self.index == 0 {
                Button(action: {
                    
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
            }
        }
        .padding()
    }
}

struct Login: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
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
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "eye")
                            .foregroundColor(.black)
                    }
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
    
    private func authenticateCallback(response: MongoUser?, error: Error?) {
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
    
        
        
//        if !userViewModel.mongoUserDoesExistInSqliteDatabase(mongoUserElement: user[0]) {
//            userViewModel.createUserByMongoUser(mongoUser: user[0])
//        }
        let keychainService = KeychainService()
        do {
            guard let username = user?.username, let password = user?.password, let userId = user?.userId else {
                return
            }
            try keychainService.storeGenericPasswordFor(account: username as String, service: "storePassword", password: password as String)
            UserDefaults.standard.set(username, forKey: "username")
            UserDefaults.standard.set(userId, forKey: "userId")
            DispatchQueue.main.async {
                withAnimation {
                    viewRouter.currentPage = .mainPage
                }
            }
//            do {
//                if let u = UserDefaults.standard.string(forKey: "username") {
//                    let s = try keychainService.getGenericPasswordFor(account: u, service: "storePassword")
//                    print("\(u) and \(s)")
//                }
//            } catch {
//                print("fail")
//            }
        } catch {
            restResponse = "\(error)"
            didReceiveRestError.toggle()
        }
    }
    
    private func authenticateUser() {
        
        let restService = RESTService()
        restService.authenticateUser(username: self.username, password: self.pass, completion: authenticateCallback(response:error:))
        
    }
}

struct SignUp: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    let textFieldInputValidationService = TextFieldInputValidationService()

    @State var firstName = ""
    @State var lastName = ""
    @State var mail = ""
    @State var username = ""
    @State var pass = ""
    @State var repass = ""
    
    @State var firstNameIsValid = true
    @State var lastNameIsValid = true
    @State var emailIsValid = true
    @State var usernameIsValid = true
    @State var passwordIsValid = true
    
    @State var passwordError = ""
    
    @State var didReceiveRestError = false
    @State var restResponse = ""
        
    struct FirstName: View {
        
        @Binding var firstName: String
        @Binding var isValid: Bool
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "person")
                        .foregroundColor(.black)
                    TextField("First name", text: self.$firstName)
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
    
    struct LastName: View {
        
        @Binding var lastName: String
        @Binding var isValid: Bool
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "person.3")
                        .foregroundColor(.black)
                    TextField("Last name", text: self.$lastName)
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
    
    struct Email: View {
        
        @Binding var email: String
        @Binding var isValid: Bool
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    TextField("Email", text: self.$email)
                        .autocapitalization(.none)
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
    
    struct Username: View {
        
        @Binding var username: String
        @Binding var isValid: Bool
        
        var body: some View {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.black)
                    TextField("Username", text: self.$username)
                        .autocapitalization(.none)
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
    
    struct Password: View {
        
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
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "eye")
                            .foregroundColor(.black)
                    }
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
        let keychainService = KeychainService()
        do {
            try keychainService.storeGenericPasswordFor(account: user.username as String, service: "storePassword", password: user.password as String)
            UserDefaults.standard.set(user.username, forKey: "username")
            UserDefaults.standard.set(user.userId, forKey: "userId")
            DispatchQueue.main.async {
                withAnimation {
                    viewRouter.currentPage = .mainPage
                }
            }
        } catch {
            restResponse = "\(error)"
            didReceiveRestError.toggle()
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

