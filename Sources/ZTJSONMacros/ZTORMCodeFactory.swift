import SwiftSyntax
import SwiftSyntaxMacros

private struct ZTMemberProperty {
    var name: String
    var type: String
    var modifiers: DeclModifierListSyntax = []
    var isOptional: Bool = false
    var normalKeys: [String] = []
    var transformerExpr: String?
    var initializerExpr: String
    var isHaveDefValue = true

    var jsonKeys: [String] {
        let raw = ["\"\(name)\""]
        if normalKeys.isEmpty {
            return raw
        }
        return normalKeys
    }
}

struct ZTORMCodeFactory {
    struct AttributeOption: OptionSet {
        let rawValue: UInt

        static let open = AttributeOption(rawValue: 1 << 0)
        static let `public` = AttributeOption(rawValue: 1 << 1)
        static let required = AttributeOption(rawValue: 1 << 2)
    }

    let context: MacroExpansionContext
    fileprivate let decl: DeclGroupSyntax
    fileprivate var memberProperties: [ZTMemberProperty] = []

    init(decl: DeclGroupSyntax, context: some MacroExpansionContext) throws {
        self.decl = decl
        self.context = context
        memberProperties = try loadMemberProperties()
    }

    private func attributesPrefix(option: AttributeOption) -> String {
        let hasPublicProperites = memberProperties.contains(where: {
            $0.modifiers.contains(where: {
                $0.name.text == "public" || $0.name.text == "open"
            })
        })

        let modifiers = decl.modifiers.compactMap { $0.name.text }
        var attributes: [String] = []
        if option.contains(.open), modifiers.contains("open") {
            attributes.append("open")
        } else if option.contains(.public), hasPublicProperites || modifiers.contains("open") || modifiers.contains("public") {
            attributes.append("public")
        }
        if option.contains(.required), decl.is(ClassDeclSyntax.self) {
            attributes.append("required")
        }
        if !attributes.isEmpty {
            attributes.append("")
        }

        return attributes.joined(separator: " ")
    }

    func genORMInitializer(isOverride: Bool = false) throws -> DeclSyntax {
        let body = memberProperties.enumerated().map { idx, member in
            let find = member.jsonKeys.map {
                "json.find(xpath: \($0))"
            }.joined(separator: " ?? ")
            
            if let transformerExpr = member.transformerExpr {
                return """
                    if let t = \(find), t != .null { 
                        self.\(member.name) = ((\(transformerExpr)).transform(t)) ?? (\(member.initializerExpr)) 
                    } else {
                        self.\(member.name) = \(member.initializerExpr) 
                    }
                """
            }
            return """
                if let t = \(find), t != .null { 
                    self.\(member.name) = (try? \(member.type.trimmingCharacters(in: .init(charactersIn: "?")))(from: t)) ?? (\(member.initializerExpr)) 
                } else {
                    self.\(member.name) = \(member.initializerExpr) 
                }
            """
        }
        .joined(separator: "\n")

        let decoder: DeclSyntax = """
        \(raw: attributesPrefix(option: [.public, .required]))init(from json: JSON) throws {
        \(raw: body)\(raw: isOverride ? "\ntry super.init(from: json)" : "")
        }
        """

        return decoder
    }
    
    func genMemberwiseInit(isOverride: Bool = false) throws -> DeclSyntax {
        let parameters = memberProperties.map { property in
            var text = property.name
            text += ": " + property.type
            if property.isHaveDefValue || property.isOptional {
                text += "= \(property.initializerExpr)"
            }
            return text
        }

        let overrideInit = isOverride ? "super.init()" : ""

        return
            """
            \(raw: attributesPrefix(option: [.public]))init(\(raw: parameters.joined(separator: ", "))) {
                \(raw: memberProperties.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n"))
                \(raw: overrideInit)
            }
            """ as DeclSyntax
    }
}

private extension ZTORMCodeFactory {
    func loadMemberProperties() throws -> [ZTMemberProperty] {
        let memberList = decl.memberBlock.members
        let memberProperties = try memberList.flatMap { member -> [ZTMemberProperty] in
            guard let variable = member.decl.as(VariableDeclSyntax.self), variable.isStoredProperty else {
                return []
            }
            let patterns = variable.bindings.map(\.pattern)
            let names = patterns.compactMap { $0.as(IdentifierPatternSyntax.self)?.identifier.text }

            return try names.compactMap { name -> ZTMemberProperty? in
                guard !variable.isLazyVar else {
                    return nil
                }
                guard let type = variable.inferType else {
                    throw ZTASTError("Please declare property type: \(name)")
                }
                
                let attributes = variable.attributes
                var initializerExpr = ""
                var isHaveDefValue = false
                if let initializer = variable.bindings.compactMap(\.initializer).first {
                    initializerExpr = initializer.value.description
                    isHaveDefValue = true
                } else {
                    
                    if variable.isOptionalType {
                        initializerExpr = "nil"
                    } else {
                        if variable.isLet == false {
                            throw ZTASTError("Please directly assign a default value to the property: \(name)")
                        }
                        
                        var defValueExpr: String? = nil
                        if let customKeyMacro = attributes.first(where: { element in
                            element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "ZTJSONLetDefValue"
                        }) {
                            defValueExpr = customKeyMacro.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.description
                        }
                        if defValueExpr == nil {
                            throw ZTASTError("Please use @ZTJSONLetDefValue to assign a default value to the property: \(name)")
                        }
                        
                        initializerExpr = defValueExpr!
                    }
                }
                var mp = ZTMemberProperty(name: name, type: type, initializerExpr: initializerExpr)
                mp.modifiers = variable.modifiers
                mp.isHaveDefValue = isHaveDefValue
                mp.isOptional = variable.isOptionalType

                if let customKeyMacro = attributes.first(where: { element in
                    element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "ZTJSONKey"
                }) {
                    mp.normalKeys = customKeyMacro.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.compactMap { $0.expression.description } ?? []
                }

                if let customKeyMacro = attributes.first(where: { element in
                    element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "ZTJSONTransformer"
                }) {
                    mp.transformerExpr = customKeyMacro.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.description
                }

                return mp
            }
        }
        return memberProperties
    }
}
