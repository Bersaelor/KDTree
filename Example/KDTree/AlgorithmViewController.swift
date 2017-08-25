//
//  AlgorithmViewController.swift
//  KDTree
//
//  Created by Konrad Feiler on 09.04.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class AlgorithmViewController: UIViewController {

    @IBOutlet weak var illustrationView: IllustrationView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var tappedLabel: UILabel!
    @IBOutlet weak var nearestLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        illustrationView.maxStep = -1
        illustrationView.pointNumber = 11

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(AlgorithmViewController.illustrationTapped(_:)))
        view.addGestureRecognizer(tapGR)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pointsSliderChanged(_ sender: UISlider) {
        illustrationView.pointNumber = Int(sender.value)
        pointsLabel.text = "Points: \(illustrationView.pointNumber)"
        
    }
    
    @objc func illustrationTapped(_ recognizer: UITapGestureRecognizer) {
        var currentStep = illustrationView.maxStep ?? 0
        currentStep += 1
        if let maxDepth = illustrationView.treeDepth, currentStep > 2*maxDepth + 2 {
            currentStep = -1
        }
        illustrationView.maxStep = currentStep
        
        arrowImageView.transform = ((currentStep+1)/2) % 2 == 0 ? CGAffineTransform.identity
            : CGAffineTransform(rotationAngle: -0.5*CGFloat.pi)
        
        tappedLabel.text = "step: \(currentStep)"
        nearestLabel.text = currentStep % 2 == 0 ? "Find Median" : "Bisect Plane"
    }

}
