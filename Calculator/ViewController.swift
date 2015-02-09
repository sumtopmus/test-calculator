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
	private var hasDot = false
	private var dotJustAdded = false
	private var stackDisplayInitialized = false

    private var operandStack = Array<Double>()
    
    @IBOutlet weak var display: UILabel!

	@IBOutlet weak var stack: UILabel!

    @IBAction func digit(sender: UIButton) {
        let digit = sender.currentTitle!

		if dotJustAdded {
			display.text = display.text! + "."
			dotJustAdded = false
		}

        if (!isTypingANumber) {
            isTypingANumber = true
			display.text = digit
        } else {
            display.text = display.text! + digit
        }
    }
    
	@IBAction func dot() {
		if !hasDot {
			hasDot = true
			dotJustAdded = true
			if !isTypingANumber {
				isTypingANumber = true
				display.text = "0"
			}
		}
	}

    @IBAction func enter() {
		operandStack.append(displayValue)
		appendOpAndDisplay("\(displayValue)")

		isTypingANumber = false
		hasDot = false
		dotJustAdded = false

		println(operandStack)
    }
    
	@IBAction func clear() {
		isTypingANumber = false
		hasDot = false
		dotJustAdded = false
		stackDisplayInitialized = false

		display.text = "0"
		stack.text = "0"

		operandStack.removeAll(keepCapacity: false)
	}

    @IBAction func operate(sender: UIButton) {
		if isTypingANumber {
			enter()
		}
        let operation = sender.currentTitle!
		appendOpAndDisplay(operation)

		switch operation {
		case "+": performBinaryOperation{$1 + $0}
		case "−": performBinaryOperation{$1 - $0}
		case "×": performBinaryOperation{$1 * $0}
		case "÷": performBinaryOperation{$1 / $0}
		case "sin": performUnaryOperation(sin)
		case "cos": performUnaryOperation(cos)
		case "√": performUnaryOperation(sqrt)
		case "π": performPrintOperation(M_PI)
		default: println("Wrong operation!")
		}
	}

	func appendOpAndDisplay(op: String) {
		if !stackDisplayInitialized {
			stack.text = op
			stackDisplayInitialized = true
		} else {
			stack.text = stack.text! + " " + op
		}
	}

	func performBinaryOperation(operation: (Double, Double) -> Double) {
		if operandStack.count >= 2 {
			displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
			operandStack.append(displayValue)
		}
	}

	func performUnaryOperation(operation: (Double) -> Double) {
		if operandStack.count >= 1 {
			displayValue = operation(operandStack.removeLast())
			operandStack.append(displayValue)
		}
	}

	func performPrintOperation(value: Double) {
		displayValue = value
		operandStack.append(value)
	}

    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = NSString(format: "%.5f", newValue)
        }
    }
}