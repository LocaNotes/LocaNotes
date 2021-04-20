//
//  CommentViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 4/14/21.
//

import Foundation

public class CommentViewModel {
      
    var comments: [Comment] = []

    private let commentsRepository: CommentsRepository

    public init() {
        self.commentsRepository = CommentsRepository()
    }
    
    func queryCommentsFromServerBy(userId: String, completion: RESTService.RestResponseReturnBlock<[MongoCommentElement]>) {
        commentsRepository.queryCommentsFromServerBy(userId: userId, completion: completion)
    }
    
    func queryLocalCommentBy(serverId: String) -> Comment? {
        do {
            return try commentsRepository.queryLocalCommentBy(serverId: serverId)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func insertCommentsFromServer(comments: [MongoCommentElement]) {
        for comment in comments {
            let serverId = comment.id
            let noteServerId = comment.noteID
            let userServerId = comment.userID
            let body = comment.body
            let createdAt = comment.createdAt
            
            let index = createdAt.index(createdAt.startIndex, offsetBy: 19)
            let substring = createdAt[..<index]
            let timestamp = String(substring) + "Z"
            
            let formatter = ISO8601DateFormatter()
            let date = formatter.date(from: timestamp)
            let unix = date?.timeIntervalSince1970
            let timeCommented = Int32(unix!)
            
            do {
                // first check if comment is already in db
                if queryLocalCommentBy(serverId: serverId) == nil {
                    
                    // get noteId from DB by noteServerId
                    let noteViewModel = NoteViewModel()
                    guard let note: Note = try noteViewModel.queryNoteBy(serverId: noteServerId) else {
                        return
                    }
                    
                    // get userId from DB by userServerId
                    let userViewModel = UserViewModel()
                    guard let user: User = try userViewModel.queryUserBy(serverId: userServerId) else {
                        return
                    }
                                    
                    try commentsRepository.insertComment(serverId: serverId, noteId: note.noteId, noteServerId: noteServerId, userId: user.userId, userServerId: userServerId, body: body, timeCommented: timeCommented)
                }
            } catch {
                print("\(error.localizedDescription)")
            }
        }
    }
}


