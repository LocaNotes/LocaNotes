//
//  DownvoteRepository.swift
//  LocaNotes
//
//  Created by Anthony C on 4/20/21.
//

import Foundation

public class DownvoteRepository {
    private let sqliteDatabaseService: SQLiteDatabaseService
    private let restService: RESTService
    
    init() {
        self.sqliteDatabaseService = SQLiteDatabaseService.shared
        self.restService = RESTService()
    }
    
    func queryAllFromServer(completion: RESTService.RestResponseReturnBlock<[MongoDownvoteElement]>) {
        restService.queryAllDownvotes(completion: completion)
    }
    
    func queryAllFromStorage() throws -> [MongoDownvoteElement]? {
        return try sqliteDatabaseService.queryAllDownvotes()
    }
    
    func queryFromStorageBy(userId: String, noteId: String) throws -> MongoDownvoteElement? {
        return try sqliteDatabaseService.queryDownvoteBy(userId: userId, noteId: noteId)
    }
    
    func insert(userId: String, noteId: String, completion: RESTService.RestResponseReturnBlock<MongoDownvoteElement>) {
        restService.insertDownvote(userId: userId, noteId: noteId, restCompletion: insertCallback(response:error:completion:), insertCompletion: completion)
    }
    
    func insertIntoStorage(serverId: String, userServerId: String, noteServerId: String, createdAt: String, updatedAt: String, v: Int32) throws {
        if let _ = try queryFromStorageBy(userId: userServerId, noteId: noteServerId) {
            print("downvote exists in db already")
        } else {
            try sqliteDatabaseService.insertDownvote(serverId: serverId, userServerId: userServerId, noteServerId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
        }
    }
    
    func delete(downvoteId: String, completion: RESTService.RestResponseReturnBlock<MongoDownvoteElement>) {
        restService.deleteDownvote(downvoteId: downvoteId, restCompletion: { [self] (response, error, completion) in
            if response == nil {
                completion?(response, error)
            } else {
                let serverId = response!.id
                do {
                    try sqliteDatabaseService.deleteDownvoteBy(serverId: downvoteId)
                    completion?(response, error)
                } catch {
                    completion?(response, error)
                }
            }
        }, deleteCompletion: completion)
    }
    
    func insertCallback(response: MongoDownvoteElement?, error: Error?, completion: RESTService.RestResponseReturnBlock<MongoDownvoteElement>) {
        if response == nil {
            completion?(response, error)
        } else {
            let serverId = response!.id
            let userServerId = response!.userID
            let noteServerId = response!.noteID
            let createdAt = response!.createdAt
            let updatedAt = response!.updatedAt
            let v = response!.v
            
            do {
                try self.insertIntoStorage(serverId: serverId, userServerId: userServerId, noteServerId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
                completion?(response, error)
            } catch {
                completion?(response, error)
            }
        }
    }
    
    func getNumberOfDownvotesFromStorageBy(noteId: String) throws -> Int {
        return try sqliteDatabaseService.getNumberOfDownvotesBy(noteId: noteId)
    }
}
