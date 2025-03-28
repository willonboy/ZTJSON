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
        if let inheritedTypes = inheritedTypes,
           inheritedTypes.contains(where: { inherited in inherited.type.trimmedDescription == "ZTJSONInitializable" }) {
            return []
        }

        let ext: DeclSyntax =
            """
            extension \(type.trimmed): ZTJSONInitializable {}
            """

        return [ext.cast(ExtensionDeclSyntax.self)]
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        let factory = try ZTORMCodeFactory(decl: declaration, context: context)
        let decoder = try factory.genORMInitializer()
        let memberwiseInit = try factory.genMemberwiseInit()
        
        return [decoder, memberwiseInit]
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

        let factory = try ZTORMCodeFactory(decl: declaration, context: context)
        let decoder = try factory.genORMInitializer(isOverride: true)
        let memberwiseInit = try factory.genMemberwiseInit(isOverride: true)
        return [decoder, memberwiseInit]
    }
}
