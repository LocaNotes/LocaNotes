//
//  NoteTagViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 4/14/21.
//

import Foundation

public class NoteTagViewModel {
    private let noteTagRepository: NoteTagRepository

    public init() {
        self.noteTagRepository = NoteTagRepository()
    }
    
    func queryBy(noteTagId: Int32) throws -> NoteTag? {
        return try noteTagRepository.queryBy(noteTagId: noteTagId)
    }
    
    func queryBy(serverId: String) -> NoteTag? {
        do {
            return try noteTagRepository.queryBy(serverId: serverId)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func queryFromServer(completion: RESTService.RestResponseReturnBlock<[MongoNoteTagElement]>) {
        noteTagRepository.queryFromServer(completion: completion)
    }
}
