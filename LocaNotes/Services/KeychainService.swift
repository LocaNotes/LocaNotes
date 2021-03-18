//
//  KeychainService.swift
//  LocaNotes
//
//  Created by Anthony C on 3/17/21.
//

import Foundation

enum KeychainServiceErrorType {
  case badData
  case servicesError
  case itemNotFound
  case unableToConvertToString
}

protocol KeychainServiceErrorProtocol: Error {
    var title: String? { get }
    var code: KeychainServiceErrorType { get }
}

struct KeychainServiceError: KeychainServiceErrorProtocol {
    var title: String?
    var code: KeychainServiceErrorType
    
    var description: String? { return _description }
    private var _description: String
    
    init (title: String?, code: KeychainServiceErrorType, description: String?) {
        self.title = title ?? "Error"
        self.code = code
        self._description = description ?? "Unknown error"
    }
    
    init (code: KeychainServiceErrorType) {
        self.code = code
        self._description = "Unknown error"
    }
    
    init (status: OSStatus, code: KeychainServiceErrorType) {
        self.code = code
        if let errorMessage = SecCopyErrorMessageString(status, nil) {
            self._description = String(errorMessage)
        } else {
            self._description = "Status code: \(status)"
        }
    }
}

class KeychainService {
    func storeGenericPasswordFor(account: String, service: String, password: String) throws {
        if password.isEmpty {
            try deleteGenericPasswordFor(account: account, service: service)
            return
        }
        
        // convert string to data
        guard let passwordData = password.data(using: .utf8) else {
            throw KeychainServiceError(code: .badData)
        }
        
        // dictionary mapping String to Any
        let query: [String: Any] = [
            //defines the class for this item
            kSecClass as String: kSecClassGenericPassword,
            
            // username field
            kSecAttrAccount as String: account,
            
            // arbitrary string that reflects the purpose of the password
            kSecAttrService as String: service,
            
            // set the data for the item
            kSecValueData as String: passwordData
        ]
        
        // ask keychain services to add info to the keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess: // password was put in keychain
            break
        case errSecDuplicateItem: // tried storing an existing item
            try updateGenericPasswordFor(account: account, service: service, password: password)
        default:
            throw KeychainServiceError(status: status, code: .servicesError)
        }
    }
    
    func getGenericPasswordFor(account: String, service: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            
            // expect single item as a search result
            kSecMatchLimit as String: kSecMatchLimitOne,
            
            // tell keychain services to return all data and attributes for the found value
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef? // will hold the keychain services that we find
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            throw KeychainServiceError(code: .itemNotFound)
        }
        guard status == errSecSuccess else {
            throw KeychainServiceError(status: status, code: .servicesError)
        }
        
        guard
            // cast to dictionary
            let existingItem = item as? [String: Any],
            // extract the kSecValueData
            let valueData = existingItem[kSecValueData as String] as? Data,
            // attempt to convert data back to string
            let value = String(data: valueData, encoding: .utf8)
        else {
            throw KeychainServiceError(code: .unableToConvertToString)
        }
        
        return value
    }
    
    func updateGenericPasswordFor(account: String, service: String, password: String) throws {
        guard let passwordData = password.data(using: .utf8) else {
            throw KeychainServiceError(code: .badData)
        }
        
        // specifies the data that I want to update
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        // contains that data that I want to update
        let attributes: [String: Any] = [
            kSecValueData as String: passwordData
        ]
        
        // performs update
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            throw KeychainServiceError(title: nil, code: .servicesError, description: "Matching item not found")
        }
        guard status == errSecSuccess else {
            throw KeychainServiceError(status: status, code: .servicesError)
        }
    }
    
    func deleteGenericPasswordFor(account: String, service: String) throws {
        
        // don't provide new value (unlike in previous cases)
        // if multiple items match a query, keychain services will delete them all
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        // delete
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainServiceError(status: status, code: .servicesError)
        }
    }
}
