//
//  SplitViewController.swift
//  swift-todo
//
//  Created by Joey on 8/18/16.
//  Copyright © 2016 Oursky Ltd. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
    override func viewDidAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if !appDelegate.loggedin {
            let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
            self.presentViewController(loginView, animated: true, completion: nil)
        }
    }
}
