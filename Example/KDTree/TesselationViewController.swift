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
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(TesselationViewController.illustrationTapped(_:)))
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
 
    @objc func illustrationTapped(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)
        fillFormView.tapped(point)
    }
    
    @IBAction func shapeChanged(_ sender: UISegmentedControl) {
        fillFormView.chosenShape = sender.selectedSegmentIndex == 0 ? .circle : .square
    }
    
}
