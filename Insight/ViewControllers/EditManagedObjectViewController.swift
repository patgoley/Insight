//
//  EditManagedObjectViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/13/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

public class EditManagedObjectViewController: ManagedObjectViewController {
    
    var completion: ObjectCompletionBlock?
    
    let originalContext: NSManagedObjectContext
    
    init(newObjectForEntity entity: NSEntityDescription, inContext context: NSManagedObjectContext) {
        
        self.originalContext = context
        
        let privateMainQueueContext = context.privateChildContext()
        
        let object = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
        
        super.init(object: object, context: privateMainQueueContext)
    }
    
    init(object: NSManagedObject) {
        
        self.originalContext = object.managedObjectContext!
        
        let privateMainQueueContext = object.managedObjectContext!.privateChildContext()
        
        let newContextObject = privateMainQueueContext.objectWithID(object.objectID)
        
        super.init(object: newContextObject, context: privateMainQueueContext)
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
        
        try! context.save()
        
        dismissViewControllerAnimated(true) {
            
            if let handler = self.completion {
                
                let objectId = self.object.objectID
                
                let originalContextObject = self.originalContext.objectWithID(objectId)
                
                handler(originalContextObject)
            }
        }
    }
    
    func cancelPressed() {
        
        context.reset()
        
        dismissViewControllerAnimated(true, completion: nil)
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

protocol AttributeCell {
    
    func updateWithValue(value: AnyObject?, forAttribute attribute: NSAttributeDescription)
    
    func currentValue() -> AnyObject?
}

class AttributeFieldTableViewCell : InsightTableViewCell, AttributeCell {
    
    @IBOutlet weak var attributeLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    final func updateWithValue(value: AnyObject?, forAttribute attribute: NSAttributeDescription) {
        
        attributeLabel.text = attribute.name
        
        textField.text = value.map(stringFromValue)
        
        textField.keyboardType = keyboardTypeForAttributeType(attribute.attributeType)
    }
    
    final func currentValue() -> AnyObject? {
        
        return textField.text.map(valueFromString)
    }
    
    func stringFromValue(value: AnyObject) -> String {
        
        return value.description!
    }
    
    func valueFromString(valueString: String) -> AnyObject {
        
        return valueString
    }
    
    private final func keyboardTypeForAttributeType(attributeType: NSAttributeType) -> UIKeyboardType {
        
        switch attributeType {
            
        case .StringAttributeType:
            
            return .ASCIICapable
            
        case .Integer16AttributeType: fallthrough
        case .Integer32AttributeType: fallthrough
        case .Integer64AttributeType:
            
            return .NumberPad
        
        case .DoubleAttributeType: fallthrough
        case .FloatAttributeType:
            
            return .DecimalPad
            
        default:
            
            return .Default
        }
    }
}

class NumberFieldTableViewCell : AttributeFieldTableViewCell {
    
    let formatter = NSNumberFormatter()
    
    override func valueFromString(valueString: String) -> AnyObject {
        
        return formatter.numberFromString(valueString)!
    }
}

class DateFieldTableViewCell: AttributeFieldTableViewCell {
    
    static let formatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        
        formatter.dateStyle = .LongStyle
        
        return formatter
    }()
    
    override func stringFromValue(value: AnyObject) -> String {
        
        return DateFieldTableViewCell.formatter.stringFromDate(value as! NSDate)
    }
    
    override func valueFromString(valueString: String) -> AnyObject {
        
        return DateFieldTableViewCell.formatter.dateFromString(valueString)!
    }
}

class BooleanFieldTableViewCell: InsightTableViewCell, AttributeCell {
    
    @IBOutlet weak var attributeLabel: UILabel!
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    func updateWithValue(value: AnyObject?, forAttribute attribute: NSAttributeDescription) {
        
        attributeLabel.text = attribute.name
        
        if let boolValue = value?.boolValue {
            
            toggleSwitch.on = boolValue
            
        } else {
            
            toggleSwitch.on = false
        }
    }
    
    func currentValue() -> AnyObject? {
        
        return toggleSwitch.on as NSNumber
    }
}