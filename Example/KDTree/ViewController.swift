//
//  ViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/28/2016.
//  Copyright (c) 2016 Konrad Feiler. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Applications"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissPresentedViewController(_ sender: UIControl) {
        dismiss(animated: true, completion: nil)
    }
}
