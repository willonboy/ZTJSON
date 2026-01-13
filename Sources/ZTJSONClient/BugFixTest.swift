import Foundation
import ZTJSON
import SwiftyJSON

// MARK: - Bug Fix 测试用例
//
// 这个文件测试修复的两个问题：
// 1. 问题2：Subclass encode 方法冗余 - 两个分支代码完全相同
// 2. 问题4：CodingKeys 冲突 - 属性名与嵌套父级相同时的冲突检测

// MARK: - 测试1：嵌套路径与属性名冲突（应该编译失败）

// 这个测试用例会触发 CodingKey 冲突错误
// 预期编译错误：CodingKey conflict: 'address' conflicts with an existing property or CodingKey.
// 取消下面的注释来验证冲突检测：
/*
@ZTJSON
struct CodingKeyConflictTest {
    var address: String = ""  // 属性名 "address" 与嵌套路径的父级 "address" 冲突

    @ZTJSONKey("address/city")
    var city: String = ""
}
*/

// MARK: - 测试2：嵌套路径与属性名不冲突（应该编译成功）

@ZTJSON
struct NestedPathNoConflictTest: Codable {
    var location: String = ""

    @ZTJSONKey("address/city")
    var cityName: String = "Unknown"
}

// MARK: - 测试3：多级嵌套路径

@ZTJSON
struct MultiLevelNestedPathTest: Codable {
    var name: String = ""

    @ZTJSONKey("data/user/profile/website")
    var website: URL?
}

// MARK: - 测试4：多个嵌套路径共享父级（不冲突）

@ZTJSON
struct SharedParentNestedPathTest: Codable {
    @ZTJSONKey("geo/lat")
    var latitude: Double = 0.0

    @ZTJSONKey("geo/lng")
    var longitude: Double = 0.0
}

// MARK: - 测试5：嵌套路径 + Transformer + Codable

extension URL: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let urlString = json.string else {
            throw ZTJSONError.typeMismatch(expected: "String (URL)", actual: "\(json.type)")
        }
        guard let url = URL(string: urlString) else {
            throw ZTJSONError.invalidValue(reason: "Invalid URL string")
        }
        self = url
    }
}

struct URLTransformer2: ZTTransform {
    static func transform(_ json: JSON) -> URL? {
        guard let urlString = json.string else { return nil }
        return URL(string: urlString)
    }
}

@ZTJSON
struct NestedPathWithTransformerTest: Codable {
    var name: String = ""

    @ZTJSONTransformer(URLTransformer2.self)
    @ZTJSONKey("user/profile/website")
    var website: URL?
}

// MARK: - 测试6：Subclass encode 方法

@ZTJSON
class BaseClass: Codable {
    var baseProp: String = ""
}

@ZTJSONSubclass
class DerivedClass: BaseClass {
    var derivedProp: String = ""
}

// MARK: - 测试函数

func runBugFixTests() {
    print("\n=== Bug Fix 测试 ===\n")

    // 测试1：嵌套路径无冲突 - Codable 解码
    print("[测试1] 嵌套路径无冲突 - Codable 解码")
    if let data = """
    {
        "location": "Shanghai",
        "address": {
            "city": "Beijing"
        }
    }
    """.data(using: .utf8) {
        do {
            let obj = try JSONDecoder().decode(NestedPathNoConflictTest.self, from: data)
            print("  location: \(obj.location)")
            print("  cityName: \(obj.cityName)")
            let success = obj.location == "Shanghai" && obj.cityName == "Beijing"
            print(success ? "  ✅ 嵌套路径 Codable 解码成功" : "  ❌ 解码失败")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试2：嵌套路径无冲突 - ZTJSON 初始化
    print("\n[测试2] 嵌套路径无冲突 - ZTJSON 初始化")
    let json1 = JSON([
        "location": "Shanghai",
        "address": ["city": "Beijing"]
    ])
    do {
        let obj1 = try NestedPathNoConflictTest(from: json1)
        print("  location: \(obj1.location)")
        print("  cityName: \(obj1.cityName)")
        print("  ✅ 嵌套路径 ZTJSON 初始化成功")
    } catch {
        print("  ❌ 初始化失败: \(error)")
    }

    // 测试3：多级嵌套路径
    print("\n[测试3] 多级嵌套路径")
    let json2 = JSON([
        "name": "Test User",
        "data": ["user": ["profile": ["website": "https://example.com"]]]
    ])
    do {
        let obj2 = try MultiLevelNestedPathTest(from: json2)
        print("  name: \(obj2.name)")
        print("  website: \(obj2.website?.absoluteString ?? "nil")")
        let success = obj2.website?.absoluteString == "https://example.com"
        print(success ? "  ✅ 多级嵌套路径成功" : "  ❌ 多级嵌套路径失败")
    } catch {
        print("  ❌ 初始化失败: \(error)")
    }

    // 测试4：共享父级的嵌套路径
    print("\n[测试4] 共享父级的嵌套路径")
    let json3 = JSON([
        "geo": ["lat": 31.2304, "lng": 121.4737]
    ])
    do {
        let obj3 = try SharedParentNestedPathTest(from: json3)
        print("  latitude: \(obj3.latitude)")
        print("  longitude: \(obj3.longitude)")
        let success = obj3.latitude == 31.2304 && obj3.longitude == 121.4737
        print(success ? "  ✅ 共享父级嵌套路径成功" : "  ❌ 共享父级嵌套路径失败")
    } catch {
        print("  ❌ 初始化失败: \(error)")
    }

    // 测试5：嵌套路径 + Transformer
    print("\n[测试5] 嵌套路径 + Transformer + Codable")
    if let data = """
    {
        "name": "User",
        "user": {
            "profile": {
                "website": "https://test.com"
            }
        }
    }
    """.data(using: .utf8) {
        do {
            let obj4 = try JSONDecoder().decode(NestedPathWithTransformerTest.self, from: data)
            print("  name: \(obj4.name)")
            print("  website: \(obj4.website?.absoluteString ?? "nil")")
            let success = obj4.website?.absoluteString == "https://test.com"
            print(success ? "  ✅ 嵌套路径 + Transformer + Codable 成功" : "  ❌ 测试失败")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试6：Subclass encode 方法
    print("\n[测试6] Subclass encode 方法")
    let derived = DerivedClass()
    derived.baseProp = "base"
    derived.derivedProp = "derived"
    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(derived)
        if let jsonStr = String(data: data, encoding: .utf8) {
            print("  encoded: \(jsonStr)")
            // 验证编码包含父类和子类属性
            let success = jsonStr.contains("baseProp") && jsonStr.contains("derivedProp")
            print(success ? "  ✅ Subclass encode 包含所有属性" : "  ❌ Subclass encode 缺少属性")
        }
    } catch {
        print("  ❌ 编码失败: \(error)")
    }

    // 测试7：Subclass decode 方法
    print("\n[测试7] Subclass decode 方法")
    if let data = """
    {
        "baseProp": "parent",
        "derivedProp": "child"
    }
    """.data(using: .utf8) {
        do {
            let decoded = try JSONDecoder().decode(DerivedClass.self, from: data)
            print("  baseProp: \(decoded.baseProp)")
            print("  derivedProp: \(decoded.derivedProp)")
            let success = decoded.baseProp == "parent" && decoded.derivedProp == "child"
            print(success ? "  ✅ Subclass decode 成功" : "  ❌ Subclass decode 失败")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试8：asJSONValue export 方法
    print("\n[测试8] asJSONValue export 方法")
    let exportTest = NestedPathNoConflictTest(location: "Test", cityName: "Shanghai")
    let exported = exportTest.asJSONValue()
    print("  exported: \(exported.rawString() ?? "")")
    let exportSuccess = exported["location"].string == "Test" && exported["cityName"].string == "Shanghai"
    print(exportSuccess ? "  ✅ asJSONValue export 成功" : "  ❌ asJSONValue export 失败")

    print("\n=== Bug Fix 测试完成 ===\n")
}
