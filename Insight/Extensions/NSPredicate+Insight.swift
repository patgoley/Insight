//
//  NSPredicate+Insight.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

extension NSPredicate {
    
    static func predicateForObjectId(objectId: NSManagedObjectID) -> NSPredicate {
        
        return NSPredicate(format: "SELF = %@", objectId)
    }
}