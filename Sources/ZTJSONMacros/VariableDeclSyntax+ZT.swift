import SwiftSyntax

extension VariableDeclSyntax {
    
    var isStoredProperty: Bool {
        if modifiers.contains(where: { $0.name.text == "static" }) {
            return false
        }
        if bindings.count < 1 {
            return false
        }
        let binding = bindings.last!
        switch binding.accessorBlock?.accessors {
        case .none:
            return true
        case let .accessors(o):
            for accessor in o {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    break
                default:
                    return false
                }
            }
            return true
        case .getter:
            return false
        }
    }

    var inferType: String? {
        var type: String? = bindings.compactMap(\.typeAnnotation).first?.type.trimmedDescription
        if type == nil, let initExpr = bindings.compactMap(\.initializer).first?.value {
            if initExpr.is(StringLiteralExprSyntax.self) {
                type = "String"
            } else if initExpr.is(IntegerLiteralExprSyntax.self) {
                type = "Int"
            } else if initExpr.is(FloatLiteralExprSyntax.self) {
                type = "Double"
            } else if initExpr.is(BooleanLiteralExprSyntax.self) {
                type = "Bool"
            } else if let funcDecl = initExpr.as(FunctionCallExprSyntax.self),
                      let declRef = funcDecl.calledExpression.as(DeclReferenceExprSyntax.self) {
                type = declRef.trimmedDescription
            }
        }
        return type
    }

    var isOptionalType: Bool {
        if bindings.compactMap(\.typeAnnotation).first?.type.is(OptionalTypeSyntax.self) == true {
            return true
        }
        if bindings.compactMap(\.initializer).first?.value.as(DeclReferenceExprSyntax.self)?.description.hasPrefix("Optional<") == true {
            return true
        }
        if bindings.compactMap(\.initializer).first?.value.as(DeclReferenceExprSyntax.self)?.description.hasPrefix("Optional(") == true {
            return true
        }
        return false
    }

    var isLazyVar: Bool {
        if modifiers.contains(where: { $0.name.trimmedDescription == "lazy" }) {
            return true
        }
        return false
    }
    
    var isLet: Bool {
        if bindingSpecifier.text.trimmingCharacters(in: .whitespacesAndNewlines) == "let" {
            return true
        }
        return false
    }
}
