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
    var serverId, userServerId: String
    var privacyId, noteTagId, userId: Int32
    var createdAt, isStory, downvotes, upvotes: Int32
    
    init(_ parent: MKPointAnnotation){
        self.parent = parent
        self.id = 0
        self.userId = 0
        self.createdAt = 0
        self.serverId = ""
        self.userServerId = ""
        self.privacyId = 0
        self.noteTagId = 0
        self.isStory = 0
        self.upvotes = 0
        self.downvotes = 0
        super.init()
    }
    
    override convenience init(){
        self.init(MKPointAnnotation())
    }
    
    func toMKPointAnnotation() -> MKPointAnnotation{
        return self.parent
    }
}
