//
//  ReportRepository.swift
//  LocaNotes
//
//  Created by Anthony C on 4/22/21.
//

import Foundation

public class ReportRepository {
    private let restService: RESTService
    
    init() {
        self.restService = RESTService()
    }
    
    func insert(noteId: String, userId: String, reportTagId: String, completion: RESTService.RestResponseReturnBlock<MongoReportElement>) {
        restService.insertReport(noteId: noteId, userId: userId, reportTagId: reportTagId, completion: completion)
    }
}
