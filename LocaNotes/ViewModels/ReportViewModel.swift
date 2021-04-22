//
//  ReportViewModel.swift
//  LocaNotes
//
//  Created by Anthony C on 4/22/21.
//

import Foundation

public class ReportViewModel {
    private let reportRepository: ReportRepository
    
    init() {
        reportRepository = ReportRepository()
    }
    
    func insert(noteId: String, userId: String, reportTagId: String, completion: RESTService.RestResponseReturnBlock<MongoReportElement>) {
        reportRepository.insert(noteId: noteId, userId: userId, reportTagId: reportTagId, completion: completion)
    }
}
