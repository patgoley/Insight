//
//  ManagedObjectViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

public class ManagedObjectViewController : ContextViewController {
    
    let objectId: NSManagedObjectID
    
    var object: NSManagedObject!
    
    var attributes = [NSAttributeDescription]()
    
    var relationships = [NSRelationshipDescription]()
    
    init(objectId: NSManagedObjectID, context: NSManagedObjectContext) {
        
        self.objectId = objectId
        
        super.init(context: context)
    }

    public required init?(coder aDecoder: NSCoder) {
        
        fatalError()
    }
    
    override func reloadData() {
        
        object = context.objectWithID(objectId)
        
        context.refreshObject(object, mergeChanges: false)
        
        let attributesByName = object.entity.attributesByName
        
        attributes = attributesByName.objectsBySortedKeyOrder()
        
        let relsByName = object.entity.relationshipsByName
        
        relationships = relsByName.objectsBySortedKeyOrder()
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return objectsForSection(section).count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(DetailLabelTableViewCell.reuseId(), forIndexPath: indexPath) as! DetailLabelTableViewCell
        
        let rowObject = objectsForSection(indexPath.section)[indexPath.row]
        
        let titleString: String
        let detailString: String
        
        switch rowObject {
            
        case let attr as NSAttributeDescription:
            
            titleString = attr.name
            
            if let value = object.valueForKey(attr.name) {
                
                detailString = "\(value)"
                
            } else {
                
                detailString = "null"
            }
            
        case let rel as NSRelationshipDescription:
            
            titleString = rel.name
            
            switch object.valueForKey(rel.name) {
                
            case let relatedCollection as NSSet:
                
                detailString = "\(relatedCollection.count) objects"
                
            case let relatedObject as NSManagedObject:
                
                detailString = "\(relatedObject)"
                
            default:
                
                detailString = rel.toMany ? "0 objects" : "null"
            }
            
        default:
            
            titleString = ""
            detailString = ""
        }
        
        cell.update(mainText: titleString, detailText: detailString)
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedObject = objectsForSection(indexPath.section)[indexPath.row]
        
        switch selectedObject {
            
        case let rel as NSRelationshipDescription:
            
            if rel.toMany {
                
                let relationshipViewController = RelationshipViewController(sourceObject: object, relationship: rel, context: context)
                
                navigationController?.pushViewController(relationshipViewController, animated: true)
                
            } else {
                
                if let relatedObject = object.valueForKey(rel.name) as? NSManagedObject {
                    
                    let objectViewController = ManagedObjectViewController(objectId: relatedObject.objectID, context: context)
                    
                    navigationController?.pushViewController(objectViewController, animated: true)
                }
            }
            
        default:
            
            break
        }
    }
    
    func objectsForSection(section: Int) -> [AnyObject] {
        
        return section == 0 ? attributes : relationships
    }
}

extension Dictionary where Key: Comparable {
    
    func objectsBySortedKeyOrder() -> [Value] {
        
        let sortedKeys = self.keys.sort()
        
        return sortedKeys.map( { return self[$0]! } )
    }
}