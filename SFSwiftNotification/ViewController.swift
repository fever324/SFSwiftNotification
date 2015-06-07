//
//  ViewController.swift
//  SFSwiftNotification
//
//  Created by Simone Ferrini on 13/07/14.
//  Copyright (c) 2014 sferrini. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SFSwiftNotificationProtocol {
    
    var notifyFrame:CGRect?
    var notifyView:SFSwiftNotification?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        notifyFrame = CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)
        
        notifyView = SFSwiftNotification(title: "hi")
        notifyView?.setTitleColor(UIColor.blackColor())
        self.view.addSubview(notifyView!)
    }
    
    @IBAction func notify(sender : AnyObject) {
        self.notifyView!.show()
    }
    
    func didNotifyFinishedAnimation(results: Bool) {
        
        println("SFSwiftNotification finished animation")
    }
    
    func didTapNotification() {
        
        let tapAlert = UIAlertController(title: "SFSwiftNotification",
            message: "You just tapped the notificatoion",
            preferredStyle: UIAlertControllerStyle.Alert)
        tapAlert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: nil))
        self.presentViewController(tapAlert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

