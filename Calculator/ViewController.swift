//
//  ViewController.swift
//  Calculator
//
//  Created by The Conqueror on 07.02.15.
//  Copyright (c) 2015 The Conqueror. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {

    private var isTypingANumber = false
	private var hasDot = false
	private var dotJustAdded = false
	private var stackDisplayInitialized = false

	private let piString = NSString(format: "%.5f", M_PI)

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
			isTypingANumber = true
			hasDot = true
			dotJustAdded = true
		}
	}

	@IBAction func pi() {
		isTypingANumber = true
		displayValue = M_PI
		enter()
	}

    @IBAction func enter() {
//		if isTypingANumber {
		operandStack.append(displayValue)

		var stringToAppend: String = "\(displayValue)"
		if stringToAppend == piString {
			stringToAppend = "π"
		}

		if !stackDisplayInitialized {
			stack.text = stringToAppend
			stackDisplayInitialized = true
		} else {
			stack.text = stack.text! + " " + stringToAppend
		}

		isTypingANumber = false
		hasDot = false
		dotJustAdded = false
//		}
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
		if !stackDisplayInitialized {
			stack.text = "\(operation)"
			stackDisplayInitialized = true
		} else {
			stack.text = stack.text! + " \(operation)"
		}

		switch operation {
		case "+": performBinaryOperation{$1 + $0}
		case "−": performBinaryOperation{$1 - $0}
		case "×": performBinaryOperation{$1 * $0}
		case "÷": performBinaryOperation{$1 / $0}
		case "sin": performUnaryOperation(sin)
		case "cos": performUnaryOperation(cos)
		case "√": performUnaryOperation(sqrt)
		default: println("Wrong operation!")
		}
	}

	func performBinaryOperation(operation: (Double, Double) -> Double) {
		if operandStack.count >= 2 {
//			TODO: resolve strange behaviour
//			isTypingANumber = true
			displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
			operandStack.append(displayValue)
		}
	}

	func performUnaryOperation(operation: (Double) -> Double) {
		if operandStack.count >= 1 {
//			TODO: resolve strange behaviour
//			isTypingANumber = true
			displayValue = operation(operandStack.removeLast())
			operandStack.append(displayValue)
		}
	}

    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
//            isTypingANumber = false
            display.text = NSString(format: "%.5f", newValue)
        }
    }
}