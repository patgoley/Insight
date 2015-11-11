//
//  EntitiesTableViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class EntitiesTableViewController : ContextViewController {
    
    var entities = [NSEntityDescription]()
    
    var entityCounts = [String : Int]()
    
    override func nibsForReuseIds() -> [String : UINib]? {
        
        return [EntityTableViewCell.reuseId() : EntityTableViewCell.nib()]
    }
    
    override func reloadData() {
        
        entities = context.entities.sort({
            
            return $0.name < $1.name
        })
        
        entityCounts.removeAll()
    }
    
    func countForEntity(entity: NSEntityDescription) -> Int {
        
        if let cachedCount = entityCounts[entity.name!] {
            
            return cachedCount
        }
        
        let request = NSFetchRequest(entityName: entity.name!)
        
        let count = context.countForFetchRequest(request, error: nil)
        
        entityCounts[entity.name!] = count
        
        return count
    } 
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return entities.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(EntityTableViewCell.reuseId(), forIndexPath: indexPath) as! EntityTableViewCell
        
        let entity = entities[indexPath.row]
        
        let count = countForEntity(entity)
        
        cell.update(name: entity.name!, count: count)
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let entity = entities[indexPath.row]
        
        let entityViewController = EntityViewController(context: context, entity: entity)
        
        navigationController?.pushViewController(entityViewController, animated: true)
    }
}

class EntityTableViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    func update(name name: String, count: Int) -> () {
        
        nameLabel.text = name
        
        countLabel.text = String(count)
    }
}