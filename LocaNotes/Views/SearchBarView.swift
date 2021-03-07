//
//  SearchBarView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/6/21.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    @State private var isEditing: Bool = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("search", text: $searchText, onEditingChanged: { isEditing in
                    self.isEditing = true
                })
                
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

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
    }
}
