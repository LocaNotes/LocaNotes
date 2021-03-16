//
//  LoginView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/15/21.
//

import SwiftUI

struct LoginView: View {
    
    @AppStorage("status") var logged = false
    
    var body: some View {
        NavigationView {
            if logged {
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
            } else {
                MainView()
                    .navigationBarHidden(true)
            }
        }
    }
}

struct Home: View {
    @State var index = 0
    
    @AppStorage("stored_User") var user = ""
    @AppStorage("status") var logged = false
    
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
            
            HStack(spacing: 15) {
                Color.white.opacity(0.7)
                    .frame(width: 35, height: 1)
                Text("or")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Color.white.opacity(0.7)
                    .frame(width: 35, height: 1)
                
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

struct Login: View {
    @State var mail = ""
    @State var pass = ""
    @AppStorage("stored_User") var user = ""
    @AppStorage("status") var logged = false
    
    @State var didReceiveRestError = false
    @State var restResponse = ""
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    TextField("Enter email address", text: self.$mail)
                }
                .padding(.vertical, 20)
                
                Divider()
                
                HStack(spacing: 15 ) {
                    Image(systemName: "lock")
                        .resizable()
                        .frame(width: 15, height: 18)
                        .foregroundColor(.black)
                    
                    SecureField("Enter password", text: self.$pass)
                    
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
    
    private func authenticateCallback(user: MongoUser?, error: Error?) {
        if error != nil {
            restResponse = "\(error!)"
            didReceiveRestError.toggle()
        } else {
            logged.toggle()
        }
    }
    
    private func authenticateUser() {
        if user == "" {
            user = self.mail
        }
        
        let restService = RESTService()
        restService.authenticateUser(username: self.mail, password: self.pass, completion: authenticateCallback(user:error:))
        
    }
}

struct SignUp: View {
    @State var mail = ""
    @State var pass = ""
    @State var repass = ""
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "envelope")
                        .foregroundColor(.black)
                    TextField("Enter email address", text: self.$mail)
                }
                .padding(.vertical, 20)
                
                Divider()
                
                HStack(spacing: 15 ) {
                    Image(systemName: "lock")
                        .resizable()
                        .frame(width: 15, height: 18)
                        .foregroundColor(.black)
                    
                    SecureField("Enter password", text: self.$pass)
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "eye")
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 20)
                
                Divider()
                
                HStack(spacing: 15 ) {
                    Image(systemName: "lock")
                        .resizable()
                        .frame(width: 15, height: 18)
                        .foregroundColor(.black)
                    
                    SecureField("Re-Enter password", text: self.$repass)
                    
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
    }
}

