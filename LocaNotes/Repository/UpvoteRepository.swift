//
//  UpvoteRepository.swift
//  LocaNotes
//
//  Created by Anthony C on 4/21/21.
//

import Foundation

public class UpvoteRepository {
    let sqliteDatabaseService: SQLiteDatabaseService
    let restService: RESTService
    
    init() {
        self.sqliteDatabaseService = SQLiteDatabaseService.shared
        self.restService = RESTService()
    }
    
    func queryAllFromServer(completion: RESTService.RestResponseReturnBlock<[MongoUpvote]>) {
        restService.queryAllUpvotes(completion: completion)
    }
    
    func queryAllFromStorage() throws -> [Upvote]? {
        return try sqliteDatabaseService.queryAllUpvotes()
    }
    
    func queryFromStorageBy(userId: String, noteId: String) throws -> Upvote? {
        return try sqliteDatabaseService.queryUpvoteBy(userId: userId, noteId: noteId)
    }
    
    func insert(userId: String, noteId: String, completion: RESTService.RestResponseReturnBlock<MongoUpvote>) {
        restService.insertUpvote(userId: userId, noteId: noteId, restCompletion: insertCallback(response:error:completion:), insertCompletion: completion)
    }
    
    func insertIntoStorage(serverId: String, userServerId: String, noteServerId: String, createdAt: String, updatedAt: String, v: Int32) throws {
        if let _ = try queryFromStorageBy(userId: userServerId, noteId: noteServerId) {
            print("upvote exists in db already")
        } else {
            try sqliteDatabaseService.insertUpvote(serverId: serverId, userServerId: userServerId, noteServerId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
        }
        
    }
    
    func delete(upvoteId: String, completion: RESTService.RestResponseReturnBlock<MongoUpvote>) {
        //restService.deleteUpvote(upvoteId: upvoteId, completion: completion)
        restService.deleteUpvote(upvoteId: upvoteId, restCompletion: { [self] (response, error, completion) in
            if response == nil {
                completion?(response, error)
            } else {
                let serverId = response!.id
                do {
                    try sqliteDatabaseService.deleteUpvoteBy(serverId: upvoteId)
                    completion?(response, error)
                } catch {
                    completion?(response, error)
                }
            }
        }, deleteCompletion: completion)
    }
    
    func insertCallback(response: MongoUpvote?, error: Error?, completion: RESTService.RestResponseReturnBlock<MongoUpvote>) {
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
                //try sqliteDatabaseService.insertUpvote(serverId: serverId, userServerId: userServerId, noteServerId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
                try self.insertIntoStorage(serverId: serverId, userServerId: userServerId, noteServerId: noteServerId, createdAt: createdAt, updatedAt: updatedAt, v: v)
                completion?(response, error)
            } catch {
                completion?(response, error)
            }
        }
    }
    
    func getNumberOfUpvotesFromStorageBy(noteId: String) throws -> Int {
        return try sqliteDatabaseService.getNumberOfUpvotesBy(noteId: noteId)
    }
}
