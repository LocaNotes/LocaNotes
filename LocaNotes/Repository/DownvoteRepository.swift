//
//  DownvoteRepository.swift
//  LocaNotes
//
//  Created by Anthony C on 4/20/21.
//

import Foundation

public class DownvoteRepository {
    let sqliteDatabaseService: SQLiteDatabaseService
    let restService: RESTService
    
    init() {
        self.sqliteDatabaseService = SQLiteDatabaseService.shared
        self.restService = RESTService()
    }
    
    func queryAllFromServer(completion: RESTService.RestResponseReturnBlock<[MongoDownvote]>) {
        restService.queryAllDownvotes(completion: completion)
    }
    
    func queryAllFromStorage() throws -> [Downvote]? {
        return try sqliteDatabaseService.queryAllDownvotes()
    }
    
    func queryFromStorageBy(userId: String, noteId: String) throws -> Downvote? {
        return try sqliteDatabaseService.queryDownvoteBy(userId: userId, noteId: noteId)
    }
    
    func insert(userId: String, noteId: String, completion: RESTService.RestResponseReturnBlock<MongoDownvote>) {
        restService.insertDownvote(userId: userId, noteId: noteId, restCompletion: insertCallback(response:error:completion:), insertCompletion: completion)
    }
    
    func delete(downvoteId: String, completion: RESTService.RestResponseReturnBlock<MongoDownvote>) {
        //restService.deleteDownvote(downvoteId: downvoteId, completion: completion)
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
    
    func insertCallback(response: MongoDownvote?, error: Error?, completion: RESTService.RestResponseReturnBlock<MongoDownvote>) {
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
                try sqliteDatabaseService.insertDownvote(serverId: serverId, userServerId: userServerId, noteServerId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
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
