//
//  PrivacyViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 4/14/21.
//

import Foundation

public class PrivacyViewModel {
    private let privacyRepository: PrivacyRepository

    public init() {
        self.privacyRepository = PrivacyRepository()
    }
    
    func queryAllFromStorage() -> [Privacy]? {
        do {
            return try privacyRepository.queryAllFromStorage()
        } catch {
            print("\(error.localizedDescription)")
            return nil
        }
    }
    
    func queryPrivacyBy(serverId: String) -> Privacy? {
        do {
            return try privacyRepository.queryPrivacyBy(serverId: serverId)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func queryFromServer(completion: RESTService.RestResponseReturnBlock<[MongoPrivacyElement]>) {
        privacyRepository.queryFromServer(completion: completion)
    }
}
