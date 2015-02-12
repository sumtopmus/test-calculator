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
	private var equalitySignIsDisplayed = false

    private var operandStack = Array<Double>()
    
    @IBOutlet weak var display: UILabel!

	@IBOutlet weak var stack: UILabel!

    @IBAction func digit(sender: UIButton) {
		removeEquality()
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
		removeEquality()
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
		operandStack.append(displayValue!)
		appendOpAndDisplay("\(displayValue!)")

		isTypingANumber = false
		hasDot = false
		dotJustAdded = false

		println(operandStack)
    }
    
	@IBAction func backspace() {
		removeEquality()
		if isTypingANumber {
			display.text = dropLast(display.text!)
			if 0 == countElements(display.text!) {
				display.text = "0"
				isTypingANumber = false
			}
		}
	}

	@IBAction func clear() {
		isTypingANumber = false
		hasDot = false
		dotJustAdded = false
		stackDisplayInitialized = false
		equalitySignIsDisplayed = false

		display.text = "0"
		stack.text = "0"

		operandStack.removeAll(keepCapacity: false)
	}

    @IBAction func operate(sender: UIButton) {
		removeEquality()
		let operation = sender.currentTitle!
		if isTypingANumber {
			if "±" == operation {
				display.text = "-" + display.text!
				return
			} else {
				enter()
			}
		}
		appendOpAndDisplay(operation)
		stack.text = stack.text! + " ="
		equalitySignIsDisplayed = true

		switch operation {
		case "+": performBinaryOperation{$1 + $0}
		case "−": performBinaryOperation{$1 - $0}
		case "×": performBinaryOperation{$1 * $0}
		case "÷": performBinaryOperation{$1 / $0}
		case "sin": performUnaryOperation(sin)
		case "cos": performUnaryOperation(cos)
		case "√": performUnaryOperation(sqrt)
		case "±": performUnaryOperation{-$0}
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

	func removeEquality() {
		if equalitySignIsDisplayed {
			stack.text = dropLast(stack.text!)
			equalitySignIsDisplayed = false
			stack.text = dropLast(stack.text!)
		}
	}

	func performBinaryOperation(operation: (Double, Double) -> Double) {
		if operandStack.count >= 2 {
			displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
			if let value = displayValue {
				operandStack.append(value)
			}
		}
	}

	func performUnaryOperation(operation: (Double) -> Double) {
		if operandStack.count >= 1 {
			displayValue = operation(operandStack.removeLast())
			operandStack.append(displayValue!)
		}
	}

	func performPrintOperation(value: Double) {
		displayValue = value
		operandStack.append(value)
	}

    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
			if let value = newValue {
				if Double.infinity != value {
					display.text = NSString(format: "%.5f", value)
				} else {
					clear()
					display.text = "inf"
				}
			} else {
				clear()
				display.text = nil
			}
        }
    }
}