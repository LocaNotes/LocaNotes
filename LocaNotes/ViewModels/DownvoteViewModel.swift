//
//  DownvoteViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 4/20/21.
//

import Foundation

public class DownvoteViewModel {
    var downvotes: [Downvote] = []

    private let downvoteRepository: DownvoteRepository

    public init() {
        self.downvoteRepository = DownvoteRepository()
    }
    
    func queryAllFromServer(completion: RESTService.RestResponseReturnBlock<[MongoDownvote]>) {
        downvoteRepository.queryAllFromServer(completion: completion)
    }
    
    func queryFromStorageBy(userId: String, noteId: String) -> Downvote? {
        do {
            return try downvoteRepository.queryFromStorageBy(userId: userId, noteId: noteId)
        } catch {
            return nil
        }
    }
    
    func insert(userId: String, noteId: String, completion: RESTService.RestResponseReturnBlock<MongoDownvote>) {
        downvoteRepository.insert(userId: userId, noteId: noteId, completion: completion)
    }
    
    func delete(downvoteId: String, completion: RESTService.RestResponseReturnBlock<MongoDownvote>) {
        downvoteRepository.delete(downvoteId: downvoteId, completion: completion)
    }
    
    func getNumberOfDownvotesFromStorageBy(noteId: String) throws -> Int {
        return try downvoteRepository.getNumberOfDownvotesFromStorageBy(noteId: noteId)
    }
}
