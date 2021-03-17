//
//  LocaNotesApp.swift
//  LocaNotes
//
//  Created by Elijah Monzon on 2/11/21.
//

import SwiftUI

@main
struct LocaNotesApp: App {
    
    @StateObject var viewRouter = ViewRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewRouter)
        }
    }
}
