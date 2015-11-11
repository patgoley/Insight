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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(DetailLabelTableViewCell.reuseId(), forIndexPath: indexPath) as! DetailLabelTableViewCell
        
        let entity = entities[indexPath.row]
        
        let count = countForEntity(entity)
        
        cell.update(mainText: entity.name!, detailText: "\(count)")
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let entity = entities[indexPath.row]
        
        let entityViewController = FetchRequestViewController(context: context, entity: entity)
        
        navigationController?.pushViewController(entityViewController, animated: true)
    }
}

class DetailLabelTableViewCell : UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    func update(mainText mainText: String, detailText: String) -> () {
        
        mainLabel.text = mainText
        
        detailLabel.text = detailText
    }
}