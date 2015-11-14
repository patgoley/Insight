//
//  EditManagedObjectViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/13/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

class EditManagedObjectViewController: ManagedObjectViewController {
    
    override func nibsForReuseIds() -> [String : UINib] {
        
        return [NumberFieldTableViewCell.reuseId() : NumberFieldTableViewCell.nib(),
                TextFieldTableViewCell.reuseId() : TextFieldTableViewCell.nib(),
                DateFieldTableViewCell.reuseId() : DateFieldTableViewCell.nib(),
                BooleanFieldTableViewCell.reuseId() : BooleanFieldTableViewCell.nib()]
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
        
        numberField.text = value != nil ? value!.description : "null"
    }
    
    func currentValue() -> ValueType? {
        
        if let text = numberField.text {
            
            return formatter.numberFromString(text)!
        }
        
        return 0 as NSNumber
    }
}

class TextFieldTableViewCell: UITableViewCell, AttributeCell {
    
    typealias ValueType = String
    
    @IBOutlet weak var textField: UITextField!
    
    func update(value: ValueType?, attribute: NSAttributeDescription) {
        
        textField.text = value ?? "null"
    }
    
    func currentValue() -> ValueType? {
        
        return textField.text ?? ""
    }
}

class DateFieldTableViewCell: UITableViewCell, AttributeCell {
    
    @IBOutlet weak var dateField: UILabel!
    
    typealias ValueType = NSDate
    
    static let formatter: NSDateFormatter = {
        
        let df = NSDateFormatter()
        
        df.dateStyle = .LongStyle
        
        return df
    }()
    
    func update(value: ValueType?, attribute: NSAttributeDescription) {
        
        if let date = value {
            
            dateField.text = DateFieldTableViewCell.formatter.stringFromDate(date)
            
        } else {
            
            dateField.text = "null"
        }
    }
    
    func currentValue() -> ValueType? {
        
        if let text = dateField.text {
            
            return DateFieldTableViewCell.formatter.dateFromString(text)
        }
        
        return nil
    }
}

class BooleanFieldTableViewCell: UITableViewCell, AttributeCell {
    
    typealias ValueType = Bool
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    func update(value: ValueType?, attribute: NSAttributeDescription) {
        
        nameLabel.text = attribute.name
        
        if let toggleValue = value {
            
            toggleSwitch.on = toggleValue
            
        } else {
            
            toggleSwitch.on = false
        }
    }
    
    func currentValue() -> ValueType? {
        
        return toggleSwitch.on
    }
}