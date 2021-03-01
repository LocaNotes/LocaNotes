//
//  ContentView.swift
//  LocaNotes
//
//  Created by Elijah Monzon on 2/11/21.
//

import SwiftUI

struct ContentView: View {
    
//    @State var selectedIndex = 0
//    @State var shouldShowModel = false
//
//    let tabBarImageNames = ["person", "gear", "plus.app.fill", "pencil", "lasso"]
    
    let noteViewModel = NoteViewModel()
    
    var body: some View {
        TabView {
            PrivateNoteListView(viewModel: noteViewModel)
                .tabItem {
                    Image(systemName: "homekit")
                    Text("Home")
                }
            Text("Social")
                .font(.system(size: 30, weight: .bold))
                .tabItem {
                    Image(systemName: "globe")
                    Text("Social")
                }
            CreateNoteView(noteViewModel: noteViewModel)
                .tabItem {
                    Image(systemName: "pencil")
                    Text("New Note")
                }
            Text("Settings")
                .font(.system(size: 30, weight: .bold))
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            Text("Account")
                .font(.system(size: 30, weight: .bold))
                .tabItem {
                    Image(systemName: "person")
                    Text("Account")
                }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


