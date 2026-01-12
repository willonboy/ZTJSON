//
//  ZTParser.swift
//  ZTJSON
//
//  Created by zt on 2025/3/23.
//

import Foundation
import SwiftyJSON

public protocol ZTJSONInitializable {
    init(from: JSON) throws
}

public protocol ZTTransform {
    associatedtype T

    static func transform(_ json: JSON) -> T?
}




// MARK: - SwiftyJSON extension

public extension JSON {
    /// XPath 查询最大深度限制，防止恶意构造的 JSON 导致性能问题
    static let xpathMaxDepth = 100

    /// 统一查询入口, 通过 XPath 风格的路径查询 JSON 数据
    /// - 常规查询: find("/0/address/street")
    /// - 批量查询: find("/*/address/geo")
    func find(xpath: String) -> JSON? {
        // 检查路径深度（组件数量）
        let components = xpath.components(separatedBy: "/").filter { !$0.isEmpty }
        guard components.count <= JSON.xpathMaxDepth else {
            print("[ZTJSON] Warning: XPath query exceeded maximum depth of \(JSON.xpathMaxDepth): '\(xpath)'")
            return nil
        }

        if xpath.contains("*") {
            return findAllLogic(xpath: xpath)
        }
        return findSingleLogic(xpath: xpath)
    }

    /// 通过 XPath 风格的路径查询 JSON 数据
    /// 示例: "users/0/name" 或 "data/items/-1/value" (负数表示从末尾倒数)
    func findSingleLogic(xpath: String) -> JSON? {
        let components = xpath.components(separatedBy: "/").filter { !$0.isEmpty }
        guard !components.isEmpty else { return self }
        return find(with: components)
    }

    // 批量查询逻辑
    func findAllLogic(xpath: String) -> JSON? {
        let components = xpath.components(separatedBy: "/").filter { !$0.isEmpty }
        guard !components.isEmpty else { return nil }

        var results: [JSON] = [self]
        var lastComponentWasWildcard = false

        for (index, component) in components.enumerated() {
            var newResults: [JSON] = []

            for current in results {
                switch (component, current.type) {
                case ("*", .array):
                    newResults += current.arrayValue
                    lastComponentWasWildcard = true
                case ("*", .dictionary):
                    newResults += current.dictionaryValue.values
                    lastComponentWasWildcard = true
                default:
                    if let next = current.findSingleLogic(xpath: component) {
                        newResults.append(next)
                    }
                    lastComponentWasWildcard = false
                }
            }

            // 如果是最后一个组件，返回结果（可能是空数组）
            if index == components.count - 1 {
                return JSON(newResults)
            }

            // 如果中间组件没有匹配：
            // - 如果上一个组件是通配符，说明通配符匹配到 0 个元素，继续处理
            // - 如果上一个组件不是通配符，说明路径不存在，返回 nil
            if newResults.isEmpty {
                if !lastComponentWasWildcard {
                    return nil
                }
                // 通配符匹配到 0 个元素，继续用空结果处理后续组件
            }

            results = newResults
        }

        return JSON(results)
    }

    private func find(with pathComponents: [String]) -> JSON? {
        var current = self
        for component in pathComponents {
            switch current.type {
            case .array:
                guard let index = Int(component) else { return nil }
                let array = current.arrayValue

                let validIndex = array.validIndex(from: index)
                guard let validIndex else { return nil }

                current = array[validIndex]

            case .dictionary:
                guard let dict = current.dictionary,
                      let next = dict[component] else {
                    return nil // 键不存在直接返回
                }
                current = next

                // 中间节点为 null 时终止遍历
                if current == .null && !isLastComponent(component, in: pathComponents) {
                    return nil
                }

            default:
                return nil // 非集合类型无法继续遍历
            }
        }
        return current // 直接返回最终结果
    }

    private func isLastComponent(_ component: String, in path: [String]) -> Bool {
        path.last == component
    }
}

extension Array {
    func validIndex(from rawIndex: Int) -> Int? {
        guard !isEmpty else { return nil }
        
        return rawIndex >= 0 ?
            (rawIndex < count ? rawIndex : nil) :
            (count + rawIndex >= 0 ? count + rawIndex : nil)
    }
}






// MARK: - ZTJSONInitializable implementation

/// JSON 解析错误
public enum ZTJSONError: Error, LocalizedError {
    /// 通用错误
    /// - Parameters:
    ///   - code: 错误码
    ///   - msg: 错误消息
    case error(code: Int, msg: String)

    // MARK: - 错误码定义

    public struct Code {
        /// 类型不匹配
        public static let typeMismatch = 1001
        /// 缺少必需字段
        public static let missingKey = 1002
        /// 值无效
        public static let invalidValue = 1003
        /// 数据格式错误
        public static let invalidData = 1004
    }

    // MARK: - 便捷属性

    /// 错误码
    public var code: Int {
        switch self {
        case .error(let code, _): return code
        }
    }

    /// 错误消息
    public var message: String {
        switch self {
        case .error(_, let msg): return msg
        }
    }

    /// LocalizedError 协议
    public var errorDescription: String? {
        return message
    }
}

// MARK: - 便捷初始化器

extension ZTJSONError {
    /// 类型不匹配错误
    public static func typeMismatch(expected: String, actual: String, key: String? = nil) -> ZTJSONError {
        let msg: String
        if let key = key {
            msg = "Type mismatch for key '\(key)': expected \(expected), got \(actual)"
        } else {
            msg = "Type mismatch: expected \(expected), got \(actual)"
        }
        return .error(code: Code.typeMismatch, msg: msg)
    }

    /// 缺少必需字段错误
    public static func missingKey(key: String) -> ZTJSONError {
        return .error(code: Code.missingKey, msg: "Missing required key: '\(key)'")
    }

    /// 值无效错误
    public static func invalidValue(key: String? = nil, reason: String) -> ZTJSONError {
        let msg: String
        if let key = key {
            msg = "Invalid value for key '\(key)': \(reason)"
        } else {
            msg = "Invalid value: \(reason)"
        }
        return .error(code: Code.invalidValue, msg: msg)
    }
}

extension Bool: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.bool else {
            throw ZTJSONError.typeMismatch(expected: "Bool", actual: "\(json.type)")
        }
        self = t
    }
}

extension Int: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int else {
            throw ZTJSONError.typeMismatch(expected: "Int", actual: "\(json.type)")
        }
        self = t
    }
}

extension Int8: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int8 else {
            throw ZTJSONError.typeMismatch(expected: "Int8", actual: "\(json.type)")
        }
        self = t
    }
}

extension Int16: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int16 else {
            throw ZTJSONError.typeMismatch(expected: "Int16", actual: "\(json.type)")
        }
        self = t
    }
}

extension Int32: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int32 else {
            throw ZTJSONError.typeMismatch(expected: "Int32", actual: "\(json.type)")
        }
        self = t
    }
}

extension Int64: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int64 else {
            throw ZTJSONError.typeMismatch(expected: "Int64", actual: "\(json.type)")
        }
        self = t
    }
}

extension UInt: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt else {
            throw ZTJSONError.typeMismatch(expected: "UInt", actual: "\(json.type)")
        }
        self = t
    }
}

extension UInt8: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt8 else {
            throw ZTJSONError.typeMismatch(expected: "UInt8", actual: "\(json.type)")
        }
        self = t
    }
}

extension UInt16: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt16 else {
            throw ZTJSONError.typeMismatch(expected: "UInt16", actual: "\(json.type)")
        }
        self = t
    }
}

extension UInt32: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt32 else {
            throw ZTJSONError.typeMismatch(expected: "UInt32", actual: "\(json.type)")
        }
        self = t
    }
}

extension UInt64: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt64 else {
            throw ZTJSONError.typeMismatch(expected: "UInt64", actual: "\(json.type)")
        }
        self = t
    }
}

extension Double: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.double else {
            throw ZTJSONError.typeMismatch(expected: "Double", actual: "\(json.type)")
        }
        self = t
    }
}

extension Float: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.float else {
            throw ZTJSONError.typeMismatch(expected: "Float", actual: "\(json.type)")
        }
        self = t
    }
}

extension String: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.string else {
            throw ZTJSONError.typeMismatch(expected: "String", actual: "\(json.type)")
        }
        self = t
    }
}

extension Array: ZTJSONInitializable where Element: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard json.type == .array else {
            throw ZTJSONError.typeMismatch(expected: "Array", actual: "\(json.type)")
        }
        self = try json.arrayValue.map { try Element(from: $0) }
    }
}

extension Dictionary: ZTJSONInitializable where Key == String, Value: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard json.type == .dictionary else {
            throw ZTJSONError.typeMismatch(expected: "Dictionary", actual: "\(json.type)")
        }
        var result = [String: Value]()
        for (key, subJson) in json.dictionaryValue {
            do {
                result[key] = try Value(from: subJson)
            } catch {
                throw ZTJSONError.invalidValue(key: key, reason: error.localizedDescription)
            }
        }
        self = result
    }
}

extension Optional: ZTJSONInitializable where Wrapped: ZTJSONInitializable {
    public init(from json: JSON) throws {
        self = try? Wrapped.init(from: json)
    }
}



private protocol OptionalTagProtocol {}
extension Optional: OptionalTagProtocol {}

public func isOptionalValue<T: Any>(_ value: T) -> Bool {
    Mirror(reflecting: value).displayStyle == .optional
}

public func isOptionalType<T>(_ type: T.Type) -> Bool {
    type is OptionalTagProtocol.Type
}

//var userList: [User]? = []
//print("isOptionalValue", isOptionalValue(userList))           // true
//print("isOptionalType", isOptionalType(type(of: userList)))   // true
//print("isOptionalType", isOptionalType([Address]?.self))      // true









public protocol ZTJSONExportable {
    func asJSONValue() -> JSON
}

extension Int: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension Int8: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension Int16: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension Int32: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension Int64: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension UInt: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension UInt8: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension UInt16: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension UInt32: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension UInt64: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension Float: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension Double: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension Bool: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension String: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self) }
}

extension Optional: ZTJSONExportable where Wrapped: ZTJSONExportable {
    public func asJSONValue() -> JSON {
        switch self {
        case .some(let val): return val.asJSONValue()
        case .none: return JSON(NSNull())
        }
    }
}

extension Array: ZTJSONExportable where Element: ZTJSONExportable {
    public func asJSONValue() -> JSON {
        JSON(self.map { $0.asJSONValue() })
    }
}

extension Dictionary: ZTJSONExportable where Key == String, Value: ZTJSONExportable {
    public func asJSONValue() -> JSON {
        JSON(self.mapValues { $0.asJSONValue() })
    }
}

// MARK: - ZTAPIParam Protocol

/// API 参数枚举协议
public protocol ZTAPIParamProtocol: Sendable {
    /// 参数对应的键名
    var key: String { get }
    /// 参数值
    var value: Sendable { get }

    /// 数据发送前校验参数；如是否缺失必要参数；某参数是否合法
    static func isValid(_ params: [String: Sendable]) -> Bool
}

public extension ZTAPIParamProtocol {
    /// 默认实现：总是返回 true
    static func isValid(_ params: [String: Sendable]) -> Bool { true }
}
