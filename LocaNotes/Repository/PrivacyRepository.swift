//
//  PrivacyRepository.swift
//  LocaNotes
//
//  Created by Anthony C on 4/14/21.
//

import Foundation

public class PrivacyRepository {
    private let sqliteDatabaseService: SQLiteDatabaseService
    private let restService: RESTService
    
    init() {
        self.sqliteDatabaseService = SQLiteDatabaseService.shared
        self.restService = RESTService()
    }
    
    func queryAllFromStorage() throws -> [Privacy]? {
        return try sqliteDatabaseService.queryAllPrivacies()
    }
    
    func queryPrivacyBy(serverId: String) throws -> Privacy? {
        return try sqliteDatabaseService.queryPrivacyBy(serverId: serverId)
    }
    
    func queryFromServer(completion: RESTService.RestResponseReturnBlock<[MongoPrivacyElement]>) {
        restService.queryPrivacy(completion: completion)
    }
}
