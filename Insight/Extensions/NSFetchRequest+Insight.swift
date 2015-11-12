//
//  NSFetchRequest+Insight.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

extension NSFetchRequest {
    
    static func requestForObjectsInRelationship(sourceObject: NSManagedObject, relationship: NSRelationshipDescription) -> NSFetchRequest {
        
        let request = NSFetchRequest()
        
        request.entity = relationship.entity
        
        let inverseRelationship = relationship.inverseRelationship!
        
        if inverseRelationship.toMany {
            
            request.predicate = NSPredicate(format: "%K CONTAINS %@", inverseRelationship.name, sourceObject)
            
        } else {
            
            request.predicate = NSPredicate(format: "%K = %@", inverseRelationship.name, sourceObject)
        }
        
        return request
    }
}