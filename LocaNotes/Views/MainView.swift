//
//  MainView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/16/21.
//

import SwiftUI

struct MainView: View {
    
    //    @State var selectedIndex = 0
    //    @State var shouldShowModel = false
    //
    //    let tabBarImageNames = ["person", "gear", "plus.app.fill", "pencil", "lasso"]
        
    let noteViewModel = NoteViewModel()
    let userViewModel = UserViewModel()
    
    @EnvironmentObject var viewRouter: ViewRouter
        
    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NoteView(viewModel: noteViewModel, privacyLabel: PrivacyLabel.privateNote)
                .tabItem {
                    Image(systemName: "homekit")
                    Text("Home")
                }
                .tag(0)
            NoteView(viewModel: noteViewModel, privacyLabel: PrivacyLabel.publicNote)
                .tabItem {
                    Image(systemName: "globe")
                    Text("Social")
                }
                .tag(1)
            CreateNoteView(noteViewModel: noteViewModel, selectedTab: self.$selectedTab)
                .tabItem {
                    Image(systemName: "pencil")
                    Text("New Note")
                }
                .tag(3)
            SettingsView(viewModel: userViewModel)
                .font(.system(size: 30, weight: .bold))
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
            AccountView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Account")
                }
                .tag(5)
        }
        
//        VStack(spacing: 0) {
//
//            ZStack {
//
//                Spacer()
//                    .fullScreenCover(isPresented: $shouldShowModel, content: {
//                        Button(action: {shouldShowModel.toggle()}, label: {
//                            Text("Fullscreen cover")
//                        })
//                    })
//
//                switch selectedIndex {
//                case 0:
//                    PrivateNoteListView()
//                case 1:
//                    ScrollView {
//                        Text("test")
//                    }
//                default:
//                    // need navigation view so that the text is flush against the bottom
//                    NavigationView {
//                        Text("remaining tabs")
//                    }
//                }
//            }
//
//            Divider()
//                .padding(.bottom, 12)
//
//            HStack {
//                ForEach(0..<5) { num in
//                    Button(action: {
//
//                        if num == 2 {
//                            shouldShowModel.toggle()
//                            return
//                        }
//
//                        selectedIndex = num
//                    }, label: {
//                        Spacer()
//
//                        if num == 2 {
//                            Image(systemName: tabBarImageNames[num])
//                                .font(.system(size: 44, weight: .bold))
//                                .foregroundColor(.red)
//                        } else {
//                            Image(systemName: tabBarImageNames[num])
//                                .font(.system(size: 24, weight: .bold))
//                                .foregroundColor(selectedIndex == num ? Color(.label) : Color(white: 0.8))
//                        }
//                        Spacer()
//                    })
//                }
//            }
//        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(ViewRouter())
    }
}
