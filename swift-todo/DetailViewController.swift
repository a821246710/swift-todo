//
//  DetailViewController.swift
//  swift-todo
//
//  Created by Joey on 8/18/16.
//  Copyright © 2016 Oursky Ltd. All rights reserved.
//

import UIKit
import SKYKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem as? SKYRecord {
            if let label = self.detailDescriptionLabel {
                label.text = detail.objectForKey("title") as? String
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func edit(sender: AnyObject) {
        let alertController = UIAlertController(title: "Edit title", message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { (action) in
            let title = alertController.textFields![0].text
            let todo = self.detailItem as! SKYRecord
            todo.setObject(title!, forKey: "title")
            
            SKYContainer.defaultContainer().privateCloudDatabase.saveRecord(todo, completion: { (record, error) in
                if (error != nil) {
                    print("error saving todo: \(error)")
                    return
                }
                
                self.detailDescriptionLabel.text = todo.objectForKey("title") as? String
            })
        }))
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            let todo = self.detailItem as! SKYRecord
            textField.placeholder = "Title"
            textField.text = todo.objectForKey("title") as? String
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

