//
//  NSManagedObject+Insight.swift
//  Insight
//
//  Created by Patrick Goley on 11/12/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    //MARK: Access
    
    func objectsInRelationship(relationship: NSRelationshipDescription) -> NSSet {
        
        precondition(relationship.toMany)
        
        if let set = valueForKey(relationship.name) as? NSSet {
            
            return set
            
        } else {
            
            return NSSet()
        }
    }
    
    func objectForRelationship(relationship: NSRelationshipDescription) -> NSManagedObject? {
        
        precondition(!relationship.toMany)
        
        return valueForKey(relationship.name) as? NSManagedObject
    }
    
    //MARK: Adding objects
    
    func addObjects(objects: [NSManagedObject], toRelationship relationship: NSRelationshipDescription) {
        
        precondition(relationship.toMany, "add objects to relationship must be called with a to-many relationship")
        
        let mutableSet = mutableSetForRelationship(relationship)
        
        mutableSet.addObjectsFromArray(objects)
        
        let set = NSSet(set: mutableSet)
        
        setValue(set, forKey: relationship.name)
    }
    
    func addObject(object: NSManagedObject, toRelationship relationship: NSRelationshipDescription) {
        
        guard relationship.toMany == false else {
            
            addObjects([object], toRelationship: relationship)
            
            return
        }
        
        setValue(object, forKey: relationship.name)
    }
    
    //MARK: Removing objects
    
    func removeObjects(var objects: [NSManagedObject], fromRelationship relationship: NSRelationshipDescription) {
        
        precondition(relationship.toMany, "remove objects from relationship must be called with a to-many relationship")
        
        let mutableSet = mutableSetForRelationship(relationship)
        
        guard mutableSet.count > 0 else {
            
            print("no objects in relationship to remove")
            
            return
        }
        
        while objects.count > 0 {
            
            let object = objects.removeFirst()
            
            if mutableSet.containsObject(object) {
                
                mutableSet.removeObject(object)
                
            } else {
                
                print("relationship did not contain object to remove \(object)")
            }
        }
        
        setValue(mutableSet.copy(), forKey: relationship.name)
    }
    
    func removeObject(object: NSManagedObject, fromRelationship relationship: NSRelationshipDescription) {
        
        guard relationship.toMany == false else {
            
            removeObjects([object], fromRelationship: relationship)
            
            return
        }
        
        guard let currentRelatedObject = self.valueForKey(relationship.name) as? NSManagedObject else {
            
            print("no object in relationship to remove")
            
            return
        }
        
        guard currentRelatedObject.isEqual(object) else {
            
            print("object being removed was not equal to the current related object")
            
            return
        }
        
        setValue(nil, forKey: relationship.name)
    }
    
    //MARK: Utility
    
    private func mutableSetForRelationship(relationship: NSRelationshipDescription) -> NSMutableSet {
        
        if let relationshipSet = valueForKey(relationship.name) as? NSSet {
            
            return relationshipSet.mutableCopy() as! NSMutableSet
            
        } else {
            
            return NSMutableSet()
        }
    }
}