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
        case Constant(String, Double)
        case Variable(String)
		case UnaryOperation(String, (Double) -> Double)
		case BinaryOperation(String, (Double, Double) -> Double)
	}

    private var knownOps = [String:Op]()

    private var constantValues = [String:Double]()

    var variableValues = [String:Double]()

	private var opStack = [Op]()

    var description: String {
        get {
            var oneExpression = evaluateLastExpressionDescription(opStack)
            var result = oneExpression.result
            var currentOpStack = oneExpression.remainingOps
            while (!currentOpStack.isEmpty) {
                oneExpression = evaluateLastExpressionDescription(currentOpStack)
                result = oneExpression.result + ", " + result
                currentOpStack = oneExpression.remainingOps
            }
            return result
        }
    }

	init() {
		knownOps["+"] = .BinaryOperation("+", +)
		knownOps["−"] = .BinaryOperation("−", {$1 - $0})
		knownOps["×"] = .BinaryOperation("×", *)
		knownOps["÷"] = .BinaryOperation("÷", {$1 / $0})
		knownOps["√"] = .UnaryOperation("√", sqrt)
		knownOps["sin"] = .UnaryOperation("sin", sin)
		knownOps["cos"] = .UnaryOperation("cos", cos)
		knownOps["±"] = .UnaryOperation("-", {-$0})
        knownOps["π"] = .Constant("π", M_PI)
    }

    private func evaluateLastExpressionDescription(ops: [Op]) -> (result: String, numberOfOperands: Int, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", 1, remainingOps)
            case .Constant(let constant, let value):
                return (constant, 1, remainingOps)
            case .Variable(let variable):
                return (variable, 1, remainingOps)
            case .UnaryOperation(let operationSymbol, let operation):
                let operandDescriptionEvaluation = evaluateLastExpressionDescription(remainingOps)
                return (operationSymbol + "(" + operandDescriptionEvaluation.result + ")", 1, operandDescriptionEvaluation.remainingOps)
            case .BinaryOperation(let operationSymbol, let operation):
                let operand1Evaluation = evaluateLastExpressionDescription(remainingOps)
                let operand2Evaluation = evaluateLastExpressionDescription(operand1Evaluation.remainingOps)

                var auxiliaryResult: String
                if ("" != operand2Evaluation.result) {
                    auxiliaryResult = operand2Evaluation.result
                } else {
                    auxiliaryResult = "?"
                }
                var result = ""
                if (operand2Evaluation.numberOfOperands > 1) {
                    result = "(" + auxiliaryResult + ")"
                } else {
                    result = auxiliaryResult
                }

                result += operationSymbol

                if ("" != operand1Evaluation.result) {
                    auxiliaryResult = operand1Evaluation.result
                } else {
                    auxiliaryResult = "?"
                }
                if (operand1Evaluation.numberOfOperands > 1) {
                    result += "(" + auxiliaryResult + ")"
                } else {
                    result += auxiliaryResult
                }
                return (result, 2, operand2Evaluation.remainingOps)
            }
        }
        
        return ("", 0, ops)
    }

	private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
		if !ops.isEmpty {
			var remainingOps = ops
			let op = remainingOps.removeLast()
			switch op {
			case .Operand(let operand):
				return (operand, remainingOps)
            case .Constant(let constant, let value):
                return (value, remainingOps)
            case .Variable(let variable):
                return (variableValues[variable], remainingOps)
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

    func pushOperand(symbol: String) -> Double? {
        if let value = knownOps[symbol] {
            opStack.append(value)
        } else {
            opStack.append(.Variable(symbol))
        }
        return evaluate()
    }

	func performOperation(symbol: String) -> Double? {
		if let operation = knownOps[symbol] {
			opStack.append(operation)
		}
		return evaluate()
	}

    func clear() {
        clearStack()
        clearVariables()
    }

    func clearStack() {
        opStack.removeAll(keepCapacity: false)
    }

    func clearVariables() {
        variableValues.removeAll(keepCapacity: false)
    }
}