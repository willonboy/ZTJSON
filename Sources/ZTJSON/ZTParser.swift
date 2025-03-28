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
    /// 通过 XPath 风格的路径查询 JSON 数据
    /// 示例: "users/0/name" 或 "data/items/-1/value" (负数表示从末尾倒数)
    func find(xpath: String) -> JSON? {
        let components = xpath.components(separatedBy: "/").filter { !$0.isEmpty }
        guard !components.isEmpty else { return self }
        return find(with: components)
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

public enum ZTJSONError: Error {
    case invalidData
}

extension Bool: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.bool else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension Int: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension Int8: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int8 else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension Int16: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int16 else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension Int32: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int32 else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension Int64: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.int64 else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension UInt: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension UInt8: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt8 else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension UInt16: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt16 else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension UInt32: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt32 else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension UInt64: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.uInt64 else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension Double: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.double else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension Float: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.float else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension String: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let t = json.string else {
            throw ZTJSONError.invalidData
        }
        self = t
    }
}

extension Array: ZTJSONInitializable where Element: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard json.type == .array else {
            throw ZTJSONError.invalidData
        }
        
        self = try json.arrayValue.map { try Element(from: $0) }
    }
}

extension Dictionary: ZTJSONInitializable where Key == String, Value: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard json.type == .dictionary else {
            throw ZTJSONError.invalidData
        }

        var result = [String: Value]()
        for (key, subJson) in json.dictionaryValue {
            do {
                result[key] = try Value(from: subJson)
            } catch {
                throw ZTJSONError.invalidData
            }
        }
        self = result
    }
}
