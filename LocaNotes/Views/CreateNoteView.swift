//
//  CreateNoteView.swift
//  LocaNotes
//
//  Created by Anthony C on 2/28/21.
//

import SwiftUI

struct CreateNoteView: View {
        
    @EnvironmentObject var noteViewModel: NoteViewModel
    
    @Binding var selectedTab: Int
    
    @State private var selectedTag = noteTagLabel.other.rawValue
    
    // used in the toggle to show the user's preference between public or private
    @State private var selectedPrivacy = PrivacyLabel.privateNote.rawValue
    
    @State private var selectedStoryOption = StoryOptions.isRegular.rawValue
    
    // for the privacy drawer
    @State private var showPrivacyDrawer = false
    
    // for the note tags drawer
    @State private var showNoteTagDrawer = false
    
    // for picking whether or note a story
    @State private var showStoryDrawer = false
    
    // what the user types in the text editor
    @State private var noteContent = ""
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastTitle: String = ""
    private let createNoteSuccess: String
    private let createNoteError: String
    @State private var toastCompletion: () -> Void = {}
    
    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
        
        createNoteSuccess = "Successfully created note."
        createNoteError = "Could not create note."
    }
    
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
                        self.showNoteTagDrawer = false
                        self.showStoryDrawer = false
                        self.showPrivacyDrawer.toggle()
                    }) {
                        Image(systemName: "lock")
                    }
                    Button(action: {
                        UIApplication.shared.endEditing(true)
                        self.showPrivacyDrawer = false
                        self.showStoryDrawer = false
                        self.showNoteTagDrawer.toggle()
                    }) {
                        Image(systemName: "tag")
                    }
                    Button(action: {
                        UIApplication.shared.endEditing(true)
                        self.showPrivacyDrawer = false
                        self.showNoteTagDrawer = false
                        self.showStoryDrawer.toggle()
                    }) {
                        Image(systemName: "book")
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
            
            VStack {
                StoryRadioButtonsSheet(selectedOption: self.$selectedStoryOption, show: self.$showStoryDrawer)
                    .offset(y: self.showStoryDrawer ? (UIApplication.shared.windows.last?.safeAreaInsets.bottom)! + 15 : UIScreen.main.bounds.height)
            }
        }
        .padding()
        .alert(isPresented: $showToast) {
            makeToast(title: toastTitle, message: toastMessage, completion: toastCompletion)
        }
        .animation(.default)
    }
    
    private func makeToast(title: String, message: String, completion: @escaping () -> Void) -> Alert {
        return Alert(title: Text(title), message: Text(message), dismissButton: .destructive(Text("OK")) {
            completion()
        })
    }
    
    private func showErrorToast(error: String) {
        self.toastCompletion = {
            // do nothing
        }
        toastTitle = "Error"
        toastMessage = error
        showToast = true
    }
    
    private func showSuccessToast(message: String) {
        self.toastCompletion = {
            // reset
            DispatchQueue.main.async {
                selectedTab = 0
                noteContent = ""
                selectedPrivacy = PrivacyLabel.privateNote.rawValue
                UIApplication.shared.endEditing(true)
            }
        }
        toastTitle = "Success"
        toastMessage = message
        showToast = true
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
        
        var isStory: Int
        switch selectedStoryOption {
        case StoryOptions.isStory.rawValue:
            isStory = 1
        default:
            isStory = 0
        }
        
        noteViewModel.insertNewNote(body: noteContent, noteTagId: noteTagId, privacyId: privacyId, isStory: isStory, UICompletion: createCompletion)
    }
    
    private func createCompletion() {
        showSuccessToast(message: createNoteSuccess)
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

enum StoryOptions: String {
    case isStory = "Story"
    case isRegular = "Regular Note"
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

struct StoryRadioButtonsSheet: View {
    @Binding var selectedOption: String
    @Binding var show: Bool
    
    private let data = [StoryOptions.isRegular.rawValue, StoryOptions.isStory.rawValue]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Create Story?")
                .font(.title)
            ForEach(data, id: \.self) {value in
                Button(action: {
                    self.selectedOption = value
                    self.show.toggle()
                }) {
                    HStack {
                        Text(value)
                        Spacer()
                        Image(systemName: self.selectedOption == value ? "largecircle.fill.circle" : "circle")
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
