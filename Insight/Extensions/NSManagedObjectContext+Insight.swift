//
//  NSManagedObjectContext+Insight.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    var entities: [NSEntityDescription] {
        
        return parentStoreCoordinator().managedObjectModel.entities
    }
    
    func parentStoreCoordinator() -> NSPersistentStoreCoordinator {
        
        var context = self
        
        var coordinator = context.persistentStoreCoordinator
        
        while coordinator == nil {
            
            if let parentContext = context.parentContext {
                
                coordinator = parentContext.persistentStoreCoordinator
                
                context = parentContext
                
            } else {
                
                fatalError("context has no persistent store coordinator or parent context")
            }
        }
        
        return coordinator!
    }
}