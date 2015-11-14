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
    
    let inverseRelationship: NSRelationshipDescription
    
    public required init(sourceObject: NSManagedObject, relationship: NSRelationshipDescription, context: NSManagedObjectContext) {
        
        self.sourceObject = sourceObject
        
        self.relationship = relationship
        
        self.inverseRelationship = relationship.inverseRelationship!
        
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
            
            sourceObject.removeObject(deletedObject, fromRelationship: relationship)
            
            reloadTableView()
            
        default: break
        }
    }
    
    override func addButtonPressed(sender: UIBarButtonItem) {
        
        let object = NSEntityDescription.insertNewObjectForEntityForName(relationship.destinationEntity!.name!, inManagedObjectContext: context)
        
        sourceObject.addObject(object, toRelationship: relationship)
        
        reloadTableView()
    }
}