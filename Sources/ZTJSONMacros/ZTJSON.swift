import SwiftSyntax
import SwiftSyntaxMacros
import Foundation

struct ZTASTError: CustomStringConvertible, Error {
    var description: String

    init(_ desc: String) {
        self.description = desc
    }
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
        
        // 2. 判断 Codable 聚合协议
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
        let factory = try ZTORMCodeFactory(decl: declaration, context: context)
        
        // 生成所有必要成员（包括原本的 ORM init 和新增的 Codable 实现）
        return [
            try factory.genORMInitializer(),
            try factory.genDecodableInitializer(),
            try factory.genEncodableMethod(),
            try factory.genMemberwiseInit()
        ]
    }
}

public struct ZTJSONSubclass: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
    {
        guard declaration.is(ClassDeclSyntax.self) else {
            throw ZTASTError("not a `subclass`")
        }

        let factory = try ZTORMCodeFactory(decl: declaration, context: context)
        return [
            try factory.genORMInitializer(isSubclass: true),
            try factory.genDecodableInitializer(isSubclass: true),
            try factory.genEncodableMethod(isSubclass: true),
            try factory.genMemberwiseInit(isSubclass: true)
        ]
    }
}

public struct ZTJSONExport: ExtensionMacro, MemberMacro {
    public static func expansion(of node: AttributeSyntax,
                                 attachedTo declaration: some DeclGroupSyntax,
                                 providingExtensionsOf type: some TypeSyntaxProtocol,
                                 conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        var inheritedTypes: InheritedTypeListSyntax?
        if let declaration = declaration.as(StructDeclSyntax.self) {
            inheritedTypes = declaration.inheritanceClause?.inheritedTypes
        } else if let declaration = declaration.as(ClassDeclSyntax.self) {
            inheritedTypes = declaration.inheritanceClause?.inheritedTypes
        }
        
        if let inheritedTypes = inheritedTypes,
           inheritedTypes.contains(where: { inherited in inherited.type.trimmedDescription == "ZTJSONExportable" }) {
            return []
        }

        let ext: DeclSyntax =
            """
            extension \(type.trimmed): ZTJSONExportable {}
            """

        return [ext.cast(ExtensionDeclSyntax.self)]
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let factory = try ZTORMCodeFactory(decl: declaration, context: context)
        return [try factory.genJSONExportEncoder()]
    }
}

public struct ZTJSONExportSubclass: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax]
    {
        guard declaration.is(ClassDeclSyntax.self) else {
            throw ZTASTError("not a `subclass`")
        }

        let factory = try ZTORMCodeFactory(decl: declaration, context: context)
        return [try factory.genJSONExportEncoder(isSubclass: true)]
    }
}
