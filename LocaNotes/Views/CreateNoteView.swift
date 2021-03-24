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
    @State private var selectedPrivacy = PrivacyLabel.privateNote.rawValue
    
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
                        
                        // reset
                        selectedTab = 0
                        noteContent = ""
                        selectedPrivacy = PrivacyLabel.privateNote.rawValue
                        UIApplication.shared.endEditing(true)
                    }) {
                        Image(systemName: "checkmark")
                            .padding(.trailing, 10)
                    }
                    .disabled(self.noteContent == "" ? true : false)
                    Button(action: {
                        UIApplication.shared.endEditing(true)
                        self.showDrawer.toggle()
                    }) {
                        Image(systemName: "link")
                    }
                }
                
                TextEditor(text: $noteContent)
                    .frame(maxHeight: .infinity)
                    .background(Color(UIColor.label.withAlphaComponent(self.showDrawer ? 0.2 : 0)).edgesIgnoringSafeArea(.all))
                    .disabled(self.showDrawer ? true : false)
            }
            
            VStack {
                RadioButtonsSheet(selectedPrivacy: self.$selectedPrivacy, show: self.$showDrawer)
                    .offset(y: self.showDrawer ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 15 : UIScreen.main.bounds.height)
            }
        }
        .padding()
        .animation(.default)
    }
    
    // is it worth using the NotificationCenter instead of invoking the call?
    private func insertNote() {
        noteViewModel.insertNote(body: noteContent)
    }
}

enum PrivacyLabel: String {
    case publicNote = "Public"
    case privateNote = "Private"
}

struct RadioButtonsSheet: View {
    @Binding var selectedPrivacy: String
    @Binding var show: Bool
    
    let data = [PrivacyLabel.publicNote.rawValue, PrivacyLabel.privateNote.rawValue]
    
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

//struct CreateNoteView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateNoteView(noteViewModel: NoteViewModel(), selectedTab: 0)
//    }
//}
