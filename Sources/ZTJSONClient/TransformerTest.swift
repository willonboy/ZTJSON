import Foundation
import ZTJSON
@preconcurrency import SwiftyJSON

// MARK: - 测试 Transformer 支持

struct URLTransformer: ZTTransform {
    static func transform(_ json: JSON) -> URL? {
        guard let urlString = json.string else { return nil }
        return URL(string: urlString)
    }
}

struct IntTransformer: ZTTransform {
    static func transform(_ json: JSON) -> Int? {
        // 先尝试直接获取 Int
        if let intValue = json.int {
            return intValue
        }
        // 如果是字符串，尝试转换
        if let stringValue = json.string {
            return Int(stringValue)
        }
        return nil
    }
}

// 测试 @ZTJSONTransformer 的 Codable 支持
@ZTJSON
struct TransformerTest: Codable {
    var name: String = "Test"

    @ZTJSONTransformer(URLTransformer.self)
    var website: URL?

    @ZTJSONTransformer(IntTransformer.self)
    var count: Int = 0
}

// MARK: - 测试 XPath 支持

@ZTJSON
struct XPathTest: Codable {
    var name: String = ""

    @ZTJSONKey("nested/value")
    var nestedValue: String = "default"

    @ZTJSONKey("address/city")
    var city: String = "Unknown"
}

// MARK: - 测试 Transformer + XPath 组合

@ZTJSON
struct TransformerAndXPathTest: Codable {
    var name: String = ""

    @ZTJSONTransformer(IntTransformer.self)
    @ZTJSONKey("nested/count")
    var nestedCount: Int = 0

    @ZTJSONTransformer(URLTransformer.self)
    @ZTJSONKey("data/website")
    var website: URL?
}

// MARK: - 测试 Codable + Transformer 新功能

// 测试用的结构体（必须定义在函数外，因为宏不能用于局部类型）

// 多 Key 回退 + Transformer
@ZTJSON
struct MultiKeyTransformerTest: Codable {
    @ZTJSONTransformer(IntTransformer.self)
    @ZTJSONKey("id", "user_id", "userId")
    var userId: Int = 0
}

// 深层嵌套路径 + Transformer
@ZTJSON
struct DeepNestedTransformerTest: Codable {
    @ZTJSONTransformer(URLTransformer.self)
    @ZTJSONKey("data/user/profile/website")
    var website: URL?
}

// 多个 Transformer 属性
@ZTJSON
struct MultiTransformerTest: Codable {
    @ZTJSONTransformer(URLTransformer.self)
    var website: URL?

    @ZTJSONTransformer(IntTransformer.self)
    var count: Int = 0

    @ZTJSONTransformer(IntTransformer.self)
    var score: Int = 0

    @ZTJSONTransformer(URLTransformer.self)
    var avatar: URL?
}

// 嵌套路径 + Transformer
@ZTJSON
struct NestedTransformerTest: Codable {
    var name: String = ""

    @ZTJSONTransformer(IntTransformer.self)
    @ZTJSONKey("nested/count")
    var nestedCount: Int = 0
}

// Optional + Transformer
@ZTJSON
struct OptionalTransformerTest: Codable {
    @ZTJSONTransformer(URLTransformer.self)
    var website: URL?
}

// 默认值 + Transformer
@ZTJSON
struct DefaultTransformerTest: Codable {
    @ZTJSONTransformer(URLTransformer.self)
    var website: URL?

    @ZTJSONTransformer(IntTransformer.self)
    var count: Int = 0
}

// Codable 往返测试
@ZTJSON
struct RoundTripTest: Codable {
    var name: String = ""

    @ZTJSONTransformer(URLTransformer.self)
    var website: URL?

    @ZTJSONTransformer(IntTransformer.self)
    var count: Int = 0
}

func testCodableTransformerSupport() {
    print("\n=== Testing Codable + Transformer Support ===\n")

    // 测试 1: 简单键 + Transformer + Codable
    print("[测试 1] 简单键 + Transformer + Codable")
    if let data = """
    {
        "name": "Test User",
        "website": "https://example.com",
        "count": "42"
    }
    """.data(using: .utf8) {
        do {
            let obj = try JSONDecoder().decode(TransformerTest.self, from: data)
            let success = obj.website?.absoluteString == "https://example.com" && obj.count == 42
            print("  website: \(obj.website?.absoluteString ?? "nil")")
            print("  count: \(obj.count)")
            print(success ? "  ✅ 简单键 Transformer + Codable 正常工作" : "  ❌ 简单键 Transformer + Codable 失败")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试 2: 嵌套路径 + Transformer + Codable
    print("\n[测试 2] 嵌套路径 + Transformer + Codable")
    if let data = """
    {
        "name": "Nested Test",
        "nested": {
            "count": "999"
        }
    }
    """.data(using: .utf8) {
        do {
            let obj = try JSONDecoder().decode(NestedTransformerTest.self, from: data)
            let success = obj.nestedCount == 999
            print("  nestedCount: \(obj.nestedCount)")
            print(success ? "  ✅ 嵌套路径 Transformer + Codable 正常工作" : "  ❌ 嵌套路径 Transformer + Codable 失败")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试 3: Transformer + Optional + Codable
    print("\n[测试 3] Transformer + Optional + Codable")

    // 有值的情况
    if let data1 = """
    {"website": "https://test.com"}
    """.data(using: .utf8) {
        do {
            let obj1 = try JSONDecoder().decode(OptionalTransformerTest.self, from: data1)
            print("  有值: \(obj1.website?.absoluteString ?? "nil")")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 无值的情况
    if let data2 = """
    {"other": "value"}
    """.data(using: .utf8) {
        do {
            let obj2 = try JSONDecoder().decode(OptionalTransformerTest.self, from: data2)
            print("  无值: \(obj2.website?.absoluteString ?? "nil")")
            print("  ✅ Optional Transformer + Codable 正常工作")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试 4: Transformer 转换失败使用默认值
    print("\n[测试 4] Transformer 转换失败使用默认值")
    // 注意：Swift 的 URL(string:) 对于不带 scheme 的字符串也会创建 URL 对象
    // 所以这里使用 null 来测试转换失败的情况
    if let data = """
    {
        "website": null,
        "count": "not a number"
    }
    """.data(using: .utf8) {
        do {
            let obj = try JSONDecoder().decode(DefaultTransformerTest.self, from: data)
            print("  website (null): \(obj.website?.absoluteString ?? "nil") (应为 nil)")
            print("  count (无效数字): \(obj.count) (应为默认值 0)")
            let success = obj.website == nil && obj.count == 0
            print(success ? "  ✅ 转换失败时正确使用默认值" : "  ❌ 默认值处理不正确")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试 5: ZTJSON 方式与 Codable 方式结果一致
    print("\n[测试 5] ZTJSON 方式与 Codable 方式结果一致")
    if let data = """
    {
        "name": "Compare Test",
        "website": "https://compare.com",
        "count": "123"
    }
    """.data(using: .utf8) {
        do {
            // Codable 方式
            let codableObj = try JSONDecoder().decode(TransformerTest.self, from: data)

            // ZTJSON 方式
            let json = try JSON(data: data)
            let ztjsonObj = try TransformerTest(from: json)

            let match = codableObj.website == ztjsonObj.website && codableObj.count == ztjsonObj.count
            print("  Codable: website=\(codableObj.website?.absoluteString ?? "nil"), count=\(codableObj.count)")
            print("  ZTJSON: website=\(ztjsonObj.website?.absoluteString ?? "nil"), count=\(ztjsonObj.count)")
            print(match ? "  ✅ 两种方式结果一致" : "  ❌ 两种方式结果不一致")
        } catch {
            print("  ❌ 测试失败: \(error)")
        }
    }

    // 测试 6: 多 Key 回退 + Transformer
    print("\n[测试 6] 多 Key 回退 + Transformer")
    // 使用第二个回退键 user_id
    if let data1 = """
    {"user_id": "42"}
    """.data(using: .utf8) {
        do {
            let obj1 = try JSONDecoder().decode(MultiKeyTransformerTest.self, from: data1)
            print("  使用 user_id: \(obj1.userId)")
            let success = obj1.userId == 42
            print(success ? "  ✅ 多 Key 回退 + Transformer 正常工作" : "  ❌ 多 Key 回退失败")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试 7: 深层嵌套路径 + Transformer
    print("\n[测试 7] 深层嵌套路径 + Transformer")
    if let data = """
    {
        "data": {
            "user": {
                "profile": {
                    "website": "https://deep-nested.com"
                }
            }
        }
    }
    """.data(using: .utf8) {
        do {
            let obj = try JSONDecoder().decode(DeepNestedTransformerTest.self, from: data)
            print("  website: \(obj.website?.absoluteString ?? "nil")")
            let success = obj.website?.absoluteString == "https://deep-nested.com"
            print(success ? "  ✅ 深层嵌套路径 + Transformer 正常工作" : "  ❌ 深层嵌套路径失败")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试 8: 多个 Transformer 属性
    print("\n[测试 8] 多个 Transformer 属性")
    if let data = """
    {
        "website": "https://multi.com",
        "count": "100",
        "score": "95",
        "avatar": "https://avatar.com"
    }
    """.data(using: .utf8) {
        do {
            let obj = try JSONDecoder().decode(MultiTransformerTest.self, from: data)
            let success = obj.website?.absoluteString == "https://multi.com" &&
                         obj.count == 100 &&
                         obj.score == 95 &&
                         obj.avatar?.absoluteString == "https://avatar.com"
            print("  website: \(obj.website?.absoluteString ?? "nil")")
            print("  count: \(obj.count)")
            print("  score: \(obj.score)")
            print("  avatar: \(obj.avatar?.absoluteString ?? "nil")")
            print(success ? "  ✅ 多个 Transformer 属性正常工作" : "  ❌ 多个 Transformer 属性失败")
        } catch {
            print("  ❌ 解码失败: \(error)")
        }
    }

    // 测试 9: Codable 往返测试（encode -> decode）
    print("\n[测试 9] Codable 往返测试（encode -> decode）")
    let original = RoundTripTest(name: "RoundTrip", website: URL(string: "https://test.com"), count: 42)
    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RoundTripTest.self, from: data)
        let match = decoded.name == original.name &&
                     decoded.website == original.website &&
                     decoded.count == original.count
        print("  原始: name=\(original.name), website=\(original.website?.absoluteString ?? "nil"), count=\(original.count)")
        print("  解码: name=\(decoded.name), website=\(decoded.website?.absoluteString ?? "nil"), count=\(decoded.count)")
        print(match ? "  ✅ Codable 往返测试通过" : "  ❌ Codable 往返测试失败")
    } catch {
        print("  ❌ 往返测试失败: \(error)")
    }

    print("\n=== Codable + Transformer 测试完成 ===\n")
}

// MARK: - 运行测试

func runTransformerTests() {
    print("\n=== Testing Transformer Support ===\n")

// 测试1: 使用 ZTJSON 初始化（XPath 完全支持）
let jsonWithTransformer = JSON([
    "name": "Test User",
    "website": "https://example.com",
    "count": 42
])

if let testObj = try? TransformerTest(from: jsonWithTransformer) {
    print("✅ ZTJSON init with transformer works:")
    print("  name: \(testObj.name)")
    print("  website: \(String(describing: testObj.website))")
    print("  count: \(testObj.count)")
} else {
    print("❌ ZTJSON init failed")
}

// 测试2: 使用 Codable 初始化（transformer 支持）
let jsonString = """
{
    "name": "Codable User",
    "website": "https://codable.test",
    "count": 100
}
"""

if let data = jsonString.data(using: .utf8),
   let codableObj = try? JSONDecoder().decode(TransformerTest.self, from: data) {
    print("\n✅ Codable init with transformer works:")
    print("  name: \(codableObj.name)")
    print("  website: \(String(describing: codableObj.website))")
    print("  count: \(codableObj.count)")
} else {
    print("\n❌ Codable init with transformer failed")
}

// 测试3: XPath with ZTJSON
let xpathJson = JSON([
    "name": "XPath Test",
    "nested": ["value": "nested value here"],
    "address": ["city": "Shanghai"]
])

if let xpathObj = try? XPathTest(from: xpathJson) {
    print("\n✅ ZTJSON init with XPath works:")
    print("  name: \(xpathObj.name)")
    print("  nestedValue: \(xpathObj.nestedValue)")
    print("  city: \(xpathObj.city)")
} else {
    print("\n❌ ZTJSON init with XPath failed")
}

// 测试4: XPath with Codable (应该使用默认值并显示注释)
let xpathJsonString = """
{
    "name": "Codable XPath",
    "nested": {"value": "should be default in Codable"},
    "address": {"city": "Beijing"}
}
"""

if let xpathData = xpathJsonString.data(using: .utf8),
   let xpathCodableObj = try? JSONDecoder().decode(XPathTest.self, from: xpathData) {
    print("\n✅ Codable init with XPath (uses default value):")
    print("  name: \(xpathCodableObj.name)")
    print("  nestedValue: \(xpathCodableObj.nestedValue) (should be default)")
    print("  city: \(xpathCodableObj.city) (should be default)")
    print("\n  ℹ️  For full XPath support, use init(from: JSON) instead of Codable")
} else {
    print("\n❌ Codable init with XPath failed")
}

print("\n=== All Tests Complete ===\n")

// MARK: - 测试 Transformer + XPath 组合

print("\n=== Testing Transformer + XPath Combination ===\n")

let combinedJson = JSON([
    "name": "Combined Test",
    "nested": ["count": 999],
    "data": ["website": "https://combined.test"]
])

// 测试: ZTJSON init 支持 transformer + xpath
if let combinedObj = try? TransformerAndXPathTest(from: combinedJson) {
    print("✅ ZTJSON init with transformer + XPath works:")
    print("  name: \(combinedObj.name)")
    print("  nestedCount: \(combinedObj.nestedCount)")
    print("  website: \(String(describing: combinedObj.website))")
} else {
    print("❌ ZTJSON init with transformer + XPath failed")
}

// 测试: Codable init（会尝试直接解码，对于嵌套路径会失败并使用默认值）
let combinedJsonString = """
{
    "name": "Codable Combined",
    "nested": {"count": 888},
    "data": {"website": "https://codable.combined"}
}
"""

print("\n[DEBUG] Testing Codable init with transformer + XPath")
if let combinedData = combinedJsonString.data(using: .utf8) {
    do {
        let combinedCodableObj = try JSONDecoder().decode(TransformerAndXPathTest.self, from: combinedData)
        print("\n⚠️  Codable init with transformer + XPath:")
        print("  name: \(combinedCodableObj.name)")
        print("  nestedCount: \(combinedCodableObj.nestedCount) (may be default due to XPath)")
        print("  website: \(String(describing: combinedCodableObj.website)) (may be default due to XPath)")
        print("\n  ℹ️  For full transformer + XPath support, use init(from: JSON)")
    } catch {
        print("\n❌ Codable init with transformer + XPath failed: \(error)")
    }
} else {
    print("\n❌ Failed to convert JSON string to data")
}

print("\n=== Transformer + XPath Tests Complete ===\n")

// MARK: - 运行新的 Codable + Transformer 测试
testCodableTransformerSupport()
}
