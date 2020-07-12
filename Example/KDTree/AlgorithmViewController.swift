//
//  AlgorithmViewController.swift
//  KDTree
//
// Copyright (c) 2020 mathHeartCode UG(haftungsbeschränkt) <konrad@mathheartcode.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
