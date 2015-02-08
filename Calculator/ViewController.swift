//
//  ViewController.swift
//  Calculator
//
//  Created by The Conqueror on 07.02.15.
//  Copyright (c) 2015 The Conqueror. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var isTypingANumber = false
    
    private var operandStack = Array<Double>()
    
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
    
    @IBAction func enter() {
//		if isTypingANumber {
			operandStack.append(displayValue)
			isTypingANumber = false
//		}
		println(operandStack)
    }
    
    @IBAction func operate(sender: UIButton) {
		if isTypingANumber {
			enter()
		}
        let operation = sender.currentTitle!
		switch operation {
		case "+": performBinaryOperation{$1 + $0}
		case "−": performBinaryOperation{$1 - $0}
		case "×": performBinaryOperation{$1 * $0}
		case "÷": performBinaryOperation{$1 / $0}
		case "√": performUnaryOperation(sqrt)
		default: println("Wrong operation!")
		}
	}

	func performBinaryOperation(operation: (Double, Double) -> Double) {
		if operandStack.count >= 2 {
//			TODO: resolve strange behaviour
//			isTypingANumber = true
			displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
			enter()
		}
	}

	func performUnaryOperation(operation: (Double) -> Double) {
		if operandStack.count >= 1 {
//			TODO: resolve strange behaviour
//			isTypingANumber = true
			displayValue = operation(operandStack.removeLast())
			enter()
		}
	}

    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
//            isTypingANumber = false
            display.text = "\(newValue)"
        }
    }
}