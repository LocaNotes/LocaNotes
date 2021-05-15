//
//  substring.swift
//  LocaNotes
//
//  Created by Anthony C on 4/21/21.
//

// Source: https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift

import Foundation

extension String {
    /**
     Returns a substring up to the specified index of the specified string
     - Parameters:
        - startIndex: the starting index of the substring
        - offset: the ending index of the substring
     */
    public func substring(start: Int = 0, offset: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(startIndex, offsetBy: offset - start)
        let substring = self[startIndex..<endIndex]
        return String(substring)
    }
}
