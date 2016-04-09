//
//  ViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/28/2016.
//  Copyright (c) 2016 Konrad Feiler. All rights reserved.
//

import UIKit

extension CGFloat {
    static func random(start start: CGFloat = 0.0, end: CGFloat = 1.0) -> CGFloat {
        return (end-start)*CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + start
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        var arr = Array<String>()
//        
//        arr.reduce(0) { $0 + $1.characters.count }
        
        let _ = Dictionary<String, String>()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissPresentedViewController(sender: UIControl) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
