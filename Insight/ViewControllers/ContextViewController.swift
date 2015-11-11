//
//  ContextViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class ContextViewController : UITableViewController {
    
    let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        
        self.context = context
        
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let nibName = "\(self.dynamicType)"
        
        if let _ = bundle.URLForResource(nibName, withExtension: "nib") {
            
            super.init(nibName: nibName, bundle: bundle)
            
        } else {
            
            super.init(nibName: nil, bundle: nil)
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        
        fatalError()
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        registerReusableViews()
    }
    
    public override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        reloadData()
        
        tableView.reloadData()
    }
    
    func registerReusableViews() {
        
        let nibMap = nibsForReuseIds()
        
        for (reuseId, nib) in nibMap {
            
            tableView.registerNib(nib, forCellReuseIdentifier: reuseId)
        }
    }
    
    func nibsForReuseIds() -> [String : UINib] {
    
        return [DetailLabelTableViewCell.reuseId() : DetailLabelTableViewCell.nib()]
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func reloadData() {
        
        fatalError("must be overriden in subclass")
    }
}