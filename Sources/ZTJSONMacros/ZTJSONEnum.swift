import SwiftSyntax
import SwiftSyntaxMacros

/// 让枚举自动支持 ZTJSON 序列化
/// 自动在枚举中添加 asJSONValue() 和 init(from:) 方法
/// 自动添加 ZTJSONExportable 和 ZTJSONInitializable 协议遵循
/// 要求：枚举必须有原始值（RawRepresentable），如 `enum MyEnum: Int`
public struct ZTJSONEnum: MemberMacro, ExtensionMacro, AttachedMacro {
    // MARK: - ExtensionMacro

    public static func expansion(of node: AttributeSyntax,
                                 attachedTo declaration: some DeclGroupSyntax,
                                 providingExtensionsOf type: some TypeSyntaxProtocol,
                                 conformingTo protocols: [TypeSyntax],
                                 in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw ZTASTError("@ZTJSONEnum 只能用于 enum")
        }

        let currentInherited = enumDecl.inheritanceClause?.inheritedTypes.compactMap { $0.type.trimmedDescription } ?? []

        var missing: [String] = []

        if !currentInherited.contains("ZTJSONInitializable") {
            missing.append("ZTJSONInitializable")
        }

        if !currentInherited.contains("ZTJSONExportable") {
            missing.append("ZTJSONExportable")
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

    // MARK: - MemberMacro

    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw ZTASTError("@ZTJSONEnum 只能用于 enum")
        }

        let enumName = enumDecl.name.text
        var rawTypeName = "Int"

        // 首先尝试从继承列表中获取原始值类型（如 enum MyEnum: Int32）
        let inheritedRawType = enumDecl.inheritanceClause?.inheritedTypes.first { type in
            let name = type.type.trimmedDescription
            return name != "Codable" &&
                   name != "Decodable" &&
                   name != "Encodable" &&
                   name != "ZTJSONExportable" &&
                   name != "ZTJSONInitializable" &&
                   name != "ZTTransform" &&
                   name != "CaseIterable" &&
                   name != "Equatable" &&
                   name != "Hashable" &&
                   name != "Comparable" &&
                   name != "RawRepresentable"
        }

        if let explicitRawType = inheritedRawType {
            rawTypeName = explicitRawType.type.trimmedDescription
        } else {
            // 如果继承列表中没有明确类型，尝试从 typealias RawValue 获取
            for member in enumDecl.memberBlock.members {
                if let typealiasDecl = member.decl.as(TypeAliasDeclSyntax.self),
                   typealiasDecl.name.text == "RawValue" {
                    rawTypeName = typealiasDecl.initializer.value.trimmedDescription
                    break
                }
            }

            // 检查是否遵循 RawRepresentable
            let hasRawRepresentable = enumDecl.inheritanceClause?.inheritedTypes.contains { type in
                type.type.trimmedDescription == "RawRepresentable"
            } ?? false

            guard hasRawRepresentable else {
                throw ZTASTError("@ZTJSONEnum 要求枚举必须有原始值（RawRepresentable），例如 `enum MyEnum: Int { ... }`")
            }
        }

        // 生成 asJSONValue() 方法
        let asJSONValue: DeclSyntax = DeclSyntax(stringLiteral: """
        func asJSONValue() -> JSON {
            JSON(self.rawValue as Any)
        }
        """)

        // 生成 init(from:) 方法，当转换失败时抛出异常
        let initFromJSON: DeclSyntax = DeclSyntax(stringLiteral: """
        init(from json: SwiftyJSON.JSON) throws {
            // 尝试从整数初始化
            if let intValue = json.int {
                guard let result = \(enumName)(rawValue: \(rawTypeName)(intValue)) else {
                    throw ZTJSONError.typeMismatch(expected: "\(enumName)", actual: "Invalid raw value: \\(intValue)")
                }
                self = result
                return
            }
            // 尝试从字符串初始化
            if let strValue = json.string, let rawValue = \(rawTypeName)(strValue) {
                guard let result = \(enumName)(rawValue: rawValue) else {
                    throw ZTJSONError.typeMismatch(expected: "\(enumName)", actual: "Invalid raw value: \\(strValue)")
                }
                self = result
                return
            }
            throw ZTJSONError.typeMismatch(expected: "\(enumName) (with raw value)", actual: "\\(json.type)")
        }
        """)

        return [asJSONValue, initFromJSON]
    }
}
