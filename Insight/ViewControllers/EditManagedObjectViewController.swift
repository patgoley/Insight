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
    
    override init(object: NSManagedObject, context: NSManagedObjectContext) {
        
        let privateMainQueueContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        privateMainQueueContext.parentContext = context
        
        let newContextObject = privateMainQueueContext.objectWithID(object.objectID)
        
        super.init(object: newContextObject, context: privateMainQueueContext)
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: Selector("donePressed"))
        
        self.navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancelPressed"))
        
        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    func donePressed() {
        
        try! context.save()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelPressed() {
        
        context.reset()
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func cellTypes() -> [UITableViewCell.Type] {
        
        return [NumberFieldTableViewCell.self,
                TextFieldTableViewCell.self,
                DateFieldTableViewCell.self,
                BooleanFieldTableViewCell.self,
                DetailLabelTableViewCell.self]
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch objectAtIndexPath(indexPath) {
            
        case let .First(attr):
            
            return cellForAttribute(attr, atIndexPath: indexPath, inTableView: tableView)
            
        default:
            
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    func cellForAttribute(attribute: NSAttributeDescription, atIndexPath indexPath: NSIndexPath, inTableView: UITableView) -> UITableViewCell {
        
        switch attribute.attributeType {
            
        case .Integer16AttributeType: fallthrough
        case .Integer32AttributeType: fallthrough
        case .Integer64AttributeType: fallthrough
        case .FloatAttributeType: fallthrough
        case .DoubleAttributeType:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NumberFieldTableViewCell.reuseId(), forIndexPath: indexPath) as! NumberFieldTableViewCell
            
            let value = object.valueForKey(attribute.name) as? NSNumber
            
            cell.update(value, attribute: attribute)
            
            return cell
            
        case .StringAttributeType:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(TextFieldTableViewCell.reuseId(), forIndexPath: indexPath) as! TextFieldTableViewCell
            
            let value = object.valueForKey(attribute.name) as? String
            
            cell.update(value, attribute: attribute)
            
            return cell
            
        case .DateAttributeType:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(DateFieldTableViewCell.reuseId(), forIndexPath: indexPath) as! DateFieldTableViewCell
            
            let value = object.valueForKey(attribute.name) as? NSDate
            
            cell.update(value, attribute: attribute)
            
            return cell
            
        case .BooleanAttributeType:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(BooleanFieldTableViewCell.reuseId(), forIndexPath: indexPath) as! BooleanFieldTableViewCell
            
            let value = object.valueForKey(attribute.name) as? Bool
            
            cell.update(value, attribute: attribute)
            
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(TextFieldTableViewCell.reuseId(), forIndexPath: indexPath) as! TextFieldTableViewCell
            
            if let value = object.valueForKey(attribute.name) {
                
                cell.update(value.description, attribute: attribute)
                
            } else {
                
                cell.update("null", attribute: attribute)
            }
            
            return cell
        }
    }
}

protocol AttributeCell {
    
    typealias ValueType
    
    func update(value: ValueType?, attribute: NSAttributeDescription)
    
    func currentValue() -> ValueType?
}

class NumberFieldTableViewCell : UITableViewCell, AttributeCell {
    
    typealias ValueType = NSNumber
    
    @IBOutlet weak var numberField: UITextField!
    
    let formatter = NSNumberFormatter()
    
    func update(value: ValueType?, attribute: NSAttributeDescription) {
        
        numberField.text = value.map({ $0.description })
    }
    
    func currentValue() -> ValueType? {
        
        return numberField.text.map({ formatter.numberFromString($0)! })
    }
}

class TextFieldTableViewCell: UITableViewCell, AttributeCell {
    
    typealias ValueType = String
    
    @IBOutlet weak var textField: UITextField!
    
    func update(value: ValueType?, attribute: NSAttributeDescription) {
        
        textField.text = value
    }
    
    func currentValue() -> ValueType? {
        
        return textField.text
    }
}

class DateFieldTableViewCell: UITableViewCell, AttributeCell {
    
    typealias ValueType = NSDate
    
    @IBOutlet weak var dateField: UILabel!
    
    static let formatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        
        formatter.dateStyle = .LongStyle
        
        return formatter
    }()
    
    func update(value: ValueType?, attribute: NSAttributeDescription) {
        
        dateField.text = value.map({ DateFieldTableViewCell.formatter.stringFromDate($0) })
    }
    
    func currentValue() -> ValueType? {
        
        return dateField.text.map({ DateFieldTableViewCell.formatter.dateFromString($0)! })
    }
}

class BooleanFieldTableViewCell: UITableViewCell, AttributeCell {
    
    typealias ValueType = Bool
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    func update(value: ValueType?, attribute: NSAttributeDescription) {
        
        nameLabel.text = attribute.name
        
        toggleSwitch.on = value ?? false
    }
    
    func currentValue() -> ValueType? {
        
        return toggleSwitch.on
    }
}