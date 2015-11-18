//
//  EditManagedObjectViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/13/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

public class EditManagedObjectViewController: ManagedObjectViewController, ModalSelectionViewController {
    
    var _completion: ObjectCompletionBlock?
    
    var completion: ObjectCompletionBlock? {
        
        get {
            
            return _completion
        }
        
        set {
            
            _completion = newValue
        }
    }
    
    var isNewObject = false
    
    convenience init(newObjectForRelationship relationship: NSRelationshipDescription, sourceObject: NSManagedObject) {
        
        self.init(newObjectForEntity: relationship.destinationEntity!, inContext: sourceObject.managedObjectContext!)
        
        sourceObject.addObject(object, toRelationship: relationship)
    }
    
    convenience init(newObjectForEntity entity: NSEntityDescription, inContext context: NSManagedObjectContext) {
        
        let object = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
        
        self.init(object: object)
        
        self.isNewObject = true
    }
    
    required public init(object: NSManagedObject) {
        
        super.init(object: object)
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("donePressed"))
        
        self.navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelPressed"))
        
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func donePressed() {
        
        for (i, attribute) in objectsForSection(0).enumerate() {
            
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! AttributeCell
            
            let value = cell.currentValue()
            
            object.setValue(value, forKey: attribute.name!)
        }
        
        if completion == nil {
            
            try! context.save()
        }
        
        dismissViewControllerAnimated(true) {
            
            guard let handler = self.completion else {
                
                return
            }
            
            handler(self.object)
        }
    }
    
    func cancelPressed() {
        
        if isNewObject {
            
            context.deleteObject(object)
            
        } else if object.changedValues().count > 0 {
            
            context.refreshObject(object, mergeChanges: false)
        }
        
        dismissViewControllerAnimated(true) {
            
            guard let handler = self.completion else {
                
                return
            }
            
            handler(nil)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func cellTypes() -> [InsightTableViewCell.Type] {
        
        return [AttributeFieldTableViewCell.self,
                NumberFieldTableViewCell.self,
                DateFieldTableViewCell.self,
                BooleanFieldTableViewCell.self,
                DetailLabelTableViewCell.self]
    }
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            let attribute = objectsForSection(0)[indexPath.row] as! NSAttributeDescription
            
            if attribute.attributeType == .BooleanAttributeType {
                
                return 44.0
            }
            
            return 80.0
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch objectAtIndexPath(indexPath) {
            
        case let .First(attribute):
            
            let reuseId = reuseIdForAttributeType(attribute.attributeType)
            
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseId, forIndexPath: indexPath) as! AttributeCell
            
            let value = object.valueForKey(attribute.name)
            
            cell.updateWithValue(value, forAttribute: attribute)
            
            return cell as! UITableViewCell
            
        default:
            
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    func reuseIdForAttributeType(type: NSAttributeType) -> String {
        
        switch type {
            
        case .Integer16AttributeType: fallthrough
        case .Integer32AttributeType: fallthrough
        case .Integer64AttributeType: fallthrough
        case .FloatAttributeType:     fallthrough
        case .DoubleAttributeType:    return NumberFieldTableViewCell.reuseId()
        case .DateAttributeType:      return DateFieldTableViewCell.reuseId()
        case .BooleanAttributeType:   return BooleanFieldTableViewCell.reuseId()
        default:                      return AttributeFieldTableViewCell.reuseId()
        }
    }
}

