//
//  RESTService.swift
//  LocaNotes
//
//  Created by Anthony C on 3/15/21.
//

import Foundation

public class RESTService {
    
    typealias RestLoginReturnBlock<T> = ((T?, Error?) -> Void)?
    
    func authenticateUser(username: String, password: String, completion: RestLoginReturnBlock<MongoUser>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/login"
        
        let queryItemUsername = URLQueryItem(name: "username", value: username)
        let queryItemPassword = URLQueryItem(name: "password", value: password)
        
        components.queryItems = [queryItemUsername, queryItemPassword]
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(MongoUser.self, from: data!)
                completion?(user, nil)
            } catch let error {
                completion?(nil, error)
            }
        }.resume()
    }
    
    func createUser(firstName: String, lastName: String, email: String, username: String, password: String, completion: RestLoginReturnBlock<MongoUserElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/user"
        
        let queryItemFirstName = URLQueryItem(name: "firstName", value: firstName)
        let queryItemLastName = URLQueryItem(name: "lastName", value: lastName)
        let queryItemEmail = URLQueryItem(name: "email", value: email)
        let queryItemUsername = URLQueryItem(name: "username", value: username)
        let queryItemPassword = URLQueryItem(name: "password", value: password)
        
        components.queryItems = [queryItemFirstName, queryItemLastName, queryItemEmail, queryItemUsername, queryItemPassword]
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(MongoUserElement.self, from: data!)
                completion?(user, nil)
            } catch let error {
                completion?(nil, error)
            }
        }.resume()
    }
    
    private func checkForErrors(data: Data?, response: URLResponse?, error: Error?) -> Error? {
        guard let data = data, let response = response as? HTTPURLResponse else {
            if let err = error {
                return error
            } else {
                return nil
            }
        }
        
        let statusCode = response.statusCode
        guard (200...299) ~= statusCode else { //check for http errors
            let restError = self.handleErrorStatusCode(statusCode: statusCode, data: data)
            return restError
        }
        
        return nil
    }
    
    private func handleErrorStatusCode(statusCode: Int, data: Data) -> RestError {
        var restError = RestError(title: nil, code: statusCode, description: nil)
        if let json = String(data: data, encoding: String.Encoding.utf8) {
            if let decodedJson = json.data(using: .utf8) {
                do {
                    if let serializedJson = try JSONSerialization.jsonObject(with: decodedJson, options: []) as? [String: String] {
                        if let errorMessage = serializedJson["error"] {
                            
                            // get error message from server
                            restError = RestError(title: nil, code: statusCode, description: errorMessage)
                        } else {
                            
                            // response from server doesn't have an "error" key
                            restError = RestError(title: nil, code: statusCode, description: nil)
                        }
                    }
                } catch {
                    
                    // couldn't serialize json
                    print(error.localizedDescription)
                    restError = RestError(title: nil, code: statusCode, description: nil)
                }
            }
            return restError
        }
        return restError
    }
}

protocol RestErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

struct RestError: RestErrorProtocol {
    var title: String?
    var code: Int
    
    var description: String? { return _description }
    private var _description: String
    
    init (title: String?, code: Int, description: String?) {
        self.title = title ?? "Error"
        self.code = code
        self._description = description ?? "Unknown error"
    }
}
