//
//  ForgotPasswordViewRouter.swift
//  LocaNotes
//
//  Created by Anthony C on 3/29/21.
//

import Foundation

class ForgotPasswordViewRouter: ObservableObject {
    
    @Published var currentPage: ForgotPasswordPage = .enterEmail
}

enum ForgotPasswordPage {
    case enterEmail
    case enterTemporaryPassword
    case resetPassword
}
