import SwiftSyntax
import SwiftSyntaxMacros

public struct ZTJSONTransformer: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return []
    }
}

public struct ZTJSONLetDefValue: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return []
    }
}

public struct ZTJSONIgnore: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return []
    }
}

public struct ZTJSONKey: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        // 验证参数个数
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw ZTASTError("@ZTJSONKey 至少需要一个参数")
        }

        let count = arguments.count
        guard count >= 1 else {
            throw ZTASTError("@ZTJSONKey 至少需要一个参数")
        }

        guard count <= 5 else {
            throw ZTASTError("@ZTJSONKey 最多支持 5 个参数（主键 + 4 个回退键）")
        }

        return []
    }
}
