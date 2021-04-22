//
//  UpvoteViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 4/21/21.
//

import Foundation

public class UpvoteViewModel {
    var upvotes: [Upvote] = []

    private let upvoteRepository: UpvoteRepository

    public init() {
        self.upvoteRepository = UpvoteRepository()
    }
    
    func queryAllFromServer(completion: RESTService.RestResponseReturnBlock<[MongoUpvote]>) {
        upvoteRepository.queryAllFromServer(completion: completion)
    }
    
    func queryFromStorageBy(userId: String, noteId: String) -> Upvote? {
        do {
            return try upvoteRepository.queryFromStorageBy(userId: userId, noteId: noteId)
        } catch {
            return nil
        }
    }
    
    func insert(userId: String, noteId: String, completion: RESTService.RestResponseReturnBlock<MongoUpvote>) {
        upvoteRepository.insert(userId: userId, noteId: noteId, completion: completion)
    }
    
    func insertIntoStorage(serverId: String, userId: String, noteId: String, createdAt: String, updatedAt: String, v: Int32) throws {
        try upvoteRepository.insertIntoStorage(serverId: serverId, userServerId: userId, noteServerId: noteId, createdAt: createdAt, updatedAt: updatedAt, v: v)
    }
    
    func delete(upvoteId: String, completion: RESTService.RestResponseReturnBlock<MongoUpvote>) {
        upvoteRepository.delete(upvoteId: upvoteId, completion: completion)
    }
    
    func getNumberOfUpvotesFromStorageBy(noteId: String) throws -> Int {
        return try upvoteRepository.getNumberOfUpvotesFromStorageBy(noteId: noteId)
    }
}
