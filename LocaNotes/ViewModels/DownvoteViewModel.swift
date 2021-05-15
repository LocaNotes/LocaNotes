//
//  DownvoteViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 4/20/21.
//

import Foundation

public class DownvoteViewModel {
    private let downvoteRepository: DownvoteRepository

    public init() {
        self.downvoteRepository = DownvoteRepository()
    }
    
    func queryAllFromServer(completion: RESTService.RestResponseReturnBlock<[MongoDownvoteElement]>) {
        downvoteRepository.queryAllFromServer(completion: completion)
    }
    
    func queryFromStorageBy(userId: String, noteId: String) -> MongoDownvoteElement? {
        do {
            return try downvoteRepository.queryFromStorageBy(userId: userId, noteId: noteId)
        } catch {
            return nil
        }
    }
    
    func insert(userId: String, noteId: String, completion: RESTService.RestResponseReturnBlock<MongoDownvoteElement>) {
        downvoteRepository.insert(userId: userId, noteId: noteId, completion: completion)
    }
    
    func insertIntoStorage(serverId: String, userId: String, noteId: String, createdAt: String, updatedAt: String, v: Int32) throws {
        try downvoteRepository.insertIntoStorage(serverId: serverId, userServerId: userId, noteServerId: noteId, createdAt: createdAt, updatedAt: updatedAt, v: v)
    }
    
    func delete(downvoteId: String, completion: RESTService.RestResponseReturnBlock<MongoDownvoteElement>) {
        downvoteRepository.delete(downvoteId: downvoteId, completion: completion)
    }
    
    func getNumberOfDownvotesFromStorageBy(noteId: String) throws -> Int {
        return try downvoteRepository.getNumberOfDownvotesFromStorageBy(noteId: noteId)
    }
}
