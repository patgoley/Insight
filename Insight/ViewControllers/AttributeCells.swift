//
//  AttributeCells.swift
//  Insight
//
//  Created by Patrick Goley on 11/17/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

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