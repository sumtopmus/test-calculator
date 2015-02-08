//
//  ViewController.swift
//  Calculator
//
//  Created by The Conqueror on 07.02.15.
//  Copyright (c) 2015 The Conqueror. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var isTypingANumber: Bool = false
    
    @IBOutlet weak var display: UILabel!
    @IBAction func digit(sender: UIButton) {
        let digit = sender.currentTitle!
        if (!isTypingANumber) {
            isTypingANumber = true
            display.text = digit
        } else {
            display.text = display.text! + digit
        }
    }
}