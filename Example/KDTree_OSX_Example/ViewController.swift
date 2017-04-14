//
//  ViewController.swift
//  KDTree_OSX_Example
//
//  Created by Konrad Feiler on 03/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var tesselationView: FillWithFormsView!
    @IBOutlet weak var clickGestureRecognizer: NSClickGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func illustrationTapped(_ recognizer: NSClickGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)
        tesselationView.tapped(point)
    }

}
