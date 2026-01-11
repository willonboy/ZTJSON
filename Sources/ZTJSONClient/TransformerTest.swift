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
        return json.int
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
}
