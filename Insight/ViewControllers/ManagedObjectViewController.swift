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
    
    let object: NSManagedObject
    
    var attributes = [NSAttributeDescription]()
    
    var relationships = [NSRelationshipDescription]()
    
    required public init(object: NSManagedObject) {
        
        self.object = object
        
        super.init(context: object.managedObjectContext!)
        
        self.title = object.insightDescription
    }

    public required init?(coder aDecoder: NSCoder) {
        
        fatalError()
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editPressed"))
        
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    func editPressed() {
        
        let editViewController = EditManagedObjectViewController(object: object)
        
        presentNavigationController(withRoot: editViewController)
    }
    
    override func reloadData() {
        
        context.refreshObject(object, mergeChanges: true)
        
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
    
    func objectsForSection(section: Int) -> [AnyObject] {
        
        return section == 0 ? attributes : relationships
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(DetailLabelTableViewCell.reuseId(), forIndexPath: indexPath) as! DetailLabelTableViewCell
        
        let titleString: String
        let detailString: String
        
        switch objectAtIndexPath(indexPath) {
            
        case let .First(attribute):
            
            titleString = attribute.name
            
            detailString = attributeDetailString(attribute)
            
        case let .Second(relationship):
            
            titleString = relationship.name
            
            detailString = relationshipDetailString(relationship)
        }
        
        cell.update(mainText: titleString, detailText: detailString)
        
        return cell
    }
    
    private func attributeDetailString(attribute: NSAttributeDescription) -> String {
        
        guard let value = object.valueForKey(attribute.name) else {
            
            return "null"
        }
        
        if let boolNumber = value as? NSNumber where attribute.attributeType == .BooleanAttributeType {
            
            return boolNumber.boolValue ? "true" : "false"
        }
        
        return "\(value)"
    }
    
    private func relationshipDetailString(relationship: NSRelationshipDescription) -> String {
        
        if relationship.toMany {
            
            let relatedSet = object.objectsInRelationship(relationship)
            
            return relatedSet.count == 1 ? "1 object" : "\(relatedSet.count) objects"
            
        } else {
            
            if let object = object.objectForRelationship(relationship) {
                
                return object.insightDescription
                
            } else {
                
                return "null"
            }
        }
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedObject = objectAtIndexPath(indexPath)
        
        switch selectedObject {
            
        case let .Second(rel):
            
            if rel.toMany {
                
                let relationshipViewController = RelationshipViewController(sourceObject: object, relationship: rel, context: context)
                
                navigationController?.pushViewController(relationshipViewController, animated: true)
                
            } else {
                
                if let relatedObject = object.objectForRelationship(rel) {
                    
                    let objectViewController = ManagedObjectViewController(object: relatedObject)
                    
                    navigationController?.pushViewController(objectViewController, animated: true)
                    
                } else {
                    
                    promptToAddToRelatedObject(rel)
                }
            }
            
        default:
            
            break
        }
    }
    
    func promptToAddToRelatedObject(relationship: NSRelationshipDescription) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Add New", style: .Default, handler: { (_) -> Void in
            
            self.insertNewRelatedObject(relationship)
        }))
        
        alert.addAction(UIAlertAction(title: "Link Existing", style: .Default, handler: { (_) -> Void in
            
            self.linkExistingObject(relationship)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func insertNewRelatedObject(relationship: NSRelationshipDescription) {
        
        let createObjectViewController = EditManagedObjectViewController(newObjectForRelationship: relationship, sourceObject: object)
        
        startModalSelection(createObjectViewController) { (object: NSManagedObject?) in
            
            if object != nil {
                
                self.reloadTableView()
            }
        }
    }
    
    func linkExistingObject(relationship: NSRelationshipDescription) {
        
        let fetchRequestViewController = FetchRequestViewController(context: context, entity: relationship.destinationEntity!)
        
        startModalSelection(fetchRequestViewController) { (object: NSManagedObject?) in
            
            if object != nil {
                
                self.object.addObject(object!, toRelationship: relationship)
                
                self.reloadTableView()
            }
        }
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> Either<NSAttributeDescription, NSRelationshipDescription> {
        
        switch objectsForSection(indexPath.section)[indexPath.row] {
            
        case let attr as NSAttributeDescription:
            
            return .First(attr)
            
        case let rel as NSRelationshipDescription:
            
            return .Second(rel)
            
        default:
            
            fatalError()
        }
    }
}

enum Either<A, B> {
    
    case First(A), Second(B)
}

extension Dictionary where Key: Comparable {
    
    func objectsBySortedKeyOrder() -> [Value] {
        
        let sortedKeys = self.keys.sort()
        
        return sortedKeys.map( { self[$0]! } )
    }
}