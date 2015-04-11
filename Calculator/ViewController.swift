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

	private var brain = CalculatorBrain()
    
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

    @IBAction func constant(sender: UIButton) {
        removeEquality()
        let variable = sender.currentTitle!

        if (isTypingANumber) {
            clearDisplayValue()
        }

        displayResult(brain.pushOperand(variable))
    }

    @IBAction func saveToMemory(sender: UIButton) {
        reset()
        if let value = displayValue {
            brain.variableValues["M"] = value
        }
        displayResult(brain.evaluateAndReportErrors())
    }

    @IBAction func getFromMemory(sender: UIButton) {
        enter()
        displayResult(brain.pushOperand(sender.currentTitle!))
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

    @IBAction func operate(sender: UIButton) {
        removeEquality()
        if let operation = sender.currentTitle {
            if isTypingANumber {
                if "±" == operation {
                    if "-" == display.text!.substringToIndex(display.text!.startIndex.successor()) {
                        display.text?.removeAtIndex(display.text!.startIndex)
                    } else {
                        display.text =  "-" + display.text!
                    }
                    return
                } else {
                    enter()
                }
            }
            displayResult(brain.performOperation(operation))
        }
    }

    @IBAction func enter() {
        if (!equalitySignIsDisplayed) {
            reset()
            if let value = displayValue {
                displayResult(brain.pushOperand(value))
            }
        }
    }
    
	@IBAction func backspace() {
        if isTypingANumber {
			display.text = dropLast(display.text!)
			if 0 == count(display.text!) {
				display.text = " "
				isTypingANumber = false
			}
        } else {
            brain.undoLastOp()
            displayResult(brain.evaluateAndReportErrors())
        }
	}

	@IBAction func clear() {
        clearDisplayValue()
        stack.text = " "
        brain.clear()
	}

    private func clearDisplayValue() {
        reset()
        display.text = " "
    }

    private func reset() {
        removeEquality()
        isTypingANumber = false
        hasDot = false
        dotJustAdded = false
    }

    private func removeEquality() {
        if equalitySignIsDisplayed {
            stack.text = dropLast(stack.text!)
            equalitySignIsDisplayed = false
        }
    }

    private func updateStack() {
        var stackText = brain.description
        if let value = displayValue {
            stackText += "="
            equalitySignIsDisplayed = true
        }
        stack.text = stackText
    }

    private func displayResult(result: String) {
        display.text = result
        updateStack()
    }

    private var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if let value = newValue {
                display.text = "\(value)"

            } else {
                clearDisplayValue()
            }
            updateStack()
        }
    }

}