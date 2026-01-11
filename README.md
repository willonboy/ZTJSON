# ZTJSON

基于 Swift 宏的高性能 JSON ORM 库，支持 XPath 语法和标准 Codable 协议。

## 特性

- **编译时宏** - 零运行时开销，代码生成在编译时完成
- **XPath 支持** - 灵活的路径语法（`geo/lat`、`*/email`、`users/0/name` 等）
- **Codable 兼容** - 完全支持 Codable 协议，可与系统 API 无缝集成
- **多 Key 回退** - 支持配置多个候选键名，自动回退
- **嵌套路径** - 简单嵌套路径自动使用 `nestedContainer` 高效解析
- **Let 属性支持** - 通过 `@ZTJSONLetDefValue` 为 let 常量属性配置默认值
- **自定义转换** - 通过 Transformer 支持任意类型转换
- **Enum 支持** - 自定义 Enum 解析逻辑
- **灵活配置** - 丰富的宏属性，避免 Model 膨胀

## 安装

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/your-repo/ZTJSON.git", from: "1.0.0")
]
```

## 快速开始

```swift
import ZTJSON

@ZTJSON
struct User {
    var id: Int = 0
    var name: String = ""
    var email: String = ""
}

// 解析
let user = try User(from: json)

// Codable 支持
let user = try JSONDecoder().decode(User.self, from: jsonData)
```

## 核心用法

### 1. 基础属性

```swift
@ZTJSON
struct User {
    // 常规属性
    var id: Int = 0
    var name: String = ""

    // Optional 属性
    var address: Address?

    // 带默认值的 let 属性
    @ZTJSONLetDefValue(0)
    let userId: Int
}
```

### 2. XPath 路径支持

```swift
@ZTJSON
struct Address {
    // 简单嵌套路径 
    @ZTJSONKey("geo/lat")
    var lat: Double = 0

    @ZTJSONKey("geo/lng")
    var lng: Double = 0

    // 复杂路径 - 使用 JSON.find() 解析
    @ZTJSONKey("users/0/name")
    var firstName: String = ""

    // 通配符
    @ZTJSONKey("*/email")
    var anyEmail: String = ""

    // 负数索引
    @ZTJSONKey("users/-1/id")  // 倒数第一个
    var lastUserId: Int = 0
}
```

### 3. 多 Key 回退

```swift
@ZTJSON
struct Company {
    // 尝试 "bs"，不存在则回退到 "business"
    @ZTJSONKey("bs", "business")
    var business: String = ""

    // Codable 解码时依次尝试每个键
    // 编码时使用第一个键 "bs"
}
```

### 4. 自定义 Transformer

```swift
// 定义 Transformer
struct TransformURL: ZTTransform {
    static func transform(_ json: JSON) -> URL? {
        URL(string: json.stringValue)
    }
}

struct TransformDouble: ZTTransform {
    static func transform(_ json: JSON) -> Double? {
        json.doubleValue
    }
}

@ZTJSON
struct User {
    @ZTJSONTransformer(TransformURL.self)
    var website: URL?

    @ZTJSONTransformer(TransformDouble.self)
    @ZTJSONKey("geo/lat")
    var latitude: Double = 0
}
```

### 5. Enum 解析

```swift
enum Animal: String, ZTJSONInitializable {
    init(from json: JSON) throws {
        guard let rawValue = json.string else {
            throw NSError(domain: "Animal", code: 0)
        }
        guard let animal = Animal(rawValue: rawValue) else {
            throw NSError(domain: "Animal", code: 1)
        }
        self = animal
    }

    case dog, cat, fish
}

extension Animal: ZTJSONExportable {
    func asJSONValue() -> JSON {
        JSON(self.rawValue)
    }
}

@ZTJSON
struct User {
    var pet: Animal = .dog
}
```

### 6. 忽略字段

```swift
@ZTJSON
struct User {
    var id: Int = 0
    var name: String = ""

    // 此字段不会被序列化/反序列化
    @ZTJSONIgnore
    var temporaryData: String = ""
}
```

### 7. 类继承支持

```swift
@ZTJSON
open class BaseAddress {
    var street = ""
    var city = ""
}

@ZTJSONSubclass  // 使用 @ZTJSONSubclass
open class Address: BaseAddress {
    @ZTJSONKey("geo/lat")
    var lat: Double = 0

    @ZTJSONKey("geo/lng")
    var lng: Double = 0
}
```

## Codable 集成

### ignoreComplexXPath 参数

```swift
// 默认行为（推荐）
@ZTJSON  // 等同于 @ZTJSON(ignoreComplexXPath: true)
struct User {
    // 简单键 -> Codable keyedContainer
    var name: String = ""

    // 嵌套路径 -> Codable nestedContainer
    @ZTJSONKey("geo/lat")
    var lat: Double = 0

    // 复杂 XPath -> JSON.find() (base64)
    @ZTJSONKey("*/email")
    var anyEmail: String = ""
}

// 完全使用 JSON.find() 方式
@ZTJSON(ignoreComplexXPath: false)
struct User {
    @ZTJSONKey("geo/lat")
    var lat: Double = 0  // 使用 JSON.find() 解析
}
```

### XPath 类型判定

| XPath 类型 | 示例                        | ignoreComplexXPath: true | ignoreComplexXPath: false |
| ---------- | --------------------------- | ------------------------ | ------------------------- |
| 简单键     | `"name"`                    | Codable                  | JSON.find()               |
| 嵌套路径   | `"geo/lat"`                 | nestedContainer          | JSON.find()               |
| 复杂路径   | `"*/email"`, `users/0/name` | JSON.find()              | JSON.find()               |

### 生成的 CodingKeys

```swift
@ZTJSON
struct Address {
    @ZTJSONKey("geo/lat")
    var lat: Double = 0

    @ZTJSONKey("bs", "business")
    var business: String = ""
}

// 自动生成的 CodingKeys：
enum CodingKeys: String, CodingKey {
    case lat = "lat"           // 叶子节点
    case business = "bs"       // 主键
    case business_1 = "business"  // 回退键
    case geo = "geo"           // 父级容器
}
```

### Codable 编解码

```swift
let encoder = JSONEncoder()
let data = try encoder.encode(user)

let decoder = JSONDecoder()
let user = try decoder.decode(User.self, from: data)
```

## 导出 JSON

```swift
@ZTJSON
struct User {
    var id: Int = 0
    var name: String = ""
}

let user = User(id: 1, name: "Alice")
let json = user.asJSONValue()
print(json.rawString())
// 输出: {"id":1,"name":"Alice"}
```

## 宏属性参考

| 宏                        | 用途                            |
| ------------------------- | ------------------------------- |
| `@ZTJSON`                 | struct 的主宏                   |
| `@ZTJSONSubclass`         | class 的主宏（支持继承）        |
| `@ZTJSONKey(...)`         | 指定 JSON 键名，支持多 key 回退 |
| `@ZTJSONTransformer(...)` | 自定义类型转换                  |
| `@ZTJSONLetDefValue(...)` | let 属性的默认值                |
| `@ZTJSONIgnore`           | 忽略字段                        |

---

## 高级用法

### XPathParser - 动态解析多个路径

```swift
import ZTJSON
import SwiftyJSON

// 定义 XPath 解析器
struct XPathParser: Equatable, Hashable {
    let xpath: String
    let type: any ZTJSONInitializable.Type
    let isOptional: Bool

    init(_ xpath: String = "/", type: any ZTJSONInitializable.Type, _ isOptional: Bool = true) {
        self.xpath = xpath.isEmpty ? "/" : xpath
        self.type = type
        self.isOptional = isOptional
    }
}

// 扩展 Dictionary 支持 XPath 下标访问
extension Dictionary where Key == String, Value == any ZTJSONInitializable {
    subscript<T: ZTJSONInitializable>(parser: XPathParser) -> T? {
        guard let value = self[parser.xpath] else { return nil }
        return value as? T
    }

    subscript<T: ZTJSONInitializable>(xpath path: String) -> T? {
        guard let value = self[path] else { return nil }
        return value as? T
    }
}

// 从网络 API 解析多个数据结构
@discardableResult
func get(confs: [XPathParser]) -> Result<[String: any ZTJSONInitializable], XPathParserError> {
    if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
        if let d = try? Data(contentsOf: url) {
            if let json = try? JSON(data: d) {
                var r: [String: any ZTJSONInitializable] = [:]
                for p in confs {
                    if let j = json.find(xpath: p.xpath), let t = try? p.type.init(from: j) {
                        r[p.xpath] = t
                    } else if !p.isOptional {
                        return Result.failure(XPathParserError("Parse xpath failed"))
                    }
                }
                return Result.success(r)
            }
        }
    }
    return Result.failure(XPathParserError("Parse xpath failed"))
}
```

### 使用示例 - 同时解析多个数据

```swift
// 解析根路径 => [User]
get(confs: [.init(type: [User].self)])

// 解析 "/0/address" => Address
get(confs: [.init("/0/address", type: Address.self)])

// 解析 "/*/address" => [Address]
get(confs: [.init("/*/address", type: [Address].self)])

// 解析 "/*/address/geo" => [Geo]
get(confs: [.init("/*/address/geo", type: [Geo].self)])

// 同时解析多个路径
get(confs: [
    .init(type: [User].self),           // 根路径 => [User]
    .init("/0/address", type: Address.self),  // 第一个用户的地址
    .init("/*/address", type: [Address].self), // 所有用户的地址
    .init("/*/address/geo", type: [Geo].self)  // 所有地址的坐标
])
```

### 嵌套类结构

```swift
// 嵌套类 - 注意内部类也需要 @ZTJSON
@ZTJSON
class User {
    @MainActor
    static var clsName = "User"  // 静态属性会被忽略

    lazy var uuid = { UUID().uuidString }()  // lazy 属性会被忽略

    @ZTJSONLetDefValue(0)
    let id: Int

    @ZTJSONLetDefValue("")
    let name: String

    @ZTJSONTransformer(TransformHttp.self)
    var website: URL?

    var company: Company = .init()
    var address: Address?

    // 内部类
    @ZTJSON
    class A {
        var val3: [String: String] = [:]
        var val4: [Int] = [123] + [4]
    }
}
```

### 深层嵌套路径

```swift
@ZTJSON
class NestAddress {
    @ZTJSONKey("address/street")
    var street = ""

    @ZTJSONKey("address/suite")
    var suite: String = ""

    @ZTJSONKey("address/city")
    var city = ""

    @ZTJSONKey("address/zipcode")
    var zipcode: String = ""

    @ZTJSONTransformer(TransformDouble.self)
    @ZTJSONKey("address/geo/lat")
    var lat: Double = 0

    @ZTJSONTransformer(TransformDouble.self)
    @ZTJSONKey("address/geo/lng")
    var lng = 0.0
}
```

---

## 注意事项

1. **Codable 优先** - 默认情况下 (`ignoreComplexXPath: true`)，简单键和嵌套路径使用高效的 Codable 实现
2. **复杂 XPath** - 通配符、数组索引等复杂路径会回退到 JSON.find() 方式
3. **多 Key 编码** - 多 key 配置时，编码使用第一个键，解码依次尝试所有键
4. **类型推断** - var 属性会自动推断类型，let 属性需要显式类型或默认值
5. **Optional 解析** - Optional 属性解析失败时返回 nil，不会抛出错误

## 许可证

MIT License
