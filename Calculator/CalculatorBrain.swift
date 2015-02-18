//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by The Conqueror on 11.02.15.
//  Copyright (c) 2015 The Conqueror. All rights reserved.
//

import Foundation

class CalculatorBrain {
	private enum Op {
		case Operand(Double)
		case UnaryOperation(String, (Double) -> Double)
		case BinaryOperation(String, (Double, Double) -> Double)
	}

	private var opStack = [Op]()

	private var knownOps = [String:Op]()

	init() {
		knownOps["+"] = .BinaryOperation("+", +)
		knownOps["−"] = .BinaryOperation("−", {$1 - $0})
		knownOps["×"] = .BinaryOperation("×", *)
		knownOps["÷"] = .BinaryOperation("÷", {$1 / $0})
		knownOps["√"] = .UnaryOperation("√", sqrt)
		knownOps["sin"] = .UnaryOperation("sin", sin)
		knownOps["cos"] = .UnaryOperation("cos", cos)
		knownOps["±"] = .UnaryOperation("±", {-$0})
	}

	private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
		if !ops.isEmpty {
			var remainingOps = ops
			let op = remainingOps.removeLast()
			switch op {
			case .Operand(let operand):
				return (operand, remainingOps)
			case .UnaryOperation(_, let operation):
				let operandEvaluation = evaluate(remainingOps)
				if let operand = operandEvaluation.result {
					return (operation(operand), operandEvaluation.remainingOps)
				}
			case .BinaryOperation(_, let operation):
				let operand1Evaluation = evaluate(remainingOps)
				if let operand1 = operand1Evaluation.result {
					let operand2Evaluation = evaluate(operand1Evaluation.remainingOps)
					if let operand2 = operand2Evaluation.result {
						return (operation(operand1, operand2), operand2Evaluation.remainingOps)
					}
				}
			}
		}

		return (nil, ops)
	}

	func evaluate() -> Double? {
		return evaluate(opStack).result
	}

	func pushOperand(operand: Double) -> Double? {
		opStack.append(.Operand(operand))
		return evaluate()
	}

	func performOperation(symbol: String) -> Double? {
		if let operation = knownOps[symbol] {
			opStack.append(operation)
		}
		return evaluate()
	}
}