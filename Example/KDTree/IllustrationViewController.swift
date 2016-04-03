//
//  IllustrationViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 01/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

extension CGPoint {
    var shortDecimalDescription: String {
        return String(format: "(%.3f, %.3f)", self.x, self.y)
    }

    static func random() -> CGPoint {
        return CGPoint(x: CGFloat.random(start: -1, end: 1), y: CGFloat.random(start: -1, end: 1))
    }
}

class IllustrationViewController: UIViewController {

    @IBOutlet weak var illustrationView: IllustrationView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var tappedLabel: UILabel!
    @IBOutlet weak var nearestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(IllustrationViewController.illustrationTapped(_:)))
        illustrationView.addGestureRecognizer(tapGR)        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

//MARK: - Navigation
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        illustrationView.isKNearest = sender.selectedSegmentIndex == 1
    }
    
    @IBAction func pointsSliderChanged(sender: UISlider) {
        illustrationView.pointNumber = Int(sender.value)
        pointsLabel.text = "Points: \(illustrationView.pointNumber)"
        
    }
    
    func illustrationTapped(recognizer: UITapGestureRecognizer) {
        let point = recognizer.locationInView(recognizer.view)
        illustrationView.pointTapped(point)
        
        tappedLabel.text = illustrationView.tappedPoint.flatMap({"Tapped: \($0.shortDecimalDescription)"}) ?? "Tapped: nil"
        nearestLabel.text = illustrationView.nearestPoints.first.flatMap({"Nearest: \($0.shortDecimalDescription)"}) ?? "Nearest: nil"
    }
    
}
