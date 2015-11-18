//
//  InsightTableViewCell.swift
//  Insight
//
//  Created by Patrick Goley on 11/17/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation

protocol ReusableCell {
    
    static func nib() -> UINib
    
    static func reuseId() -> String
}

class InsightTableViewCell : UITableViewCell, ReusableCell {

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    class func nib() -> UINib {
        
        return UINib(nibClass: self)
    }
    
    class func reuseId() -> String {
        
        return "\(self)"
    }
}

extension UINib {
    
    convenience init(nibClass: AnyClass) {
        
        self.init(nibName: "\(nibClass)", bundle: NSBundle(forClass: nibClass))
    }
}