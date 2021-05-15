//
//  endEditing.swift
//  LocaNotes
//
//  Created by Anthony C on 3/6/21.
//
// source: https://stackoverflow.com/questions/56491386/how-to-hide-keyboard-when-using-swiftui

import Foundation

import SwiftUI

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}
