//
//  endEditing.swift
//  LocaNotes
//
//  Created by Anthony C on 3/6/21.
//

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
