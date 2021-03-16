//
//  RESTService.swift
//  LocaNotes
//
//  Created by Anthony C on 3/15/21.
//

import Foundation

public class RESTService {
    let urlString = "http://localhost:3000"
    
    typealias NetworkingReturnBlock<T> = ((T?, Error?) -> Void)?
    
    func authenticateUser(username: String, password: String, completion: NetworkingReturnBlock<MongoUser>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/login"
//        components.path = "/login/\(username)/\(password)"
        
//        let parameters: [String: Any] = [
//            "username": username,
//            "password": password
//        ]
//        guard let url = URL(string: urlString) else {
//            return
//        }
        
        let queryItemUsername = URLQueryItem(name: "username", value: username)
        let queryItemPassword = URLQueryItem(name: "password", value: password)
        
        components.queryItems = [queryItemUsername, queryItemPassword]
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        //request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let err = error {
                    completion?(nil, error)
                } else {
                    completion?(nil, nil)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(MongoUser.self, from: data)
                completion?(user, nil)
            } catch let error {
                completion?(nil, error)
            }
//            guard let data = data,
//                  let response = response as? HTTPURLResponse,
//                  error == nil else { // check for networking error
//                print("error", error ?? "Unknown error")
//                return
//            }
//
//            guard (200...299) ~= response.statusCode else { //check for http errors
//                print("statusCode should be 2xx, but is \(response.statusCode)")
//                return
//            }
//
//            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(responseString ?? "")")
        }.resume()
    }
    
    func createUser(firstName: String, lastName: String, email: String, username: String, password: String, completion: NetworkingReturnBlock<MongoUser>) {
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
                
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let err = error {
                    completion?(nil, error)
                } else {
                    completion?(nil, nil)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let user = try decoder.decode(MongoUser.self, from: data)
                completion?(user, nil)
            } catch let error {
                completion?(nil, error)
            }
        }.resume()
    }
}
