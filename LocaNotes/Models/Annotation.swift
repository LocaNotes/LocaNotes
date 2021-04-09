//
//  Annotation.swift
//  LocaNotes
//
//  Created by Elijah Monzon on 4/8/21.
//

import MapKit

/** Wrapper class for MKPointAnnotation to be more compatible with Note*/
class Annotation: MKPointAnnotation {
    private let parent: MKPointAnnotation
    var id: Int32
    var userid: Int32
    var timestamp: Int32
    
    
    init(_ parent: MKPointAnnotation){
        self.parent = parent
        self.id = 0
        self.userid = 0
        self.timestamp = 0
    }
    
    func toMKPointAnnotation() -> MKPointAnnotation{
        return self.parent
    }
}
