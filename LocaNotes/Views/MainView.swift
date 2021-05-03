//
//  MainView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/16/21.
//

import SwiftUI

struct MainView: View {
        
    private let noteViewModel = NoteViewModel()
    private let userViewModel = UserViewModel()
    
    @EnvironmentObject private var viewRouter: ViewRouter
        
    @State private var selectedTab = 0
    
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
            SettingsView()
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(ViewRouter())
    }
}
