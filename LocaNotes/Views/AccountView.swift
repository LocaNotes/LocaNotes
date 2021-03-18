//
//  AccountView.swift
//  LocaNotes
//
//  Created by Anthony C on 3/17/21.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            Text("Account")
                .font(.system(size: 30, weight: .bold))
            Button(action: {
                viewRouter.currentPage = .loginPage
            }) {
                Text("Log out")
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
