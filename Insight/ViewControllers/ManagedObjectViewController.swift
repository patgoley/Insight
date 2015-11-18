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
    
    init(object: NSManagedObject, context: NSManagedObjectContext) {
        
        self.object = object
        
        super.init(context: context)
        
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
        
        let editViewController = EditManagedObjectViewController(object: object, context: context)
        
        let navController = UINavigationController(rootViewController: editViewController)
        
        presentViewController(navController, animated: true, completion: nil)
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
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(DetailLabelTableViewCell.reuseId(), forIndexPath: indexPath) as! DetailLabelTableViewCell
        
        let rowObject = objectsForSection(indexPath.section)[indexPath.row]
        
        let titleString: String
        let detailString: String
        
        switch rowObject {
            
        case let attr as NSAttributeDescription:
            
            titleString = attr.name
            
            let value = object.valueForKey(attr.name)
            
            detailString = valueString(value, forAttribute: attr)
            
        case let rel as NSRelationshipDescription:
            
            titleString = rel.name
            
            switch object.valueForKey(rel.name) {
                
            case let relatedCollection as NSSet:
                
                detailString = "\(relatedCollection.count) objects"
                
            case let relatedObject as NSManagedObject:
                
                detailString = relatedObject.insightDescription
                
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
    
    private func valueString(aValue: AnyObject?, forAttribute attribute: NSAttributeDescription) -> String {
        
        guard let value = aValue else {
            
            return "null"
        }
        
        if let boolNumber = value as? NSNumber where attribute.attributeType == .BooleanAttributeType {
            
            return boolNumber.boolValue ? "true" : "false"
        }
        
        return "\(value)"
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
                    
                    let objectViewController = ManagedObjectViewController(object: relatedObject, context: context)
                    
                    navigationController?.pushViewController(objectViewController, animated: true)
                }
            }
            
        default:
            
            break
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
    
    func objectsForSection(section: Int) -> [AnyObject] {
        
        return section == 0 ? attributes : relationships
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