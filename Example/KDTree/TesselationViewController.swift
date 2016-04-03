//
//  TesselationViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 03/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class TesselationViewController: UIViewController {

    @IBOutlet weak var fillFormView: FillWithFormsView!
    @IBOutlet weak var pointsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(IllustrationViewController.illustrationTapped(_:)))
        fillFormView.addGestureRecognizer(tapGR)
        
        pointsLabel.text = "Shapes: \(fillFormView.points)"
        fillFormView.pointsUpdated = { [weak self] in
            self?.pointsLabel.text = "Shapes: \($0)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func illustrationTapped(recognizer: UITapGestureRecognizer) {
        let point = recognizer.locationInView(recognizer.view)
        fillFormView.pointTapped(point)
        
    }
    
    
    @IBAction func shapeChanged(sender: UISegmentedControl) {
        fillFormView.chosenShape = sender.selectedSegmentIndex == 0 ? .Circle : .Square
    }
    
}
