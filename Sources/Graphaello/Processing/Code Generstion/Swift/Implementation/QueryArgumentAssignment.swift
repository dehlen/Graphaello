//
//  QueryArgumentAssignment.swift
//  Graphaello
//
//  Created by Mathias Quintero on 09.12.19.
//  Copyright © 2019 Mathias Quintero. All rights reserved.
//

import Foundation
import Stencil
import SwiftSyntax

struct QueryArgumentAssignment {
    let name: String
    let expression: ExprSyntax
}

extension QueryArgumentAssignment: ExtraValuesSwiftCodeTransformable {

    func arguments(from context: Stencil.Context, arguments: [Any?]) throws -> [String : Any] {
        return ["expression" : expression.description]
    }

}

extension Struct where CurrentStage: ResolvedStage {
    
    var queryArgumentAssignments: [QueryArgumentAssignment] {
        return query?.queryArgumentAssignments ?? []
    }
    
}

extension GraphQLQuery {
    
    var queryArgumentAssignments: [QueryArgumentAssignment] {
        return arguments.map { QueryArgumentAssignment(name: $0.name,
                                                       expression: $0.assignmentExpression) }
    }
    
}

extension GraphQLConnectionQuery {

    var queryArgumentAssignments: [QueryArgumentAssignment] {
        return query.queryArgumentAssignments.map { assignment in
            if assignment.name == "first" {
                return QueryArgumentAssignment(name: assignment.name,
                                               expression: SequenceExprSyntax(lhs: IdentifierExprSyntax(identifier: "_pageSize"),
                                                                              rhs: assignment.expression,
                                                                              binaryOperator: BinaryOperatorExprSyntax(text: "??")) )
            }
            if assignment.name == "after" {
                return QueryArgumentAssignment(name: assignment.name,
                                               expression: IdentifierExprSyntax(identifier: "_cursor"))
            }
            return assignment
        }
    }

}

extension GraphQLMutation {
    
    var queryArgumentAssignments: [QueryArgumentAssignment] {
        return arguments.map { QueryArgumentAssignment(name: $0.name,
                                                       expression: $0.assignmentExpression) }
    }
    
}

extension GraphQLArgument {

    var assignmentExpression: ExprSyntax {
        if case .value(let expression) = argument {
            return expression
        }

        if type.isScalar {
            return IdentifierExprSyntax(identifier: name.camelized)
        } else {
            return FunctionCallExprSyntax(target: MemberAccessExprSyntax(base: nil, name: "init"),
                                          arguments: [(nil, IdentifierExprSyntax(identifier: name.camelized))])
        }
    }

}
