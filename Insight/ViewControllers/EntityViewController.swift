//
//  EntityViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EntityViewController : ContextViewController {
    
    let entity: NSEntityDescription
    
    var objects = [NSManagedObject]()
    
    init(context: NSManagedObjectContext, entity: NSEntityDescription) {
        
        self.entity = entity
        
        super.init(context: context)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func nibsForReuseIds() -> [String : UINib]? {
        
        return [ModelObjectTableViewCell.reuseId() : ModelObjectTableViewCell.nib()]
    }
    
    override func reloadData() {
        
        let request = NSFetchRequest(entityName: entity.name!)
        
        objects = try! context.executeFetchRequest(request) as! [NSManagedObject]
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        
        NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
        
        try! context.save()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ModelObjectTableViewCell.reuseId(), forIndexPath: indexPath) as! ModelObjectTableViewCell
        
        let object = objects[indexPath.row]
        
        cell.updateWithObject(object)
        
        return cell
    }
}

class ModelObjectTableViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func updateWithObject(object: NSManagedObject) {
        
        nameLabel.text = "\(object)"
    }
}