//
//  ContentView.swift
//  LocaNotes
//
//  Created by Elijah Monzon on 2/11/21.
//

import SwiftUI

struct ContentView: View {
        
    @EnvironmentObject private var viewRouter: ViewRouter
        
    var body: some View {
        switch viewRouter.currentPage {
        case .loginPage:
            LoginView()
                .transition(.scale)
        case .mainPage:
            MainView()
                .transition(.scale)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewRouter())
    }
}


