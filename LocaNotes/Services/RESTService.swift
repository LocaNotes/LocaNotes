//
//  RESTService.swift
//  LocaNotes
//
//  Created by Anthony C on 3/15/21.
//

import Foundation

public class RESTService {
    
    typealias RestLoginReturnBlock<T> = ((T?, Error?) -> Void)?
    
    typealias RestResponseReturnBlock<T> = ((T?, Error?) -> Void)?
    
    typealias InsertDownvoteReturnBlock<T> = ((MongoDownvoteElement?, Error?, RestResponseReturnBlock<T>) -> Void)?
    
    typealias InsertUpvoteReturnBlock<T> = ((MongoUpvote?, Error?, RestResponseReturnBlock<T>) -> Void)?
    
    func authenticateUser(username: String, password: String, completion: RestLoginReturnBlock<[MongoUserElement]>) {
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
                let user = try decoder.decode([MongoUserElement].self, from: data!)
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
            if error != nil {
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
    
    func resetEmail(email: String, completion: RestLoginReturnBlock<MongoUserElement>) {
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        do {
            let userRepository = UserRepository()
            guard let user = try userRepository.getUserBy(userId: userId) else {
                completion?(nil, nil)
                return
            }
            
            var components = URLComponents()
            components.scheme = "http"
            components.host = "localhost"
            components.port = 3000
            components.path = "/user/resetemail/\(user.serverId)"
            
            print("server id: \(user.serverId)")
            print("email:\(email)")
            let queryItemEmail = URLQueryItem(name: "email", value: email)
            
            components.queryItems = [queryItemEmail]
            
            guard let url = components.url else { preconditionFailure("Failed to construct URL") }
            
            print(url)
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "PATCH"
                            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let returnedError = self.checkForErrors(data: data, response: response, error: error)
                if returnedError != nil {
                    completion?(nil, returnedError)
                    return
                }
                let user = try? JSONDecoder().decode(MongoUserElement.self, from: data!)
                completion?(user, nil)
            }.resume()
        } catch {
            completion?(nil, error)
            return
        }
    }
    
    func resetPassword(email: String, password: String, completion: RestLoginReturnBlock<MongoUserElement>) {
        do {
            var user: User?
            let userRepository = UserRepository()
            if email.count > 0 {
                user = try userRepository.getUserBy(email: email)
            } else {
                let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
                user = try userRepository.getUserBy(userId: userId)
                if user == nil {
                    completion?(nil, nil)
                    return
                }
            }
            
            var components = URLComponents()
            components.scheme = "http"
            components.host = "localhost"
            components.port = 3000
            components.path = "/user/resetpassword/\(user!.serverId)"
            
            let queryItemPassword = URLQueryItem(name: "password", value: password)
            
            components.queryItems = [queryItemPassword]
            
            guard let url = components.url else { preconditionFailure("Failed to construct URL") }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "PATCH"
                            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let returnedError = self.checkForErrors(data: data, response: response, error: error)
                if returnedError != nil {
                    completion?(nil, returnedError)
                    return
                }
                
                let decoder = JSONDecoder()
                let user = try? decoder.decode(MongoUserElement.self, from: data!)
                completion?(user, nil)
            }.resume()
        }  catch {
            completion?(nil, error)
            return
        }
    }
    
    func resetUsername(username: String, completion: RestLoginReturnBlock<MongoUserElement>) {
        let userId = Int32(UserDefaults.standard.integer(forKey: "userId"))
        
        do {
            let userRepository = UserRepository()
            guard let user = try userRepository.getUserBy(userId: userId) else {
                completion?(nil, nil)
                return
            }
            
            var components = URLComponents()
            components.scheme = "http"
            components.host = "localhost"
            components.port = 3000
            components.path = "/user/resetusername/\(user.serverId)"
            
            let queryItemUsername = URLQueryItem(name: "username", value: username)
            
            components.queryItems = [queryItemUsername]
            
            guard let url = components.url else { preconditionFailure("Failed to construct URL") }
            
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "PATCH"
                            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let returnedError = self.checkForErrors(data: data, response: response, error: error)
                if returnedError != nil {
                    completion?(nil, returnedError)
                    return
                }
                
                let decoder = JSONDecoder()
                let user = try? decoder.decode(MongoUserElement.self, from: data!)
                completion?(user, nil)
            }.resume()
        } catch {
            completion?(nil, error)
        }
    }
    
    func forgotPasswordSendEmail(email: String, completion: RestLoginReturnBlock<MongoUserElement>) {
        
        do {
            var components = URLComponents()
            components.scheme = "http"
            components.host = "localhost"
            components.port = 3000
            components.path = "/user/forgotpassword"
            
            let queryItemUsername = URLQueryItem(name: "email", value: email)
            
            components.queryItems = [queryItemUsername]
            
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
                let user = try? decoder.decode(MongoUserElement.self, from: data!)
                completion?(user, nil)
            }.resume()
        } catch {
            completion?(nil, error)
        }
    }
    
    func forgotPasswordSendTemporaryPassword(email: String, temporaryPassword: String, completion: RestLoginReturnBlock<MongoUserElement>) {
        do {
            var components = URLComponents()
            components.scheme = "http"
            components.host = "localhost"
            components.port = 3000
            components.path = "/user/verifytemporarypassword"
            
            let queryItemEmail = URLQueryItem(name: "email", value: email)
            let queryItemTemporaryPassword = URLQueryItem(name: "temporaryPassword", value: temporaryPassword)
            
            components.queryItems = [queryItemEmail, queryItemTemporaryPassword]
            
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
                let user = try? decoder.decode(MongoUserElement.self, from: data!)
                completion?(user, nil)
            }.resume()
        } catch {
            completion?(nil, error)
        }
    }
    
    func insertNote(userId: Int32, privacyId: Int32, noteTagId: Int32, title: String, latitude: String, longitude: String, body: String, isStory: Bool, completion: RestResponseReturnBlock<MongoNoteElement>, UICompletion: (() -> Void)?) {
                
        do {
            let userRepository = UserRepository()
            guard let user = try userRepository.getUserBy(userId: userId) else {
                completion?(nil, nil)
                return
            }
            
            var components = URLComponents()
            components.scheme = "http"
            components.host = "localhost"
            components.port = 3000
            components.path = "/notes"
            
            var privacyIdServer: String
            switch (privacyId) {
            case 1: // private
                privacyIdServer = "606143349a65a46b36955c45"
            case 2: // public
                privacyIdServer = "6061432c9a65a46b36955c44"
            default:
                privacyIdServer = "606143349a65a46b36955c45"
            }
            
            var noteTagIdServer: String
            switch (noteTagId) {
            case 4: // emergency
                noteTagIdServer = "606143549a65a46b36955c46"
            case 3: // dining
                noteTagIdServer = "606143599a65a46b36955c47"
            case 2: // meme
                noteTagIdServer = "6061435c9a65a46b36955c48"
            case 1: // other
                noteTagIdServer = "606143609a65a46b36955c49"
            default:
                noteTagIdServer = "606143609a65a46b36955c49"
            }
            
            
            let queryItemUserId = URLQueryItem(name: "userId", value: String(user.serverId))
            let queryItemPrivacyId = URLQueryItem(name: "privacyId", value: privacyIdServer)
            let queryItemNoteTagId = URLQueryItem(name: "noteTagId", value: noteTagIdServer)
            let queryItemTitle = URLQueryItem(name: "title", value: title)
            let queryItemLatitude = URLQueryItem(name: "latitude", value: latitude)
            let queryItemLongitude = URLQueryItem(name: "longitude", value: longitude)
            let queryItemBody = URLQueryItem(name: "body", value: body)
            let queryItemIsStory = URLQueryItem(name: "isStory", value: String(isStory))
            let queryItemDownvotes = URLQueryItem(name: "downvotes", value: "0")
            let queryItemUpvotes = URLQueryItem(name: "upvotes", value: "0")
            
            components.queryItems = [queryItemUserId, queryItemPrivacyId, queryItemNoteTagId, queryItemTitle, queryItemLatitude, queryItemLongitude, queryItemBody, queryItemIsStory, queryItemDownvotes, queryItemUpvotes]
            
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
                let note = try? decoder.decode(MongoNoteElement.self, from: data!)
                print("here")
                completion?(note, nil)
                UICompletion?()
            }.resume()
        } catch {
            completion?(nil, error)
        }
    }
    
    func deleteNoteBy(id: String, completion: RestResponseReturnBlock<MongoNoteElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/notes/\(id)"
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "DELETE"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let note = try? decoder.decode(MongoNoteElement.self, from: data!)
            completion?(note, nil)
        }.resume()
    }
    
    func updateNoteBody(note: Note, completion: RestResponseReturnBlock<MongoNoteElement>) {
        
        let serverId = note.serverId
        let serverUserId = note.userServerId
        let privacyId = note.privacyId
        let noteTagId = note.noteId
        let title = note.title
        let latitude = note.latitude
        let longitude = note.longitude
        let body = note.body
        let isStory = note.isStory
        let downvotes = note.downvotes
        let upvotes = note.upvotes
        
        var privacyIdServer: String
        switch (privacyId) {
        case 1: // public
            privacyIdServer = "6061432c9a65a46b36955c44"
        case 2: // private
            privacyIdServer = "606143349a65a46b36955c45"
        default:
            privacyIdServer = "606143349a65a46b36955c45"
        }
        
        var noteTagIdServer: String
        switch (noteTagId) {
        case 1: // emergency
            noteTagIdServer = "606143549a65a46b36955c46"
        case 2: // dining
            noteTagIdServer = "606143599a65a46b36955c47"
        case 3: // meme
            noteTagIdServer = "6061435c9a65a46b36955c48"
        case 4: // other
            noteTagIdServer = "606143609a65a46b36955c49"
        default:
            noteTagIdServer = "606143609a65a46b36955c49"
        }
        
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/notes/\(serverId)"
        
        let queryItemUserId = URLQueryItem(name: "userId", value: serverUserId)
        let queryItemPrivacyId = URLQueryItem(name: "privacyId", value: privacyIdServer)
        let queryItemNoteTagId = URLQueryItem(name: "noteTagId", value: noteTagIdServer)
        let queryItemTitle = URLQueryItem(name: "title", value: title)
        let queryItemLatitude = URLQueryItem(name: "latitude", value: latitude)
        let queryItemLongitude = URLQueryItem(name: "longitude", value: longitude)
        let queryItemBody = URLQueryItem(name: "body", value: body)
        let queryItemIsStory = URLQueryItem(name: "isStory", value: String(isStory))
        let queryItemDownvotes = URLQueryItem(name: "downvotes", value: String(downvotes))
        let queryItemUpvotes = URLQueryItem(name: "upvotes", value: String(upvotes))
        
        components.queryItems = [queryItemUserId, queryItemPrivacyId, queryItemNoteTagId, queryItemTitle, queryItemLatitude, queryItemLongitude, queryItemBody, queryItemIsStory, queryItemDownvotes, queryItemUpvotes]
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "PATCH"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let note = try? decoder.decode(MongoNoteElement.self, from: data!)
            completion?(note, nil)
        }.resume()
    }
    
    func queryServerNotesBy(userId: String, completion: RestResponseReturnBlock<[MongoNoteElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/notes"
        
        let queryItemUserId = URLQueryItem(name: "userId", value: userId)
        
        components.queryItems = [queryItemUserId]
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let note = try? decoder.decode([MongoNoteElement].self, from: data!)
            completion?(note, nil)
        }.resume()
    }
    
    func queryCommentsFromServerBy(userId: String, completion: RestResponseReturnBlock<[MongoCommentElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/comment"
        
        let queryItemUserId = URLQueryItem(name: "userId", value: userId)
        
        components.queryItems = [queryItemUserId]
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let comments = try? decoder.decode([MongoCommentElement].self, from: data!)
            completion?(comments, nil)
        }.resume()
    }
    
    func queryCommentsFromServerBy(noteId: String, completion: RestResponseReturnBlock<[MongoCommentElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/comment"
        
        let queryItemUserId = URLQueryItem(name: "noteId", value: noteId)
        
        components.queryItems = [queryItemUserId]
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let comments = try? decoder.decode([MongoCommentElement].self, from: data!)
            completion?(comments, nil)
        }.resume()
    }
    
    func queryAllServerPublicRegularNotes(completion: RestResponseReturnBlock<[MongoNoteElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/notes"
        
        let queryItemPublic = URLQueryItem(name: "public", value: "true")
        
        components.queryItems = [queryItemPublic]
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let notes = try? decoder.decode([MongoNoteElement].self, from: data!)
            completion?(notes, nil)
        }.resume()
    }
    
    func queryAllServerUsers(completion: RestResponseReturnBlock<[MongoUserElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/user"
                                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let users = try? decoder.decode([MongoUserElement].self, from: data!)
            completion?(users, nil)
        }.resume()
    }
    
    func queryPrivacy(completion: RestResponseReturnBlock<[MongoPrivacyElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/privacy"
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let privacies = try? decoder.decode([MongoPrivacyElement].self, from: data!)
            completion?(privacies, nil)
        }.resume()
    }
    
    func queryNoteTag(completion: RestResponseReturnBlock<[MongoNoteTagElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/notetag"
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let noteTags = try? decoder.decode([MongoNoteTagElement].self, from: data!)
            completion?(noteTags, nil)
        }.resume()
    }
    
    func queryAllDownvotes(completion: RestResponseReturnBlock<[MongoDownvoteElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/downvote"
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let downvotes = try? decoder.decode([MongoDownvoteElement].self, from: data!)
            completion?(downvotes, nil)
        }.resume()
    }
    
    func insertDownvote(userId: String, noteId: String, restCompletion: InsertDownvoteReturnBlock<MongoDownvoteElement>, insertCompletion: RestResponseReturnBlock<MongoDownvoteElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/downvote"
        
        let queryItemUserId = URLQueryItem(name: "userId", value: userId)
        let queryItemNoteId = URLQueryItem(name: "noteId", value: noteId)
        
        components.queryItems = [queryItemUserId, queryItemNoteId]
                                                
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                restCompletion?(nil, returnedError, insertCompletion)
                return
            }
            
            let decoder = JSONDecoder()
            let downvotes = try? decoder.decode(MongoDownvoteElement.self, from: data!)
            restCompletion?(downvotes, nil, insertCompletion)
        }.resume()
    }
    
    func deleteDownvote(downvoteId: String, restCompletion: ((MongoDownvoteElement?, Error?, RestResponseReturnBlock<MongoDownvoteElement>) -> Void)?, deleteCompletion: RestResponseReturnBlock<MongoDownvoteElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/downvote/\(downvoteId)"
                                                                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "DELETE"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                restCompletion?(nil, returnedError, deleteCompletion)
                return
            }
            
            let decoder = JSONDecoder()
            let downvotes = try? decoder.decode(MongoDownvoteElement.self, from: data!)
            restCompletion?(downvotes, nil, deleteCompletion)
        }.resume()
    }
    
    func queryAllUpvotes(completion: RestResponseReturnBlock<[MongoUpvote]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/upvote"
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let upvotes = try? decoder.decode([MongoUpvote].self, from: data!)
            completion?(upvotes, nil)
        }.resume()
    }

    func insertUpvote(userId: String, noteId: String, restCompletion: InsertUpvoteReturnBlock<MongoUpvote>, insertCompletion: RestResponseReturnBlock<MongoUpvote>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/upvote"
        
        let queryItemUserId = URLQueryItem(name: "userId", value: userId)
        let queryItemNoteId = URLQueryItem(name: "noteId", value: noteId)
        
        components.queryItems = [queryItemUserId, queryItemNoteId]
                                                
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                restCompletion?(nil, returnedError, insertCompletion)
                return
            }
            
            let decoder = JSONDecoder()
            let upvotes = try? decoder.decode(MongoUpvote.self, from: data!)
            restCompletion?(upvotes, nil, insertCompletion)
        }.resume()
    }

    func deleteUpvote(upvoteId: String, restCompletion: ((MongoUpvote?, Error?, RestResponseReturnBlock<MongoUpvote>) -> Void)?, deleteCompletion: RestResponseReturnBlock<MongoUpvote>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/upvote/\(upvoteId)"
                                                                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "DELETE"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                restCompletion?(nil, returnedError, deleteCompletion)
                return
            }
            
            let decoder = JSONDecoder()
            let upvotes = try? decoder.decode(MongoUpvote.self, from: data!)
            restCompletion?(upvotes, nil, deleteCompletion)
        }.resume()
    }
    
    func getUserBy(serverId: String, completion: RestResponseReturnBlock<[MongoUserElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/user"
        
        let queryItemUserId = URLQueryItem(name: "userId", value: serverId)
        
        components.queryItems = [queryItemUserId]
                                                                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let user = try? decoder.decode([MongoUserElement].self, from: data!)
            completion?(user, nil)
        }.resume()
    }
    
    func insertComment(userId: String, noteId: String, body: String, completion: RestResponseReturnBlock<MongoCommentElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/comment"
        
        let queryItemUserId = URLQueryItem(name: "userId", value: userId)
        let queryItemNoteId = URLQueryItem(name: "noteId", value: noteId)
        let queryItemBody = URLQueryItem(name: "body", value: body)
        
        components.queryItems = [queryItemUserId, queryItemNoteId, queryItemBody]
                                                                        
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
            let comment = try? decoder.decode(MongoCommentElement.self, from: data!)
            completion?(comment, nil)
        }.resume()
    }
    
    func queryReportTag(completion: RestResponseReturnBlock<[MongoReportTagElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/reporttag"
                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let reportTags = try? decoder.decode([MongoReportTagElement].self, from: data!)
            completion?(reportTags, nil)
        }.resume()
    }
    
    func insertReport(noteId: String, userId: String, reportTagId: String, completion: RestResponseReturnBlock<MongoReportElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/report"
        
        let queryItemNoteId = URLQueryItem(name: "noteId", value: noteId)
        let queryItemUserId = URLQueryItem(name: "userId", value: userId)
        let queryItemReportTagId = URLQueryItem(name: "reportTagId", value: reportTagId)
        
        components.queryItems = [queryItemUserId, queryItemNoteId, queryItemReportTagId]
                                                                        
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
            let report = try? decoder.decode(MongoReportElement.self, from: data!)
            completion?(report, nil)
        }.resume()
    }
    
    func searchForUserBy(username: String, completion: RestResponseReturnBlock<[MongoUserElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/user"
        
        let queryItemUsername = URLQueryItem(name: "username", value: username)
        
        components.queryItems = [queryItemUsername]
                                                                        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let user = try? decoder.decode([MongoUserElement].self, from: data!)
            completion?(user, nil)
        }.resume()
    }
    
    func getFriendListFor(userId: String, completion: RestResponseReturnBlock<[MongoUserElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/friend/users/\(userId)"
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let users = try? decoder.decode([MongoUserElement].self, from: data!)
            completion?(users, nil)
        }.resume()
    }
    
    func addFriend(frienderId: String, friendeeId: String, completion: RestResponseReturnBlock<MongoFriendElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/friend"
        
        let queryItemUserId = URLQueryItem(name: "userId", value: frienderId)
        let queryItemFriendUserId = URLQueryItem(name: "friendUserId", value: friendeeId)
        
        components.queryItems = [queryItemUserId, queryItemFriendUserId]
                                                                        
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
            let friend = try? decoder.decode(MongoFriendElement.self, from: data!)
            completion?(friend, nil)
        }.resume()
    }
    
    func removeFriend(frienderId: String, friendeeId: String, completion: RestResponseReturnBlock<MongoFriendElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/friend/\(frienderId)/\(friendeeId)"
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "DELETE"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let friend = try? decoder.decode(MongoFriendElement.self, from: data!)
            completion?(friend, nil)
        }.resume()
    }
    
    func checkIfFriends(frienderId: String, friendeeId: String, completion: RestResponseReturnBlock<[MongoFriendElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/friend/\(frienderId)/\(friendeeId)"
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let friend = try? decoder.decode([MongoFriendElement].self, from: data!)
            completion?(friend, nil)
        }.resume()
    }
    
    func checkIfSharedFor(noteId: String, receiverId: String, completion: RestResponseReturnBlock<[MongoShareElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/share"
        
        let queryItemNoteId = URLQueryItem(name: "noteId", value: noteId)
        let queryItemReceiverId = URLQueryItem(name: "receiverId", value: receiverId)
        
        components.queryItems = [queryItemNoteId, queryItemReceiverId]
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let share = try? decoder.decode([MongoShareElement].self, from: data!)
            completion?(share, nil)
        }.resume()
    }
    
    func getSharedNotesFor(receiverId: String, completion: RestResponseReturnBlock<[MongoNoteElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/share/notes/\(receiverId)"
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
                
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let notes = try? decoder.decode([MongoNoteElement].self, from: data!)
            completion?(notes, nil)
        }.resume()
    }
    
    func getSharesFor(receiverId: String, completion: RestResponseReturnBlock<[MongoShareElement]>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/share/\(receiverId)"
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
                
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let shares = try? decoder.decode([MongoShareElement].self, from: data!)
            completion?(shares, nil)
        }.resume()
    }
    
    func sharePrivateNoteWith(noteId: String, receiverId: String, completion: RestResponseReturnBlock<MongoShareElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/share"
        
        let queryItemNoteId = URLQueryItem(name: "noteId", value: noteId)
        let queryItemReceiverId = URLQueryItem(name: "receiverId", value: receiverId)
        
        components.queryItems = [queryItemNoteId, queryItemReceiverId]
        
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
            let share = try? decoder.decode(MongoShareElement.self, from: data!)
            completion?(share, nil)
        }.resume()
    }
    
    func updateUser(radius: Double, userId: String, completion: RestResponseReturnBlock<MongoUserElement>) {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost"
        components.port = 3000
        components.path = "/user/updateuserradius/\(userId)"
        
        let queryItemRadius = URLQueryItem(name: "radius", value: String(radius))
        
        components.queryItems = [queryItemRadius]
        
        guard let url = components.url else { preconditionFailure("Failed to construct URL") }
                
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "PATCH"
                        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let returnedError = self.checkForErrors(data: data, response: response, error: error)
            if returnedError != nil {
                completion?(nil, returnedError)
                return
            }
            
            let decoder = JSONDecoder()
            let user = try? decoder.decode(MongoUserElement.self, from: data!)
            completion?(user, nil)
        }.resume()
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
