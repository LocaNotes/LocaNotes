//
//  TextFieldInputValidationService.swift
//  LocaNotes
//
//  Created by Anthony C on 3/16/21.
//

import Foundation

class TextFieldInputValidationService {
    
    public func validateFirstName(firstName: String) -> Bool {
        return firstName.utf16.count > 0
    }
    
    public func validateLastName(lastName: String) -> Bool {
        return lastName.utf16.count > 0
    }
    
    public func validateEmail(email: String) -> Bool {
        let range = NSRange(location: 0, length: email.utf16.count)
        let pattern = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        let regex = try! NSRegularExpression(pattern: pattern)
        return regex.firstMatch(in: email, options: [], range: range) != nil
    }
    
    public func validateUsername(username: String) -> Bool {
        return username.utf16.count > 0
    }
    
    public func validatePassword(password: String) -> Bool {
        return password.utf16.count > 0
    }
}
