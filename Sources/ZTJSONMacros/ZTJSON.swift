import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

struct ZTASTError: CustomStringConvertible, Error {
    var description: String

    init(_ desc: String) {
        self.description = desc
    }
}

// MARK: - 辅助函数：解析宏参数

/// 解析 @ZTJSON(ignoreComplexXPath: true) 类型的参数
/// ignoreComplexXPath = true (默认): 忽略复杂 XPath，简单键和嵌套路径 (如 geo/lat) 使用 Codable
/// ignoreComplexXPath = false: 所有 XPath 使用 JSON.find() 方式
func parseIgnoreComplexXPathArgument(from node: AttributeSyntax) -> Bool {
    // 默认值为 true
    guard let arguments = node.arguments,
          let labeledExprList = arguments.as(LabeledExprListSyntax.self) else {
        return true
    }

    // 查找 ignoreComplexXPath 参数
    for argument in labeledExprList {
        if argument.label?.text == "ignoreComplexXPath" {
            // 解析布尔值
            if let booleanExpr = argument.expression.as(BooleanLiteralExprSyntax.self) {
                return booleanExpr.literal.text == "true"
            }
            // 如果是其他表达式（如 true/false 标识符），尝试获取其文本
            let exprText = argument.expression.trimmedDescription.lowercased()
            return exprText == "true" || exprText == "yes"
        }
    }

    // 没找到参数，使用默认值 true
    return true
}

public struct ZTJSON: ExtensionMacro, MemberMacro {
    public static func expansion(of node: AttributeSyntax,
                                 attachedTo declaration: some DeclGroupSyntax,
                                 providingExtensionsOf type: some TypeSyntaxProtocol,
                                 conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        var inheritedTypes: InheritedTypeListSyntax?
        if let declaration = declaration.as(StructDeclSyntax.self) {
            inheritedTypes = declaration.inheritanceClause?.inheritedTypes
        } else if let declaration = declaration.as(ClassDeclSyntax.self) {
            inheritedTypes = declaration.inheritanceClause?.inheritedTypes
        } else {
            throw ZTASTError("use @ZTJSON in `struct` or `class`")
        }

        let currentInherited = inheritedTypes?.compactMap { $0.type.trimmedDescription } ?? []

        var missing: [String] = []

        // 1. 判断 ZTJSONInitializable
        if !currentInherited.contains("ZTJSONInitializable") {
            missing.append("ZTJSONInitializable")
        }

        // 2. 判断 ZTJSONExportable (现在 @ZTJSON 自动包含 export 功能)
        if !currentInherited.contains("ZTJSONExportable") {
            missing.append("ZTJSONExportable")
        }

        // 3. 判断 Codable 聚合协议
        // 如果用户没写 Codable，也没写 Decodable + Encodable 的组合，则补齐 Codable
        let hasCodable = currentInherited.contains("Codable")
        let hasDecodable = currentInherited.contains("Decodable")
        let hasEncodable = currentInherited.contains("Encodable")

        if !hasCodable {
            if !hasDecodable && !hasEncodable {
                missing.append("Codable")
            } else {
                if !hasDecodable { missing.append("Decodable") }
                if !hasEncodable { missing.append("Encodable") }
            }
        }

        if missing.isEmpty {
            return []
        }

        let ext: DeclSyntax =
            """
            extension \(type.trimmed): \(raw: missing.joined(separator: ", ")) {}
            """

        return [ext.cast(ExtensionDeclSyntax.self)]
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let ignoreComplexXPath = parseIgnoreComplexXPathArgument(from: node)
        let factory = try ZTORMCodeFactory(decl: declaration, context: context, ignoreComplexXPath: ignoreComplexXPath)

        var members: [DeclSyntax] = [
            try factory.genORMInitializer(),
            try factory.genDecodableInitializer(),
            try factory.genEncodableMethod(),
            try factory.genJSONExportEncoder(),
            try factory.genMemberwiseInit()
        ]

        // 当 ignoreComplexXPath = true 时，生成 CodingKeys enum
        if ignoreComplexXPath {
            members.append(try factory.genCodingKeys())
        }

        return members
    }
}

public struct ZTJSONSubclass: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
    {
        guard declaration.is(ClassDeclSyntax.self) else {
            throw ZTASTError("not a `subclass`")
        }

        let ignoreComplexXPath = parseIgnoreComplexXPathArgument(from: node)
        let factory = try ZTORMCodeFactory(decl: declaration, context: context, ignoreComplexXPath: ignoreComplexXPath)

        var members: [DeclSyntax] = [
            try factory.genORMInitializer(isSubclass: true),
            try factory.genDecodableInitializer(isSubclass: true),
            try factory.genEncodableMethod(isSubclass: true),
            try factory.genJSONExportEncoder(isSubclass: true),
            try factory.genMemberwiseInit(isSubclass: true)
        ]

        // 当 ignoreComplexXPath = true 时，生成 CodingKeys enum
        if ignoreComplexXPath {
            members.append(try factory.genCodingKeys())
        }

        return members
    }
}
