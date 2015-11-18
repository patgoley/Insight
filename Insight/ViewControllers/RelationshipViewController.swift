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
    
    override func addButtonPressed() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Add New", style: .Default, handler: { (_) -> Void in
            
            self.insertNewRelatedObject()
        }))
        
        alert.addAction(UIAlertAction(title: "Link Existing", style: .Default, handler: { (_) -> Void in
            
            self.linkExistingObject()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func insertNewRelatedObject() {
        
        let createObjectViewController = EditManagedObjectViewController(newObjectForRelationship: relationship, sourceObject: sourceObject)
        
        startModalSelection(createObjectViewController) { (object: NSManagedObject?) in
            
            if object != nil {
                
                self.reloadTableView()
            }
        }
    }
    
    func linkExistingObject() {
        
        let fetchRequestViewController: FetchRequestViewController
        
        if objects.count > 0 {
            
            let request = NSFetchRequest(entityName: entity.name!)
            
            request.predicate = NSPredicate(format: "NOT (SELF IN %@)", objects)
            
            fetchRequestViewController = FetchRequestViewController(request: request, context: context, entity: entity)
            
        } else {
            
            fetchRequestViewController = FetchRequestViewController(context: context, entity: entity)
        }
        
        startModalSelection(fetchRequestViewController) { (object: NSManagedObject?) in
            
            if object != nil {
                
                self.sourceObject.addObject(object!, toRelationship: self.relationship)
                
                self.reloadTableView()
            }
        }
    }
}