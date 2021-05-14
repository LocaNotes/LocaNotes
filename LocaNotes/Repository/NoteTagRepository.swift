//
//  NoteTagRepository.swift
//  LocaNotes
//
//  Created by Anthony C on 4/14/21.
//

import Foundation

public class NoteTagRepository {
    let sqliteDatabaseService: SQLiteDatabaseService
    let restService: RESTService
    
    init() {
//        self.sqliteDatabaseService = SQLiteDatabaseService()
        self.sqliteDatabaseService = SQLiteDatabaseService.shared
        self.restService = RESTService()
    }
    
    func queryBy(serverId: String) throws -> NoteTag? {
        return try sqliteDatabaseService.queryNoteTagBy(serverId: serverId)
    }
    
    func queryFromServer(completion: RESTService.RestResponseReturnBlock<[MongoNoteTagElement]>) {
        restService.queryNoteTag(completion: completion)
    }
    
    func queryBy(noteTagId: Int32) throws -> NoteTag? {
        return try sqliteDatabaseService.queryNoteTagBy(noteTagId: noteTagId)
    }
}
