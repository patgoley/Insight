//
//  NSManagedObject+Description.swift
//  Insight
//
//  Created by Patrick Goley on 11/13/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    public var insightDescription: String {
        
        get {
            
            let range = objectID.description.rangeOfString(" ")!
            
            let managedObjectId = objectID.description.substringToIndex(range.startIndex)
            
            return "\(self.dynamicType) " + managedObjectId
        }
    }
}