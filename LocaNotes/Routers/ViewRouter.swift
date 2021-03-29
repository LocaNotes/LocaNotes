//
//  ViewRouter.swift
//  LocaNotes
//
//  Created by Anthony C on 3/16/21.
//

import SwiftUI

class ViewRouter: ObservableObject {
    
    @Published var currentPage: Page = .loginPage
}

enum Page {
    case loginPage
    case mainPage
}
