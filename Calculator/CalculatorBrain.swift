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
		case Operand(Double, Int)
        case Constant(String, Double, Int)
        case Variable(String, Int)
		case UnaryOperation(String, (Double) -> Double, Int)
        case BinaryOperation(String, (Double, Double) -> Double, Int)

        static let maxPriority = 0
	}

    private var knownOps = [String:Op]()

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
        knownOps["+"] = .BinaryOperation("+", +, 3)
		knownOps["−"] = .BinaryOperation("−", {$1 - $0}, 3)
		knownOps["×"] = .BinaryOperation("×", *, 2)
        knownOps["÷"] = .BinaryOperation("÷", {$1 / $0}, 2)
        knownOps["√"] = .UnaryOperation("√", sqrt, 1)
		knownOps["sin"] = .UnaryOperation("sin", sin, 1)
		knownOps["cos"] = .UnaryOperation("cos", cos, 1)
        knownOps["±"] = .UnaryOperation("-", {-$0}, Op.maxPriority)
        knownOps["π"] = .Constant("π", M_PI, Op.maxPriority)
    }

    private func evaluateLastExpressionDescription(ops: [Op]) -> (result: String, numberOfOperands: Int, priority: Int, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand, let priority):
                return ("\(operand)", 1, priority, remainingOps)
            case .Constant(let constant, let value, let priority):
                return (constant, 1, priority, remainingOps)
            case .Variable(let variable, let priority):
                return (variable, 1, priority, remainingOps)
            case .UnaryOperation(let operationSymbol, let operation, let priority):
                let operandDescriptionEvaluation = evaluateLastExpressionDescription(remainingOps)
                let numberOfOperands = Op.maxPriority == priority ? 2 : 1
                var result = operandDescriptionEvaluation.result
                if (priority > Op.maxPriority || operandDescriptionEvaluation.numberOfOperands > 1) {
                    result = "(" + result + ")"
                }
                return (operationSymbol + result, numberOfOperands, priority, operandDescriptionEvaluation.remainingOps)
            case .BinaryOperation(let operationSymbol, let operation, let priority):
                let operand1Evaluation = evaluateLastExpressionDescription(remainingOps)
                let operand2Evaluation = evaluateLastExpressionDescription(operand1Evaluation.remainingOps)

                var auxiliaryResult: String
                if ("" != operand2Evaluation.result) {
                    auxiliaryResult = operand2Evaluation.result
                } else {
                    auxiliaryResult = "?"
                }
                var result = ""
                if (operand2Evaluation.numberOfOperands > 1 && operand2Evaluation.priority > priority) {
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
                if (operand1Evaluation.numberOfOperands > 1 && operand1Evaluation.priority > priority) {
                    result += "(" + auxiliaryResult + ")"
                } else {
                    result += auxiliaryResult
                }
                return (result, 2, priority, operand2Evaluation.remainingOps)
            }
        }
        
        return ("", 0, Op.maxPriority, ops)
    }

    private func evaluate(ops: [Op]) -> (result: Double?, error: String?, remainingOps: [Op]) {
        var result: Double? = nil
        var error: String? = nil
        var remainingOps = ops

        if !ops.isEmpty {
			let op = remainingOps.removeLast()
			switch op {
			case .Operand(let operand, _):
				result = operand
            case .Constant(let constant, let value, _):
                result = value
            case .Variable(let variable, _):
                result = variableValues[variable]
                if (nil == result) {
                    error = "The variable \(variable) is not set"
                }
            case .UnaryOperation(let operationSymbol, let operation, _):
				let operandEvaluation = evaluate(remainingOps)
				if let operand = operandEvaluation.result {
                    result = operation(operand)
                    if (!result!.isFinite) {
                        error = "Cannot evaluate \(operationSymbol)(\(operand))"
                    }
                    remainingOps = operandEvaluation.remainingOps
                } else {
                    error = operandEvaluation.error
                }
			case .BinaryOperation(let operationSymbol, let operation, _):
				let operand1Evaluation = evaluate(remainingOps)
				if let operand1 = operand1Evaluation.result {
					let operand2Evaluation = evaluate(operand1Evaluation.remainingOps)
					if let operand2 = operand2Evaluation.result {
                        result = operation(operand1, operand2)
                        if (!result!.isFinite) {
                            error = "Cannot evaluate \(operand2)\(operationSymbol)\(operand1)"
                        }
                        remainingOps = operand2Evaluation.remainingOps
                    } else {
                        error = operand2Evaluation.error
                    }
                } else {
                    error = operand1Evaluation.error
                }
			}
        } else {
            error = "Some operands are missing"
        }

		return (result, error, remainingOps)
	}

	func evaluate() -> Double? {
		return evaluate(opStack).result
	}

    func evaluateAndReportErrors() -> String {
        let result = evaluate(opStack)
        if let error = result.error {
            return error
        }
        return "\(result.result!)"
    }

    func pushOperand(operand: Double) -> String {
        opStack.append(.Operand(operand, Op.maxPriority))
        return evaluateAndReportErrors()
    }

    func pushOperand(symbol: String) -> String {
        if let value = knownOps[symbol] {
            opStack.append(value)
        } else {
            opStack.append(.Variable(symbol, Op.maxPriority))
        }
        return evaluateAndReportErrors()
    }

    func performOperation(symbol: String) -> String {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluateAndReportErrors()
    }

    func undoLastOp() {
        opStack.removeLast()
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