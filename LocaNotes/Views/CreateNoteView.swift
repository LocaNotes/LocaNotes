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
    
    @State private var selectedTag = noteTagLabel.other.rawValue
    
    // used in the toggle to show the user's preference between public or private
    @State private var selectedPrivacy = PrivacyLabel.privateNote.rawValue
    
    // for the privacy drawer
    @State private var showPrivacyDrawer = false
    
    // for the note tags drawer
    @State private var showNoteTagDrawer = false
    
    // what the user types in the text editor
    @State private var noteContent = ""
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        UIApplication.shared.endEditing(true)
                    }) {
                        Text("New Note")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Button(action: {
                        insertNote()
                    }) {
                        Image(systemName: "checkmark")
                            .padding(.trailing, 10)
                    }
                    .disabled(self.noteContent == "" ? true : false)
                    Button(action: {
                        UIApplication.shared.endEditing(true)
                        self.showPrivacyDrawer.toggle()
                    }) {
                        Image(systemName: "link")
                    }
                    Button(action: {
                        UIApplication.shared.endEditing(true)
                        self.showNoteTagDrawer.toggle()
                    }) {
                        Image(systemName: "tray.circle")
                    }
                }
                
                TextEditor(text: $noteContent)
                    .frame(maxHeight: .infinity)
                    .background(Color(UIColor.label.withAlphaComponent(self.showPrivacyDrawer ? 0.2 : 0)).edgesIgnoringSafeArea(.all))
                    .disabled(self.showPrivacyDrawer ? true : false)
            }
            
            VStack {
                RadioButtonsSheet(selectedPrivacy: self.$selectedPrivacy, show: self.$showPrivacyDrawer)
                    .offset(y: self.showPrivacyDrawer ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 15 : UIScreen.main.bounds.height)
            }
            
            VStack {
                NoteTagRadioButtonsSheet(selectedTag: self.$selectedTag, show: self.$showNoteTagDrawer)
                    .offset(y: self.showNoteTagDrawer ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 15 : UIScreen.main.bounds.height)
            }
        }
        .padding()
        .animation(.default)
    }
    
    // is it worth using the NotificationCenter instead of invoking the call?
    private func insertNote() {
        var noteTagId: Int32
        switch selectedTag {
        case noteTagLabel.emergency.rawValue:
            noteTagId = 4
        case noteTagLabel.dining.rawValue:
            noteTagId = 3
        case noteTagLabel.meme.rawValue:
            noteTagId = 2
        default:
            noteTagId = 1
        }
        
        var privacyId: Int32
        switch selectedPrivacy {
        case PrivacyLabel.privateNote.rawValue:
            privacyId = 1
        default:
            privacyId = 2
        }
        
        noteViewModel.insertNewNote(body: noteContent, noteTagId: noteTagId, privacyId: privacyId, UICompletion: completion)
    }
    
    private func completion() {
        // reset
        DispatchQueue.main.async {
            selectedTab = 0
            noteContent = ""
            selectedPrivacy = PrivacyLabel.privateNote.rawValue
            UIApplication.shared.endEditing(true)
        }
    }
}

enum noteTagLabel: String {
    case emergency = "Emergency"
    case dining = "Dining"
    case meme = "Meme"
    case other = "Other"
}

enum PrivacyLabel: String {
    case publicNote = "Public"
    case privateNote = "Private"
}

struct RadioButtonsSheet: View {
    @Binding var selectedPrivacy: String
    @Binding var show: Bool
    
    private let data = [PrivacyLabel.publicNote.rawValue, PrivacyLabel.privateNote.rawValue]
    
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
                    
                }
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 25)
        .padding(.bottom, (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 10)
        .background(Color(UIColor.label))
        .foregroundColor(Color(UIColor.systemBackground))
        .cornerRadius(30)
    }
}

struct NoteTagRadioButtonsSheet: View {
    @Binding var selectedTag: String
    @Binding var show: Bool
    
    private let data = [noteTagLabel.emergency.rawValue, noteTagLabel.dining.rawValue, noteTagLabel.meme.rawValue, noteTagLabel.other.rawValue]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tags")
                .font(.title)
            ForEach(data, id: \.self) {value in
                Button(action: {
                    self.selectedTag = value
                    self.show.toggle()
                }) {
                    HStack {
                        Text(value)
                        Spacer()
                        Image(systemName: self.selectedTag == value ? "largecircle.fill.circle" : "circle")
                    }
                    
                }
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 25)
        .padding(.bottom, (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 10)
        .background(Color(UIColor.label))
        .foregroundColor(Color(UIColor.systemBackground))
        .cornerRadius(30)
    }
}

//struct CreateNoteView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateNoteView(noteViewModel: NoteViewModel(), selectedTab: 0)
//    }
//}
