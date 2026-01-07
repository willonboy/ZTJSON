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
    var jsonKeys: [String] { normalKeys + ["\"\(name)\""] }
    var encodeKey: String {
        normalKeys.first(where: { !$0.contains("/") }) ?? "\"\(name)\""
    }
}

struct ZTORMCodeFactory {
    struct AttributeOption: OptionSet {
        let rawValue: UInt
        static let `public` = AttributeOption(rawValue: 1 << 0)
        static let required = AttributeOption(rawValue: 1 << 1)
    }

    let context: MacroExpansionContext
    fileprivate let decl: DeclGroupSyntax
    fileprivate var memberProperties: [ZTMemberProperty] = []

    init(decl: DeclGroupSyntax, context: some MacroExpansionContext) throws {
        self.decl = decl
        self.context = context
        memberProperties = try loadMemberProperties()
    }

    private func attributesPrefix(option: AttributeOption, isSubclass: Bool = false, isMethod: Bool = false) -> String {
        let hasPublic = memberProperties.contains(where: { $0.modifiers.contains(where: { $0.name.text == "public" || $0.name.text == "open" }) })
        let modifiers = decl.modifiers.compactMap { $0.name.text }
        var attributes: [String] = []
        
        // 1. 处理 required / override
        // Swift 规定：重写父类的 required init 必须且只能写 required，不能写 override
        if option.contains(.required), decl.is(ClassDeclSyntax.self) {
            attributes.append("required")
        } else if isSubclass {
            attributes.append("override")
        }
        
        // 2. 处理访问控制 (public / open)
        if option.contains(.public) {
            if modifiers.contains("open") {
                // 构造器 (init) 不能是 open，必须降级为 public；普通方法可以 open
                attributes.append(isMethod ? "open" : "public")
            } else if modifiers.contains("public") || hasPublic {
                attributes.append("public")
            }
        }
        
        if !attributes.isEmpty { attributes.append("") }
        return attributes.joined(separator: " ")
    }

    // --- 核心逻辑：提取 Body 以便两个 init 复用，同时保持你最原本的实现逻辑 ---
    private func genOriginalORMBody(jsonVar: String) -> String {
        return memberProperties.map { member in
            let find = member.jsonKeys.map { "\(jsonVar).find(xpath: \($0))" }.joined(separator: " ?? ")
            let typeName = member.type.trimmingCharacters(in: .init(charactersIn: "?"))
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
                self.\(member.name) = (try? \(typeName)(from: t)) ?? (\(member.initializerExpr)) 
            } else {
                self.\(member.name) = \(member.initializerExpr) 
            }
            """
        }.joined(separator: "\n")
    }

    // 1. ZTJSONInitializable 宏实现 (还原你的原本实现)
    func genORMInitializer(isSubclass: Bool = false) throws -> DeclSyntax {
        let prefix = attributesPrefix(option: [.public, .required])
        return """
        \(raw: prefix)init(from json: JSON) throws {
            \(raw: genOriginalORMBody(jsonVar: "json"))
            \(raw: isSubclass ? "try super.init(from: json)" : "")
        }
        """
    }
    
    // 2. Decodable 宏实现 (为了规避 convenience 报错，直接展开逻辑)
    func genDecodableInitializer(isSubclass: Bool = false) throws -> DeclSyntax {
        let prefix = attributesPrefix(option: [.public, .required])
        return """
        \(raw: prefix)init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let data = try container.decode(Data.self)
            let json = try JSON(data: data)
            \(raw: genOriginalORMBody(jsonVar: "json"))
            \(raw: isSubclass ? "try super.init(from: decoder)" : "")
        }
        """
    }

    // 3. Encodable 宏实现
    func genEncodableMethod(isSubclass: Bool = false) throws -> DeclSyntax {
        let keys = memberProperties.map { "case \($0.name) = \($0.encodeKey)" }.joined(separator: "\n")
        let encodes = memberProperties.map { "try container.encode(self.\($0.name), forKey: .\($0.name))" }.joined(separator: "\n")
        let prefix = attributesPrefix(option: [.public], isSubclass: isSubclass, isMethod: true)
        return """
        \(raw: prefix)func encode(to encoder: Encoder) throws {
            enum CodingKeys: String, CodingKey { \(raw: keys) }
            var container = encoder.container(keyedBy: CodingKeys.self)
            \(raw: encodes)
            \(raw: isSubclass ? "try super.encode(to: encoder)" : "")
        }
        """
    }

    // 4. Export 宏实现
    func genJSONExportEncoder(isSubclass: Bool = false) throws -> DeclSyntax {
        let body = memberProperties.map { "\( $0.encodeKey ) : self.\($0.name).asJSONValue()," }.joined(separator: "\n")
        let prefix = attributesPrefix(option: [.public], isSubclass: isSubclass, isMethod: true)
        if isSubclass {
            return """
            \(raw: prefix)func asJSONValue() -> JSON {
                let sup = super.asJSONValue()
                let sub = JSON([\(raw: body)])
                return (try? sup.merged(with: sub)) ?? JSON.null
            }
            """
        } else {
            return """
            \(raw: prefix)func asJSONValue() -> JSON {
                JSON([\(raw: body)])
            }
            """
        }
    }

    // 5. Memberwise Init 宏实现
    func genMemberwiseInit(isSubclass: Bool = false) throws -> DeclSyntax {
        let parameters = memberProperties.map { property in
            var text = property.name + ": " + property.type
            if property.isHaveDefValue || property.isOptional { text += "= \(property.initializerExpr)" }
            return text
        }.joined(separator: ", ")
        let prefix = attributesPrefix(option: [.public])
        return """
        \(raw: prefix)init(\(raw: parameters)) {
            \(raw: memberProperties.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n"))
            \(raw: isSubclass ? "super.init()" : "")
        }
        """
    }
}

private extension ZTORMCodeFactory {
    func loadMemberProperties() throws -> [ZTMemberProperty] {
        let memberList = decl.memberBlock.members
        return try memberList.flatMap { member -> [ZTMemberProperty] in
            guard let variable = member.decl.as(VariableDeclSyntax.self), variable.isStoredProperty else { return [] }
            let names = variable.bindings.compactMap { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
            return try names.compactMap { name -> ZTMemberProperty? in
                if variable.isLazyVar { return nil }
                guard let type = variable.inferType else { throw ZTASTError("Type needed: \(name)") }
                let attributes = variable.attributes
                if attributes.contains(where: { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "ZTJSONIgnore" }) { return nil }
                var initExpr = ""; var isDef = false
                if let initializer = variable.bindings.compactMap(\.initializer).first {
                    initExpr = initializer.value.description; isDef = true
                } else if variable.isOptionalType {
                    initExpr = "nil"
                } else {
                    if !variable.isLet { throw ZTASTError("Need default value: \(name)") }
                    let customDef = attributes.first { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "ZTJSONLetDefValue" }
                    guard let def = customDef?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.description else {
                        throw ZTASTError("Use @ZTJSONLetDefValue for let: \(name)")
                    }
                    initExpr = def
                }
                var mp = ZTMemberProperty(name: name, type: type, initializerExpr: initExpr)
                mp.modifiers = variable.modifiers; mp.isHaveDefValue = isDef; mp.isOptional = variable.isOptionalType
                if let keyAttr = attributes.first(where: { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "ZTJSONKey" }) {
                    mp.normalKeys = keyAttr.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.compactMap { $0.expression.description } ?? []
                }
                if let transAttr = attributes.first(where: { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "ZTJSONTransformer" }) {
                    mp.transformerExpr = transAttr.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.description
                }
                return mp
            }
        }
    }
}
