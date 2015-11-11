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
    
    var context: NSManagedObjectContext! = nil
    
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
        
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        registerReusableViews()
        
        reloadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("contextSavedNotification:"), name: NSManagedObjectContextDidSaveNotification, object: context)
    }
    
    func registerReusableViews() {
        
        if let nibMap = nibsForReuseIds() {
            
            for (reuseId, nib) in nibMap {
                
                tableView.registerNib(nib, forCellReuseIdentifier: reuseId)
            }
        }
    } 
    
    func nibsForReuseIds() -> [String : UINib]? {
        
        return nil
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    private func contextSavedNotification(notification: NSNotification, context: NSManagedObjectContext) {
        
        guard context != self.context else {
            
            return
        }
        
        reloadData()
        
        tableView.reloadData()
    }
    
    func reloadData() {
        
        
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}