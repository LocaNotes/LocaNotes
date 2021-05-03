//
//  SearchBarView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/6/21.
//

import SwiftUI

struct SearchBarView: View {
    
    // what the user types in the search bar
    @Binding var searchText: String
    
    // optional callback to be performed when the user types
    private let onCommitCallback: () -> Void
    
    // should be false when the user isn't typing in the search bar and true when they are
    @State private var isEditing: Bool = false
    
    init(searchText: Binding<String>, onCommitCallback: @escaping () -> Void = {}) {
        self._searchText = searchText
        self.onCommitCallback = onCommitCallback
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("search", text: $searchText, onEditingChanged: { isEditing in
                    self.isEditing = true
                }, onCommit: onCommitCallback)
                .autocapitalization(.none)
                
                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .opacity(self.searchText == "" ? 0 : 1)
                }
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            
            if self.isEditing {
                Button("Cancel") {
                    UIApplication.shared.endEditing(true)
                    self.searchText = ""
                    self.isEditing = false
                }
            }
        }
        .padding([.leading, .trailing, .top])
    }
}

//struct SearchBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBarView(searchText: .constant(""))
//    }
//}
