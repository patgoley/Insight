//
//  FetchRequestViewController.swift
//  Insight
//
//  Created by Patrick Goley on 11/11/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class FetchRequestViewController : ContextViewController {
    
    let entity: NSEntityDescription
    
    var request: NSFetchRequest
    
    var objects = [NSManagedObject]()
    
    convenience public init(context: NSManagedObjectContext, entity: NSEntityDescription) {
        
        let request = NSFetchRequest(entityName: entity.name!)
        
        self.init(request: request, context: context, entity: entity)
    }
    
    required public init(request: NSFetchRequest, context: NSManagedObjectContext, entity: NSEntityDescription) {
        
        self.entity = entity
        
        self.request = request
        
        super.init(context: context)
    }

    required public init?(coder aDecoder: NSCoder) {
        
        fatalError()
    }
    
    override func nibsForReuseIds() -> [String : UINib] {
        
        return [ModelObjectTableViewCell.reuseId() : ModelObjectTableViewCell.nib()]
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addButtonPressed:"))
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func reloadData() {
        
        objects = try! context.executeFetchRequest(request) as! [NSManagedObject]
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        
        NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
        
        reloadData()
        
        tableView.reloadData()
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return objects.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(ModelObjectTableViewCell.reuseId(), forIndexPath: indexPath) as! ModelObjectTableViewCell
        
        let object = objects[indexPath.row]
        
        cell.updateWithObject(object)
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let object = objects[indexPath.row]
        
        let objectDetailViewController = ManagedObjectViewController(objectId: object.objectID, context: context)
        
        navigationController?.pushViewController(objectDetailViewController, animated: true)
    }
    
    public override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let object = objects[indexPath.row]
        
        switch editingStyle {
            
        case .Delete:
            
            tableView.beginUpdates()
            
            context.deleteObject(object)
            
            reloadData()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            tableView.endUpdates()
            
        default: break
        }
    }
    
    public override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        
        return "Delete"
    }
}

class ModelObjectTableViewCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func updateWithObject(object: NSManagedObject) {
        
        nameLabel.text = "\(object)"
    }
}