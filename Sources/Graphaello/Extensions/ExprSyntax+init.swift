//
//  ExprSyntax+init.swift
//  
//
//  Created by Mathias Quintero on 12/18/19.
//

import Foundation
import SwiftSyntax

extension IdentifierExprSyntax {

    init(identifier: String) {
        let identifier = SyntaxFactory.makeIdentifier(identifier)
        self = IdentifierExprSyntax { builder in
            builder.useIdentifier(identifier)
        }
    }

}

extension SequenceExprSyntax {

    init(lhs: ExprSyntax, rhs: ExprSyntax, binaryOperator: BinaryOperatorExprSyntax) {
        self = SequenceExprSyntax { builder in
            builder.addElement(lhs)
            builder.addElement(binaryOperator)
            builder.addElement(rhs)
        }
    }

}

extension ArrayExprSyntax {

    init(expressions: [ExprSyntax]) {
        let leftSquare = SyntaxFactory.makeLeftSquareBracketToken()
        let rightSquare = SyntaxFactory.makeRightSquareBracketToken()
        self = ArrayExprSyntax { builder in
            builder.useLeftSquare(leftSquare)
            expressions.forEach { expression, isLast in
                builder.addElement(ArrayElementSyntax(expression: expression,
                                                      useTrailingComma: !isLast))
            }
            builder.useRightSquare(rightSquare)
        }
    }

}

extension BinaryOperatorExprSyntax {

    init(text: String) {
        let token = SyntaxFactory.makeSpacedBinaryOperator(text, leadingTrivia: .spaces(1), trailingTrivia: .spaces(1))
        self = BinaryOperatorExprSyntax { builder in
            builder.useOperatorToken(token)
        }
    }

}


extension ArrayElementSyntax {

    init(expression: ExprSyntax, useTrailingComma: Bool) {
        let comma = SyntaxFactory.makeCommaToken()
        self = ArrayElementSyntax { builder in
            builder.useExpression(expression)
            if useTrailingComma {
                builder.useTrailingComma(comma)
            }
        }
    }

}

extension MemberAccessExprSyntax {

    init(base: ExprSyntax?, name: String) {
        let dot = SyntaxFactory.makePeriodToken()
        let name = SyntaxFactory.makeIdentifier(name)
        self = MemberAccessExprSyntax { builder in
            if let base = base {
                builder.useBase(base)
            }
            builder.useDot(dot)
            builder.useName(name)
        }
    }

}

extension FunctionCallExprSyntax {

    init(target: ExprSyntax, arguments: [(String?, ExprSyntax)]) {
        let leftParen = SyntaxFactory.makeLeftParenToken()
        let rightParen = SyntaxFactory.makeRightParenToken()

        self = FunctionCallExprSyntax { builder in
            builder.useCalledExpression(target)
            builder.useLeftParen(leftParen)
            arguments.forEach { argument, isLast in
                builder.addArgument(FunctionCallArgumentSyntax(name: argument.0,
                                                               value: argument.1,
                                                               useTrailingComma: !isLast))
            }
            builder.useRightParen(rightParen)
        }
    }

}

extension FunctionCallArgumentSyntax {

    init(name: String?, value: ExprSyntax, useTrailingComma: Bool) {
        let comma = SyntaxFactory.makeCommaToken()

        self = FunctionCallArgumentSyntax { builder in
            if let name = name {
                let label = SyntaxFactory.makeIdentifier(name)
                let colon = SyntaxFactory.makeColonToken()

                builder.useLabel(label)
                builder.useColon(colon)
            }

            builder.useExpression(value)
            if useTrailingComma {
                builder.useTrailingComma(comma)
            }
        }
    }

}

extension Collection {

    fileprivate func forEach(_ body: (Element, Bool) throws -> Void) rethrows {
        let lastIndex = index(endIndex, offsetBy: -1)
        try indices.forEach { index in
            try body(self[index], index == lastIndex)
        }
    }

}
