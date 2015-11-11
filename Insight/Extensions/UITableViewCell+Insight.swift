//
//  UITableViewCell+Insight.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    
    static func nib() -> UINib {
        
        return UINib(nibName: "\(self)", bundle: NSBundle(forClass: self))
    }
    
    static func reuseId() -> String {
        
        return "\(self)"
    }
}