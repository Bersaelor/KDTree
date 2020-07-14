//
//  TesselationViewController.swift
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
