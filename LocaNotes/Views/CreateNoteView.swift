//
//  CreateNoteView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/28/21.
//

import SwiftUI

struct CreateNoteView: View {
        
    var noteViewModel: NoteViewModel
    
    @Binding var selectedTab: Int
    
    // used in the toggle to show the user's preference between public or private
    @State private var selectedPrivacy = ""
    
    // for the privacy drawer
    @State var showDrawer = false;
    
    // what the user types in the text editor
    @State private var noteContent = ""
    
//    init (noteViewModel: NoteViewModel, selectedTab: Int) {
//        self.noteViewModel = noteViewModel
//        self.selectedTab = selectedTab
//    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("New Note")
                        .font(.title)
                    Spacer()
                    Button(action: {
                        insertNote()
                        selectedTab = 0
                        noteContent = ""
                        selectedPrivacy = ""
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .disabled(self.noteContent == "" ? true : false)
                    Button(action: {
                        self.showDrawer.toggle()
                    }) {
                        Image(systemName: "link")
                    }
                }
                .padding()
                TextEditor(text: $noteContent)
                    .frame(maxHeight: .infinity)
                    .background(Color(UIColor.label.withAlphaComponent(self.showDrawer ? 0.2 : 0)).edgesIgnoringSafeArea(.all))
            }
            VStack {
                Spacer()
                RadioButtonsSheet(selectedPrivacy: self.$selectedPrivacy, show: self.$showDrawer)
                    .offset(y: self.showDrawer ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 15 : UIScreen.main.bounds.height)
            }
            .background(Color(UIColor.label.withAlphaComponent(self.showDrawer ? 0.2 : 0)).edgesIgnoringSafeArea(.all))
            .onTapGesture {
                self.showDrawer.toggle()
            }
        }
        .animation(.default)
    }
    
    // is it worth using the NotificationCenter instead of invoking the call?
    private func insertNote() {
        noteViewModel.insertNote(body: noteContent)
    }
}

enum Privacy: String {
    case publicNote = "Public"
    case privateNote = "Private"
}

struct RadioButtonsSheet: View {
    @Binding var selectedPrivacy: String
    @Binding var show: Bool
    
    let data = [Privacy.publicNote.rawValue, Privacy.privateNote.rawValue]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Privacy")
                .font(.title)
            ForEach(data, id: \.self) {value in
                Button(action: {
                    self.selectedPrivacy = value
                    self.show.toggle()
                }) {
                    HStack {
                        Text(value)
                        Spacer()
                        Image(systemName: self.selectedPrivacy == value ? "largecircle.fill.circle" : "circle")
                    }
                    .foregroundColor(.black)
                }
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 25)
        .padding(.bottom, (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 10)
        .background(Color.white)
        .cornerRadius(30)
    }
}

//struct CreateNoteView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateNoteView(noteViewModel: NoteViewModel(), selectedTab: 0)
//    }
//}
