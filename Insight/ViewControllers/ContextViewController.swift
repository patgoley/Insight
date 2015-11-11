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
        
        do {
            
            _ = UINib(nibName: nibName, bundle: bundle)
            
            super.init(nibName: nibName, bundle: bundle)
            
        } catch {
            
            super.init(nibName: nil, bundle: nil)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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