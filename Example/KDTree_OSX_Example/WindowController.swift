//
//  WindowController.swift
//  KDTree
//
//  Created by Konrad Feiler on 28.03.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
    }
    
    @IBAction func starMapTapped(_ sender: Any) {
        print("User tapped star Map")
        
        if let starVC = self.contentViewController as? StarViewController {
            starVC.reloadStars()
        }
    }

    @IBAction func tesselationTapped(_ sender: Any) {
        print("User tapped tesselation")
    }
}
