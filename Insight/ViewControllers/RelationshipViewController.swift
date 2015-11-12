//
//  RelationshipViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class RelationshipViewController : FetchRequestViewController {
    
    let sourceObject: NSManagedObject
    
    let relationship: NSRelationshipDescription
    
    public required init(sourceObject: NSManagedObject, relationship: NSRelationshipDescription, context: NSManagedObjectContext) {
        
        self.sourceObject = sourceObject
        
        self.relationship = relationship
        
        let request = NSFetchRequest.requestForObjectsInRelationship(sourceObject, relationship: relationship)
        
        super.init(request: request, context: context, entity: request.entity!)
        
        self.title = relationship.name
    }

    required public init(request: NSFetchRequest, context: NSManagedObjectContext, entity: NSEntityDescription) {
        fatalError("init(request:context:entity:) has not been implemented")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
            
        case .Delete:
            
            let deletedObject = objectAtIndexPath(indexPath)
            
            let mutableSet = mutableRelationshipSet()
            
            mutableSet.removeObject(deletedObject)
            
            sourceObject.setValue(mutableSet.copy(), forKey: relationship.name)
            
            reloadTableView()
            
        default: break
        }
    }
    
    override func addButtonPressed(sender: UIBarButtonItem) {
        
        let object = NSEntityDescription.insertNewObjectForEntityForName(relationship.entity.name!, inManagedObjectContext: context)
        
        let mutableSet = mutableRelationshipSet()
        
        mutableSet.addObject(object)
        
        sourceObject.setValue(mutableSet.copy(), forKey: relationship.name)
        
        reloadTableView()
    }
    
    func mutableRelationshipSet() -> NSMutableSet {
        
        if let relationshipSet = sourceObject.valueForKey(relationship.name) as? NSSet {
            
            return relationshipSet.mutableCopy() as! NSMutableSet
            
        } else {
            
            return NSMutableSet()
        }
    }
}