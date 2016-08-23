//
//  MasterViewController.swift
//  swift-todo
//
//  Created by Joey on 8/18/16.
//  Copyright © 2016 Oursky Ltd. All rights reserved.
//

import UIKit
import SKYKit

class MasterViewController: UITableViewController {
    
    var recordStorage:SKYRecordStorage!

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        
        let query = SKYQuery(recordType: "todo", predicate: nil)
        let coordinator = SKYRecordStorageCoordinator.defaultCoordinator()
        do {
            recordStorage = try coordinator.recordStorageWithDatabase(SKYContainer.defaultContainer().privateCloudDatabase, query: query, options: nil, error: ())
            recordStorage.enabled = true
        } catch {
            print("error occurs")
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(SKYRecordStorageDidUpdateNotification,
                                                                object: recordStorage,
                                                                queue: NSOperationQueue.mainQueue()) { (note) in
                                                                    self.updateData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        
        updateData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        let alertController = UIAlertController(title: "Add To-Do item", message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action) in
            let title = alertController.textFields![0].text
            
            let todo = SKYRecord(recordType: "todo")
            todo.setObject(title!, forKey: "title")
            // FIXME: use SKYSequence
            todo.setObject(SKYSequence(), forKey: "order")
            todo.setObject(false, forKey: "done")
            
            self.recordStorage.saveRecord(todo)
            self.objects.insert(todo, atIndex: 0)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }))
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Title"
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! SKYRecord
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    
    func updateData() {
        self.objects = self.recordStorage.recordsWithType("todo",
                                                          predicate: NSPredicate(format: "done == false"),
                                                          sortDescriptors: [NSSortDescriptor(key: "order", ascending: false)])
        self.tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! SKYRecord
        cell.textLabel!.text = object.objectForKey("title") as? String
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let todo = objects[indexPath.row] as! SKYRecord
            todo.setObject(true, forKey: "done")
            recordStorage.saveRecord(todo)
            self.objects.removeAtIndex(indexPath.row) as! SKYRecord
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

