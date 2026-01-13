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

    /// XPath 类型
    enum XPathType {
        case simple           // 简单键名，如 "name"
        case nested           // 简单嵌套路径，如 "geo/lat"
        case complex          // 复杂路径，包含通配符、数组索引等
    }

    /// 判断第一个键的 XPath 类型
    var firstKeyType: XPathType {
        guard let firstKey = normalKeys.first else { return .simple }
        return Self.classifyXPath(firstKey)
    }

    /// 判断 XPath 类型
    static func classifyXPath(_ xpath: String) -> XPathType {
        // 去掉引号
        let path = xpath.trimmingCharacters(in: .init(charactersIn: "\""))

        // 不包含 /，是简单键名
        guard path.contains("/") else { return .simple }

        // 检查是否包含复杂语法
        let complexPatterns = ["*", "[", "]", "//", "@", "!", "|", "="]
        for pattern in complexPatterns {
            if path.contains(pattern) {
                return .complex
            }
        }

        // 检查是否是负数索引（如 -1, -2）
        let components = path.split(separator: "/")
        for component in components {
            if component.hasPrefix("-") {
                return .complex
            }
        }

        // 只包含简单的 / 分隔，是嵌套路径
        return .nested
    }

    /// 解析嵌套路径，返回 (父路径, 最终键名)
    /// 例如: "geo/lat" -> ("geo", "lat")
    ///      "user/address/geo/lat" -> ("user/address/geo", "lat")
    func parseNestedPath(_ xpath: String) -> (parentPath: String, leafKey: String)? {
        let path = xpath.trimmingCharacters(in: .init(charactersIn: "\""))
        let components = path.split(separator: "/").map { String($0) }
        guard components.count >= 2 else { return nil }
        let parentPath = components.dropLast().joined(separator: "/")
        let leafKey = components.last!
        return (parentPath, leafKey)
    }

    /// 用于 Codable CodingKeys 的 case 名称（属性名）
    var codableKey: String {
        return name
    }

    /// 用于 Codable 解码的所有可能键名（不包含 XPath 路径）
    /// 支持多 key 回退机制
    var codableKeys: [String] {
        let keys = normalKeys.filter { !$0.contains("/") }.map { $0.trimmingCharacters(in: .init(charactersIn: "\"")) }
        return keys.isEmpty ? [name] : keys
    }

    /// 获取第一个非简单路径的嵌套路径键（如果有）
    var nestedPathKey: String? {
        for key in normalKeys {
            if Self.classifyXPath(key) == .nested {
                return key.trimmingCharacters(in: .init(charactersIn: "\""))
            }
        }
        return nil
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
    /// 是否忽略复杂 XPath，简单键和嵌套路径 (如 geo/lat) 使用 Codable
    /// true (默认): 简单键和嵌套路径使用 Codable，复杂 XPath 使用 JSON.find()
    /// false: 所有 XPath 使用 JSON.find() 方式
    let ignoreComplexXPath: Bool

    init(decl: DeclGroupSyntax, context: some MacroExpansionContext, ignoreComplexXPath: Bool = true) throws {
        self.decl = decl
        self.context = context
        self.ignoreComplexXPath = ignoreComplexXPath
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

    // 1. ZTJSONInitializable 宏实现 (还原你的原本实现，始终支持 XPath)
    func genORMInitializer(isSubclass: Bool = false) throws -> DeclSyntax {
        let prefix = attributesPrefix(option: [.public, .required])
        return """
        \(raw: prefix)init(from json: JSON) throws {
            \(raw: genOriginalORMBody(jsonVar: "json"))
            \(raw: isSubclass ? "try super.init(from: json)" : "")
        }
        """
    }

    // 2. Decodable 宏实现
    func genDecodableInitializer(isSubclass: Bool = false) throws -> DeclSyntax {
        let prefix = attributesPrefix(option: [.public, .required])

        // 检查是否有任何属性使用复杂 XPath
        let hasComplexXPath = memberProperties.contains { $0.firstKeyType == .complex }

        if ignoreComplexXPath && !hasComplexXPath {
            // 标准 Codable 实现：使用 keyedContainer
            // 支持简单键 + 嵌套路径（如 geo/lat）
            let decodeBody = memberProperties.map { member in
                let propAccess = "self.\(member.name)"
                let wrappedType = member.type.trimmingCharacters(in: .init(charactersIn: "?"))

                // 检查是否有嵌套路径
                if let nestedKey = member.nestedPathKey,
                   let (parentPath, leafKey) = member.parseNestedPath(nestedKey) {
                    // 嵌套路径：使用 nestedContainer
                    // 需要为父路径生成 CodingKeys
                    return generateNestedDecodeCode(member: member, parentPath: parentPath, leafKey: leafKey)
                }

                // 简单键：直接解码
                let keys = member.codableKeys
                let keyReferences: [String] = keys.enumerated().map { index, _ in
                    if index == 0 {
                        return ".\(member.codableKey)"
                    } else {
                        return ".\(member.codableKey)_\(index)"
                    }
                }

                // 如果有 Transformer，使用 Transformer 解码
                if member.transformerExpr != nil {
                    return generateTransformerDecodeCode(member: member, keys: keys, keyReferences: keyReferences)
                }

                if member.isOptional {
                    if keys.count == 1 {
                        let keyRef = keyReferences[0]
                        return """
                        \(propAccess) = try container.decodeIfPresent(\(wrappedType).self, forKey: \(keyRef))
                        """
                    } else {
                        var code = ""
                        for (index, keyRef) in keyReferences.enumerated() {
                            if index == 0 {
                                code += "if let v = try container.decodeIfPresent(\(wrappedType).self, forKey: \(keyRef)) {\n"
                                code += "    \(propAccess) = v\n"
                            } else {
                                code += "} else if let v = try container.decodeIfPresent(\(wrappedType).self, forKey: \(keyRef)) {\n"
                                code += "    \(propAccess) = v\n"
                            }
                        }
                        code += "} else {\n"
                        code += "    \(propAccess) = nil\n"
                        code += "}\n"
                        return code
                    }
                } else if member.isHaveDefValue {
                    if keys.count == 1 {
                        let keyRef = keyReferences[0]
                        return """
                        \(propAccess) = (try? container.decode(\(wrappedType).self, forKey: \(keyRef))) ?? (\(member.initializerExpr))
                        """
                    } else {
                        var code = ""
                        for (index, keyRef) in keyReferences.enumerated() {
                            if index == 0 {
                                code += "let _\(member.name)Val\(index + 1) = try? container.decode(\(wrappedType).self, forKey: \(keyRef))\n"
                            } else {
                                code += "let _\(member.name)Val\(index + 1) = _\(member.name)Val\(index) == nil ? try? container.decode(\(wrappedType).self, forKey: \(keyRef)) : _\(member.name)Val\(index)\n"
                            }
                        }
                        code += "let _\(member.name)Result: \(wrappedType)? = "
                        for index in 0..<keys.count {
                            if index > 0 { code += " ?? " }
                            code += "_\(member.name)Val\(index + 1)"
                        }
                        code += "\n"
                        code += "\(propAccess) = _\(member.name)Result ?? (\(member.initializerExpr))\n"
                        return code
                    }
                } else {
                    if keys.count == 1 {
                        let keyRef = keyReferences[0]
                        return """
                        \(propAccess) = try container.decode(\(wrappedType).self, forKey: \(keyRef))
                        """
                    } else {
                        var code = ""
                        for (index, keyRef) in keyReferences.enumerated() {
                            if index == 0 {
                                code += "let _\(member.name)Val\(index + 1) = try? container.decode(\(wrappedType).self, forKey: \(keyRef))\n"
                            } else {
                                code += "let _\(member.name)Val\(index + 1) = _\(member.name)Val\(index) == nil ? try? container.decode(\(wrappedType).self, forKey: \(keyRef)) : _\(member.name)Val\(index)\n"
                            }
                        }
                        code += "guard let \(propAccess) = "
                        for index in 0..<keys.count {
                            if index > 0 { code += " ?? " }
                            code += "_\(member.name)Val\(index + 1)"
                        }
                        code += " else {\n"
                        code += "    throw DecodingError.keyNotFound(CodingKeys(stringValue: \"\(keys.joined(separator: "\", \""))\"!, intValue: nil), container.codingPath)\n"
                        code += "}\n"
                        return code
                    }
                }
            }.joined(separator: "\n")

            return """
            \(raw: prefix)init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                \(raw: decodeBody)
                \(raw: isSubclass ? "try super.init(from: decoder)" : "")
            }
            """
        } else {
            // 原实现：使用 singleValueContainer + base64
            // 用于复杂 XPath（通配符、数组索引等）
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
    }

    /// 生成 Transformer 解码代码
    /// 支持简单键和嵌套路径，使用 JSON + Transformer 方式解码
    private func generateTransformerDecodeCode(member: ZTMemberProperty, keys: [String], keyReferences: [String]) -> String {
        let propAccess = "self.\(member.name)"
        let transformerExpr = member.transformerExpr!
        let defaultExpr = member.initializerExpr

        // 构建多键回退的 JSON 查找代码
        if keys.count == 1 {
            let jsonFetchCode = "try? container.decodeIfPresent(JSON.self, forKey: \(keyReferences[0]))"

            if member.isOptional {
                return """
                if let json = \(jsonFetchCode), let transformed = (\(transformerExpr)).transform(json) {
                    \(propAccess) = transformed
                } else {
                    \(propAccess) = nil
                }
                """
            } else if member.isHaveDefValue {
                return """
                if let json = \(jsonFetchCode), let transformed = (\(transformerExpr)).transform(json) {
                    \(propAccess) = transformed
                } else {
                    \(propAccess) = \(defaultExpr)
                }
                """
            } else {
                return """
                guard let json = \(jsonFetchCode), let transformed = (\(transformerExpr)).transform(json) else {
                    throw DecodingError.keyNotFound(CodingKeys(stringValue: "\(keys[0])", intValue: nil), container.codingPath)
                }
                \(propAccess) = transformed
                """
            }
        } else {
            // 多键回退：需要使用 if-else 链
            var fallbackChain = ""
            for (index, keyRef) in keyReferences.enumerated() {
                if index == 0 {
                    fallbackChain += "let _\(member.name)Json\(index) = try? container.decodeIfPresent(JSON.self, forKey: \(keyRef))\n"
                } else {
                    fallbackChain += "let _\(member.name)Json\(index) = _\(member.name)Json\(index - 1) == nil ? try? container.decodeIfPresent(JSON.self, forKey: \(keyRef)) : _\(member.name)Json\(index - 1)\n"
                }
            }
            // 最终的 JSON 变量（最后一个非 nil 的值）
            fallbackChain += "let \(member.name)Json: JSON? = "
            for index in 0..<keys.count {
                if index > 0 { fallbackChain += " ?? " }
                fallbackChain += "_\(member.name)Json\(index)"
            }
            fallbackChain += "\n"

            if member.isOptional {
                return """
                \(fallbackChain)
                if let json = \(member.name)Json, let transformed = (\(transformerExpr)).transform(json) {
                    \(propAccess) = transformed
                } else {
                    \(propAccess) = nil
                }
                """
            } else if member.isHaveDefValue {
                return """
                \(fallbackChain)
                if let json = \(member.name)Json, let transformed = (\(transformerExpr)).transform(json) {
                    \(propAccess) = transformed
                } else {
                    \(propAccess) = \(defaultExpr)
                }
                """
            } else {
                return """
                \(fallbackChain)
                guard let json = \(member.name)Json, let transformed = (\(transformerExpr)).transform(json) else {
                    throw DecodingError.keyNotFound(CodingKeys(stringValue: "\(keys.joined(separator: "\", \""))\"!, intValue: nil), container.codingPath)
                }
                \(propAccess) = transformed
                """
            }
        }
    }

    /// 生成嵌套路径的解码代码
    /// 例如：geo/lat -> container.nestedContainer(keyedBy: CodingKeys.self, forKey: .geo).decode(Double.self, forKey: .lat)
    private func generateNestedDecodeCode(member: ZTMemberProperty, parentPath: String, leafKey: String) -> String {
        let propAccess = "self.\(member.name)"
        let wrappedType = member.type.trimmingCharacters(in: .init(charactersIn: "?"))
        let leafCodingKey = ".\(member.name)"  // 使用属性名作为 CodingKey

        // 解析父路径的各个层级
        let pathComponents = parentPath.split(separator: "/").map { String($0) }

        // 构建 nestedContainer 调用链
        var containerChain = "container"
        for component in pathComponents {
            containerChain += ".nestedContainer(keyedBy: CodingKeys.self, forKey: .\(component))"
        }

        // 如果有 Transformer，使用 Transformer 解码
        if let transformerExpr = member.transformerExpr {
            let defaultExpr = member.initializerExpr

            if member.isOptional {
                // Optional: 从嵌套容器获取 JSON，应用 Transformer
                return """
                if let nestedContainer = try? \(containerChain),
                   let json = try? nestedContainer.decodeIfPresent(JSON.self, forKey: \(leafCodingKey)),
                   let transformed = (\(transformerExpr)).transform(json) {
                    \(propAccess) = transformed
                } else {
                    \(propAccess) = nil
                }
                """
            } else if member.isHaveDefValue {
                // 有默认值: 转换失败则使用默认值
                return """
                if let nestedContainer = try? \(containerChain),
                   let json = try? nestedContainer.decodeIfPresent(JSON.self, forKey: \(leafCodingKey)),
                   let transformed = (\(transformerExpr)).transform(json) {
                    \(propAccess) = transformed
                } else {
                    \(propAccess) = \(defaultExpr)
                }
                """
            } else {
                // 必需属性: 转换失败则抛出错误
                return """
                let nestedContainer = try \(containerChain)
                guard let json = try? nestedContainer.decodeIfPresent(JSON.self, forKey: \(leafCodingKey)),
                      let transformed = (\(transformerExpr)).transform(json) else {
                    throw DecodingError.keyNotFound(CodingKeys(stringValue: "\(leafKey)", intValue: nil), container.codingPath)
                }
                \(propAccess) = transformed
                """
            }
        }

        // 根据类型生成解码代码（无 Transformer）
        if member.isOptional {
            return """
            if let nestedContainer = try? \(containerChain) {
                \(propAccess) = try? nestedContainer.decodeIfPresent(\(wrappedType).self, forKey: \(leafCodingKey))
            }
            """
        } else if member.isHaveDefValue {
            return """
            if let nestedContainer = try? \(containerChain) {
                \(propAccess) = (try? nestedContainer.decode(\(wrappedType).self, forKey: \(leafCodingKey))) ?? (\(member.initializerExpr))
            } else {
                \(propAccess) = \(member.initializerExpr)
            }
            """
        } else {
            return """
            let nestedContainer = try \(containerChain)
            \(propAccess) = try nestedContainer.decode(\(wrappedType).self, forKey: \(leafCodingKey))
            """
        }
    }

    // 3. Encodable 宏实现
    func genEncodableMethod(isSubclass: Bool = false) throws -> DeclSyntax {
        let prefix = attributesPrefix(option: [.public], isSubclass: isSubclass, isMethod: true)

        // 检查是否有复杂 XPath
        let hasComplexXPath = memberProperties.contains { $0.firstKeyType == .complex }

        if ignoreComplexXPath && !hasComplexXPath {
            // 标准 Codable 实现：使用 keyedContainer
            let encodeBody = memberProperties.map { member in
                let key = member.codableKey
                let propAccess = "self.\(member.name)"

                if member.isOptional {
                    // Optional 类型：如果非 nil 则编码
                    return """
                    if let value = \(propAccess) {
                        try container.encode(value, forKey: .\(key))
                    }
                    """
                } else {
                    // 非 Optional 类型
                    return """
                    try container.encode(\(propAccess), forKey: .\(key))
                    """
                }
            }.joined(separator: "\n")

            if isSubclass {
                // subclass 需要先调用 super.encode(to:) 以包含父类属性
                return """
                \(raw: prefix)func encode(to encoder: Encoder) throws {
                    try super.encode(to: encoder)
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    \(raw: encodeBody)
                }
                """
            } else {
                return """
                \(raw: prefix)func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    \(raw: encodeBody)
                }
                """
            }
        } else {
            // 原实现：使用 singleValueContainer + base64
            // 用于复杂 XPath（通配符、数组索引等）
            return """
            \(raw: prefix)func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                let jsonData = try self.asJSONValue().rawData()
                try container.encode(jsonData)
            }
            """
        }
    }

    // 4. Export 宏实现
    // 使用 ZTJSONExportable 转换来处理所有类型（包括基本类型通过扩展支持）
    func genJSONExportEncoder(isSubclass: Bool = false) throws -> DeclSyntax {
        // 生成编译时类型检查代码
        let typeCheckCode = memberProperties.map { member in
            let propType = member.type  // 保留 Optional 标记
            let propTypeName = propType.trimmingCharacters(in: .init(charactersIn: "?"))

            // 生成类型约束检查：利用 Swift 类型系统在编译时验证属性类型是否遵循 ZTJSONExportable
            // 如果类型不支持，这行代码会在编译时报错
            if member.isOptional {
                // Optional 类型：使用 Optional 赋值检查
                return """
                // 编译时类型检查：\(member.name): \(propType)
                // 如果此行报错，说明 \(propTypeName) 不支持 ZTJSONExportable
                // 解决方法：扩展 \(propTypeName): ZTJSONExportable
                let _: (any ZTJSONExportable)?? = Optional(nil).map { $0 as \(propTypeName) }
                """
            } else {
                // 非 Optional 类型：使用函数参数类型约束检查
                return """
                // 编译时类型检查：\(member.name): \(propType)
                // 如果此行报错，说明 \(propTypeName) 不支持 ZTJSONExportable
                // 解决方法：扩展 \(propTypeName): ZTJSONExportable
                let _: ((\(propType)) -> any ZTJSONExportable) = { $0 as any ZTJSONExportable }
                """
            }
        }.joined(separator: "\n")

        // 生成每个属性的转换代码，支持 Optional 和非 Optional
        let body = memberProperties.map { member in
            let propAccess = "self.\(member.name)"
            let key = member.encodeKey

            // 处理 Optional 类型
            if member.isOptional {
                // Optional: 使用 flatMap 处理，nil 时返回 .null
                // 注意语法：\(propAccess) as (any ZTJSONExportable)?
                return """
                \(key): ((\(propAccess) as (any ZTJSONExportable)?)).flatMap { $0.asJSONValue() } ?? JSON.null,
                """
            } else {
                // 非 Optional: 强制转换并调用 asJSONValue()
                return """
                \(key): (\(propAccess) as any ZTJSONExportable).asJSONValue(),
                """
            }
        }.joined(separator: "\n")

        let prefix = attributesPrefix(option: [.public], isSubclass: isSubclass, isMethod: true)
        if isSubclass {
            return """
            \(raw: prefix)func asJSONValue() -> JSON {
                \(raw: typeCheckCode)
                let sup = super.asJSONValue()
                let sub = JSON([\(raw: body)])
                return (try? sup.merged(with: sub)) ?? JSON.null
            }
            """
        } else {
            return """
            \(raw: prefix)func asJSONValue() -> JSON {
                \(raw: typeCheckCode)
                return JSON([\(raw: body)])
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

    // 6. CodingKeys enum 宏实现（仅当 ignoreComplexXPath 时需要）
    // 为每个属性生成 CodingKeys，多 key 属性生成多个 case（主键 + 回退键）
    // 嵌套路径需要为父路径生成 CodingKeys
    func genCodingKeys() throws -> DeclSyntax {
        var keyCases: [String] = []
        var nestedParentKeys: Set<String> = []
        var allCaseNames: Set<String> = []

        for member in memberProperties {
            // 检查是否有嵌套路径
            if let nestedKey = member.nestedPathKey,
               let (parentPath, leafKey) = member.parseNestedPath(nestedKey) {
                // 嵌套路径：添加父路径的 CodingKeys
                let pathComponents = parentPath.split(separator: "/").map { String($0) }
                for component in pathComponents {
                    nestedParentKeys.insert(component)
                }
                // 叶子节点的键 - 使用属性名作为 case 名称，leafKey 作为字符串值
                keyCases.append("case \(member.name) = \"\(leafKey)\"")
                allCaseNames.insert(member.name)
            } else {
                // 简单键：直接生成
                let keys = member.codableKeys
                keyCases.append("case \(member.codableKey) = \"\(keys[0])\"")
                allCaseNames.insert(member.codableKey)
                // 回退键
                for index in 1..<keys.count {
                    let fallbackKeyName = "\(member.codableKey)_\(index)"
                    keyCases.append("case \(fallbackKeyName) = \"\(keys[index])\"")
                    allCaseNames.insert(fallbackKeyName)
                }
            }
        }

        // 添加嵌套路径的父级 CodingKeys，并检测冲突
        for nestedKey in nestedParentKeys.sorted() {
            // 检测冲突：父级名称是否与已有 case 名称重复
            if allCaseNames.contains(nestedKey) {
                throw ZTASTError("CodingKey conflict: '\(nestedKey)' conflicts with an existing property or CodingKey. " +
                               "When using nested path like 'xxx/\(nestedKey)/yyy', the parent key '\(nestedKey)' " +
                               "cannot be used as a property name. Please rename the property or use a different nested path.")
            }
            keyCases.append("case \(nestedKey) = \"\(nestedKey)\"")
            allCaseNames.insert(nestedKey)
        }

        let keys = keyCases.joined(separator: "\n")
        return """
        enum CodingKeys: String, CodingKey {
        \(raw: keys)
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
