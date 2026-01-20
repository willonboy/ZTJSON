import Foundation
import ZTJSON
import SwiftyJSON


let jsonStr = """
[
  {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "address": {
      "street": "Kulas Light",
      "suite": "Apt. 556",
      "city": "Gwenborough",
      "zipcode": "92998-3874",
      "geo": {
        "lat": "-37.3159",
        "lng": "81.1496"
      }
    },
    "phone": "1-770-736-8031 x56442",
    "website": "hildegard.org",
    "company": {
      "name": "Romaguera-Crona",
      "catchPhrase": "Multi-layered client-server neural-net",
      "bs": "harness real-time e-markets"
    }
  },
  {
    "id": 2,
    "name": "Ervin Howell",
    "username": "Antonette",
    "email": "Shanna@melissa.tv",
    "address": {
      "street": "Victor Plains",
      "suite": "Suite 879",
      "city": "Wisokyburgh",
      "zipcode": "90566-7771",
      "geo": {
        "lat": "-43.9509",
        "lng": "-34.4618"
      }
    },
    "phone": "010-692-6593 x09125",
    "website": "anastasia.net",
    "company": {
      "name": "Deckow-Crist",
      "catchPhrase": "Proactive didactic contingency",
      "bs": "synergize scalable supply-chains"
    }
  },
  {
    "id": 3,
    "name": "Clementine Bauch",
    "username": "Samantha",
    "email": "Nathan@yesenia.net",
    "address": {
      "street": "Douglas Extension",
      "suite": "Suite 847",
      "city": "McKenziehaven",
      "zipcode": "59590-4157",
      "geo": {
        "lat": "-68.6102",
        "lng": "-47.0653"
      }
    },
    "phone": "1-463-123-4447",
    "website": "ramiro.info",
    "company": {
      "name": "Romaguera-Jacobson",
      "catchPhrase": "Face to face bifurcated interface",
      "bs": "e-enable strategic applications"
    }
  },
  {
    "id": 4,
    "name": "Patricia Lebsack",
    "username": "Karianne",
    "email": "Julianne.OConner@kory.org",
    "address": {
      "street": "Hoeger Mall",
      "suite": "Apt. 692",
      "city": "South Elvis",
      "zipcode": "53919-4257",
      "geo": {
        "lat": "29.4572",
        "lng": "-164.2990"
      }
    },
    "phone": "493-170-9623 x156",
    "website": "kale.biz",
    "company": {
      "name": "Robel-Corkery",
      "catchPhrase": "Multi-tiered zero tolerance productivity",
      "bs": "transition cutting-edge web services"
    }
  },
  {
    "id": 5,
    "name": "Chelsey Dietrich",
    "username": "Kamren",
    "email": "Lucio_Hettinger@annie.ca",
    "address": {
      "street": "Skiles Walks",
      "suite": "Suite 351",
      "city": "Roscoeview",
      "zipcode": "33263",
      "geo": {
        "lat": "-31.8129",
        "lng": "62.5342"
      }
    },
    "phone": "(254)954-1289",
    "website": "demarco.info",
    "company": {
      "name": "Keebler LLC",
      "catchPhrase": "User-centric fault-tolerant solution",
      "bs": "revolutionize end-to-end systems"
    }
  },
  {
    "id": 6,
    "name": "Mrs. Dennis Schulist",
    "username": "Leopoldo_Corkery",
    "email": "Karley_Dach@jasper.info",
    "address": {
      "street": "Norberto Crossing",
      "suite": "Apt. 950",
      "city": "South Christy",
      "zipcode": "23505-1337",
      "geo": {
        "lat": "-71.4197",
        "lng": "71.7478"
      }
    },
    "phone": "1-477-935-8478 x6430",
    "website": "ola.org",
    "company": {
      "name": "Considine-Lockman",
      "catchPhrase": "Synchronised bottom-line interface",
      "bs": "e-enable innovative applications"
    }
  },
  {
    "id": 7,
    "name": "Kurtis Weissnat",
    "username": "Elwyn.Skiles",
    "email": "Telly.Hoeger@billy.biz",
    "address": {
      "street": "Rex Trail",
      "suite": "Suite 280",
      "city": "Howemouth",
      "zipcode": "58804-1099",
      "geo": {
        "lat": "24.8918",
        "lng": "21.8984"
      }
    },
    "phone": "210.067.6132",
    "website": "elvis.io",
    "company": {
      "name": "Johns Group",
      "catchPhrase": "Configurable multimedia task-force",
      "bs": "generate enterprise e-tailers"
    }
  },
  {
    "id": 8,
    "name": "Nicholas Runolfsdottir V",
    "username": "Maxime_Nienow",
    "email": "Sherwood@rosamond.me",
    "address": {
      "street": "Ellsworth Summit",
      "suite": "Suite 729",
      "city": "Aliyaview",
      "zipcode": "45169",
      "geo": {
        "lat": "-14.3990",
        "lng": "-120.7677"
      }
    },
    "phone": "586.493.6943 x140",
    "website": "jacynthe.com",
    "company": {
      "name": "Abernathy Group",
      "catchPhrase": "Implemented secondary concept",
      "bs": "e-enable extensible e-tailers"
    }
  },
  {
    "id": 9,
    "name": "Glenna Reichert",
    "username": "Delphine",
    "email": "Chaim_McDermott@dana.io",
    "address": {
      "street": "Dayna Park",
      "suite": "Suite 449",
      "city": "Bartholomebury",
      "zipcode": "76495-3109",
      "geo": {
        "lat": "24.6463",
        "lng": "-168.8889"
      }
    },
    "phone": "(775)976-6794 x41206",
    "website": "conrad.com",
    "company": {
      "name": "Yost and Sons",
      "catchPhrase": "Switchable contextually-based project",
      "bs": "aggregate real-time technologies"
    }
  },
  {
    "id": 10,
    "name": "Clementina DuBuque",
    "username": "Moriah.Stanton",
    "email": "Rey.Padberg@karina.biz",
    "address": {
      "street": "Kattie Turnpike",
      "suite": "Suite 198",
      "city": "Lebsackbury",
      "zipcode": "31428-2261",
      "geo": {
        "lat": "-38.2386",
        "lng": "57.2232"
      }
    },
    "phone": "024-648-3804",
    "website": "ambrose.net",
    "company": {
      "name": "Hoeger LLC",
      "catchPhrase": "Centralized empowering task-force",
      "bs": "target end-to-end models"
    }
  }
]
"""




struct TransformDouble: ZTTransform {
    static func transform(_ json: JSON) -> Double? {
        json.doubleValue
    }
}
struct TransformHttp: ZTTransform {
    static func transform(_ json: JSON) -> URL? {
        URL(string: json.stringValue)
    }
}



enum Animal: String, ZTJSONInitializable, Codable {
    init(from json: JSON) throws {
        guard let rawValue = json.string else {
            throw NSError(domain: "Animal", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON for Animal"])
        }
        
        switch rawValue {
        case "dog":
            self = .dog
        case "cat":
            self = .cat
        case "fish":
            self = .fish
        default:
            throw NSError(domain: "Animal", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid value for Animal"])
        }
    }
    
    case dog
    case cat
    case fish
}

extension Animal: ZTJSONExportable {
    public func asJSONValue() -> JSON {
        JSON(self.rawValue)
    }
}




@ZTJSON
struct Company {
    var name: String = ""
    var catchPhrase: String = ""
    @ZTJSONKey("bs", "bussness")
    var bussness: String = ""
}

extension Company: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
"""
{
    name:\"\(name)\", 
    catchPhrase:\"\(catchPhrase)\", 
    bussness:\"\(bussness)\"
    }
"""
    }
    public var debugDescription: String {
        return description
    }
}

@ZTJSON
open class BaseAddress {
    var street = ""
    var suite: String = ""
    var city:String = Bool.random() ? "Shang Hai" : "Bei Jing"
    
    var fullAddr: String {
        city + street + suite
    }
}

@ZTJSONSubclass
open class Address: BaseAddress {
    var zipcode: String = ""
    
    @ZTJSONTransformer(TransformDouble.self)
    @ZTJSONKey("geo/lat")
    var lat: Double = 0
    
    @ZTJSONTransformer(TransformDouble.self)
    @ZTJSONKey("geo/lng")
    var lng = 0.0
}

extension Address: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
"""
{
    street:\"\(street)\", 
    suite:\"\(suite)\", 
    city:\"\(city)\", 
    zipcode:\"\(zipcode)\", 
    lat:\"\(lat)\", 
    lng:\"\(lng)\"
    }
"""
    }
    public var debugDescription: String {
        return description
    }
}

@ZTJSON
struct Geo {
    @ZTJSONTransformer(TransformDouble.self)
    var lat: Double = 0
    
    @ZTJSONTransformer(TransformDouble.self)
    var lng = 0.0
}

extension Geo: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
"""
{
    lat:\"\(lat)\", 
    lng:\"\(lng)\"
    }
"""
    }
    public var debugDescription: String {
        return description
    }
}




extension URL: ZTJSONExportable {
    public func asJSONValue() -> JSON { JSON(self.absoluteString) }
}


@ZTJSON
class User {
    @MainActor
    static var clsName = "User"
    
    lazy var uuid = {
        UUID().uuidString
    }
    @ZTJSONIgnore
    var ig = UUID()
    @ZTJSONLetDefValue(0)
    let id: Int
    @ZTJSONLetDefValue("")
    let name: String
    @ZTJSONLetDefValue("")
    let username: String
    @ZTJSONLetDefValue("")
    let email: String
    
    var phone = ""
    
    @ZTJSONTransformer(TransformHttp.self)
    var website:URL?
    
    var company: Company = .init()
    
    var address: Address?
    
    var pet: Animal = .dog
}

extension User: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
"""
{
    id:\"\(id)\", 
    name:\"\(name)\", 
    username:\"\(username)\", 
    email:\"\(email)\", 
    phone:\"\(phone)\", 
    website:\"\(String(describing: website))\", 
    company:\(company), 
    address:\(String(describing: address))
}
"""
    }
    public var debugDescription: String {
        return description
    }
}


extension User {
    @ZTJSON
    class A {
        var val3: [String: String] = [String: String].init()
        var val4: [Int] = [123] + [4]
    }
}




@ZTJSON
class NestAddress {
    @ZTJSONKey("address/street")
    var street = ""
    @ZTJSONKey("address/suite")
    var suite: String = ""
    @ZTJSONKey("address/city")
    var city = ""
    @ZTJSONKey("address/zipcode")
    var zipCode: String = ""
    
    @ZTJSONTransformer(TransformDouble.self)
    @ZTJSONKey("address/geo/lat")
    var lat: Double = 0
    
    @ZTJSONTransformer(TransformDouble.self)
    @ZTJSONKey("address/geo/lng")
    var lng = 0.0
}

extension NestAddress: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
"""
{
    street:\"\(street)\", 
    suite:\"\(suite)\", 
    city:\"\(city)\", 
    zipcode:\"\(zipCode)\", 
    lat:\"\(lat)\", 
    lng:\"\(lng)\"
    }
"""
    }
    public var debugDescription: String {
        return description
    }
}












// Demo

struct XPathParserError: CustomStringConvertible, Error {
    var description: String

    init(_ desc: String) {
        self.description = desc
    }
}


struct XPathParser: Equatable, Hashable {
    let xpath: String
    let type: any ZTJSONInitializable.Type
    let isOptional:Bool
    init(_ xpath: String = "/", type: any ZTJSONInitializable.Type, _ isOptional: Bool = true) {
        self.xpath = xpath.isEmpty ? "/" : xpath
        self.type = type
        self.isOptional = isOptional
    }

    static func == (lhs: XPathParser, rhs: XPathParser) -> Bool {
        return lhs.xpath == rhs.xpath
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(xpath)
    }
}


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

@discardableResult
func get(confs: [XPathParser]) -> Result<[String: any ZTJSONInitializable], XPathParserError> {
    if let url = URL(string: "https://jsonplaceholder.typicode.com/users") {
        if let d = try? Data(contentsOf: url) {
            if let json = try? JSON(data: d) {
                // print(json.type)
                var r: [String: any ZTJSONInitializable] = [:]
                for p in confs {
                    if let j = json.find(xpath: p.xpath), let t = try? p.type.init(from:j) {
                        r[p.xpath] = t
                    } else if !p.isOptional {
                        return Result.failure(XPathParserError("Parse xpath failed"))
                    }
                }
                
                if let usr: [User] = r[.init(type: [User].self)] {
                    print("users", usr)
                    print("json string \n\n")
                    print("\(usr.asJSONValue().rawString() ?? "")")
                }
                // Or
                if let usr: [User] = r[xpath: "/"] {
                    print("users", usr)
                    print("json string \n\n")
                    print("\(usr.asJSONValue().rawString() ?? "")")
                }
                // print("result \(r)")
                
                return Result.success(r)
            }
        }
    }
    return Result.failure(XPathParserError("Parse xpath failed"))
}






// Parse root => [User]
get(confs: [.init(type: [User].self)])

// Parse "/0/address" => Address
get(confs: [.init("/0/address", type: Address.self)])

// Parse /*/address" => [Address]
get(confs: [.init("/*/address", type: [Address].self)])

// Parse "/*/address/geo" => [Geo]
get(confs: [.init("/*/address/geo", type: [Geo].self)])

// Parse root => [NestAddress]
get(confs: [.init(type: [NestAddress].self)])


// Parse same time
// Parse root => [User]
// Parse "/0/address" => Address
// Parse /*/address" => [Address]
// Parse "/*/address/geo" => [Geo]
// Parse root => [NestAddress]
get(confs: [.init(type: [User].self),
            .init("/0/address", type: Address.self),
            .init("/*/address", type: [Address].self),
            .init("/*/address/geo", type: [Geo].self),
            // OR
            //.init(type: [NestAddress].self)
            ])





// MARK: - 枚举属性使用示例

/// 使用 @ZTJSONEnum 宏自动支持 ZTJSON 序列化
/// 要求：枚举必须有原始值（RawRepresentable），如 `enum MyEnum: Int`
/// 宏会自动生成 asJSONValue()、init(from:) 方法和 extension 遵循协议
@ZTJSONEnum
enum IMChatType: RawRepresentable, Codable {
    init?(rawValue: Int32) {
        switch rawValue {
        case 1: self = .singleChat
        case 2: self = .groupChat
        case 3: self = .broadcastNow
        case 4: self = .tempChat
        case 5: self = .meetingChat
        case 6: self = .audioAndVideo
        case 1001: self = .guest
        default: return nil
        }
    }

    var rawValue: Int32 {
        switch self {
        case .singleChat: return 1
        case .groupChat: return 2
        case .broadcastNow: return 3
        case .tempChat: return 4
        case .meetingChat: return 5
        case .audioAndVideo: return 6
        case .guest: return 1001
        }
    }
    
    typealias RawValue = Int32
    
    /// 单聊
    case singleChat
    /// 群聊
    case groupChat
    /// 实时广播
    case broadcastNow
    /// 临时会话
    case tempChat
    /// 会议消息
    case meetingChat
    /// 音视频
    case audioAndVideo
    /// 拓客(属于客户端自定义 跟服务端保持一致)
    case guest
}

@ZTJSON
class IMChatModel {
    @ZTJSONLetDefValue("")
    let sessionId: String
    @ZTJSONLetDefValue(IMChatType.singleChat)
    let chatType: IMChatType  // @ZTJSONEnum 让枚举自动支持 ZTJSONInitializable，无需 @ZTJSONTransformer
    @ZTJSONLetDefValue(0)
    let chatObjId: Int64
}

// MARK: - @ZTJSONEnum 测试

print("\n=== @ZTJSONEnum 测试 ===\n")

// 测试1：ZTJSON 方式初始化
print("[测试1] ZTJSON 方式初始化")
do {
    let json1 = JSON([
        "sessionId": "session123",
        "chatType": 2,  // 群聊
        "chatObjId": 10001
    ])
    let model1 = try IMChatModel(from: json1)
    print("  sessionId: \(model1.sessionId)")
    print("  chatType: \(model1.chatType)")
    print("  chatObjId: \(model1.chatObjId)")
    print("  ✅ ZTJSON 初始化成功")
} catch {
    print("  ❌ 初始化失败: \(error)")
}

// 测试2：Codable 方式解码
print("\n[测试2] Codable 方式解码")
if let data = """
{
    "sessionId": "session456",
    "chatType": 3,
    "chatObjId": 10002
}
""".data(using: .utf8) {
    do {
        let model2 = try JSONDecoder().decode(IMChatModel.self, from: data)
        print("  sessionId: \(model2.sessionId)")
        print("  chatType: \(model2.chatType)")
        print("  chatObjId: \(model2.chatObjId)")
        print("  ✅ Codable 解码成功")
    } catch {
        print("  ❌ 解码失败: \(error)")
    }
}

// 测试3：asJSONValue 导出
print("\n[测试3] asJSONValue 导出")
let model3 = IMChatModel(sessionId: "session789", chatType: .meetingChat, chatObjId: 10003)
let exported = model3.asJSONValue()
print("  exported: \(exported.rawString() ?? "")")
print("  ✅ asJSONValue 导出成功")

// 测试4：Codable 编码
print("\n[测试4] Codable 编码")
do {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(model3)
    let jsonString = String(data: data, encoding: .utf8) ?? ""
    print("  encoded: \(jsonString)")
    print("  ✅ Codable 编码成功")
} catch {
    print("  ❌ 编码失败: \(error)")
}

// 测试6：枚举的 asJSONValue
print("\n[测试6] 枚举的 asJSONValue")
let chatType = IMChatType.groupChat
print("  asJSONValue: \(chatType.asJSONValue().rawValue)")
print("  ✅ 枚举 asJSONValue 成功")

print("\n=== @ZTJSONEnum 测试完成 ===\n")









// MARK: - Codable Encode/Decode 往返测试
print("\n" + String(repeating: "=", count: 50))
print("Testing Codable encode/decode round-trip")
print(String(repeating: "=", count: 50))

// 使用 memberwise init 创建测试用户
let testUser = User(
    id: 1,
    name: "Test User",
    username: "testuser",
    email: "test@example.com"
)
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

do {
    let encodedData = try encoder.encode(testUser)
    print("✅ Encode succeeded")
    let jsonString = String(data: encodedData, encoding: .utf8) ?? "nil"
    print("Encoded JSON (first 500 chars):")
    print(String(jsonString.prefix(500)))

    let decoder = JSONDecoder()
    do {
        let decodedUser = try decoder.decode(User.self, from: encodedData)
        print("\n✅ Decode succeeded")
        print("Decoded User id: \(decodedUser.id), name: \(decodedUser.name)")
    } catch {
        print("\n❌ Decode failed: \(error)")
        print("Error details: \(error.localizedDescription)")
    }
} catch {
    print("❌ Encode failed: \(error)")
}



// MARK: - 直接测试 asJSONValue()
print("\n" + String(repeating: "-", count: 50))
print("Testing asJSONValue() directly")
print(String(repeating: "-", count: 50))

let testCompany = Company(name: "Test Co", catchPhrase: "Test Phrase", bussness: "test")
let companyJSON = testCompany.asJSONValue()
print("Company asJSONValue():")
print(companyJSON.rawString(options: [.prettyPrinted]) ?? "nil")

if let companyData = try? companyJSON.rawData() {
    print("\n✅ Company can convert to Data")
    print("Data: \(Data(base64Encoded: companyData.base64EncodedString())?.description ?? "nil")")
}

let testUser2 = User(id: 2, name: "Alice", username: "alice", email: "alice@test.com")
let userJSON = testUser2.asJSONValue()
print("\nUser asJSONValue():")
print(userJSON.rawString(options: [.prettyPrinted]) ?? "nil")

// MARK: - 测试 encodeKey 格式
print("\n" + String(repeating: "-", count: 50))
print("Testing encodeKey format")
print(String(repeating: "-", count: 50))

// 测试带引号的格式（正确格式）
let test1 = JSON(["name" : "value1", "age" : 30])
print("With quotes (correct):")
print(test1.rawString(options: [.prettyPrinted]) ?? "nil")

// MARK: - 调试解码过程
print("\n" + String(repeating: "=", count: 50))
print("Debug decode process")
print(String(repeating: "=", count: 50))

// 先获取编码后的数据
let debugEncoder = JSONEncoder()
let testData = try! debugEncoder.encode(testUser)
let encodedString = String(data: testData, encoding: .utf8) ?? "nil"
print("Encoded data as string:")
print(encodedString)
print("\nData type check:")
print("First 100 bytes: \(testData.prefix(100))")

// 检查解码器期望什么格式
print("\n--- Testing decode with single value container ---")
do {
    let decodedUser = try JSONDecoder().decode(User.self, from: testData)
    print("✅ Success: \(decodedUser.name)")
} catch {
    print("❌ Failed: \(error)")
}


// MARK: - 新增测试用例

print("\n" + String(repeating: "=", count: 60))
print("扩展测试用例")
print(String(repeating: "=", count: 60))

// MARK: 1. @ZTJSONIgnore 功能验证
print("\n[测试 1] @ZTJSONIgnore 验证 - 确认被忽略字段不出现在编码结果中")
let userWithIgnore = User(id: 100, name: "Ignore Test", username: "ignore", email: "ignore@test.com")
let ignoreJSON = userWithIgnore.asJSONValue()
print("User.asJSONValue() 中的字段:")
print(ignoreJSON.dictionaryValue.keys.joined(separator: ", "))

// 检查 ig 字段是否被忽略
if ignoreJSON.dictionaryValue["ig"] == nil {
    print("✅ @ZTJSONIgnore 生效: ig 字段未被导出")
} else {
    print("❌ @ZTJSONIgnore 失效: ig 字段被导出了")
}

// MARK: 2. null 值处理
print("\n[测试 2] null 值处理 - JSON 中显式 null vs 字段不存在")
let nullJSONString = """
{
    "id": 1,
    "name": null,
    "username": "nulluser",
    "email": "null@test.com",
    "phone": null
}
"""
if let nullData = nullJSONString.data(using: .utf8),
   let nullJSON = try? JSON(data: nullData),
   let nullUser = try? User(from: nullJSON) {
    print("解析含 null 的 JSON:")
    print("  id: \(nullUser.id)")
    print("  name: \(nullUser.name) (应使用默认值)")
    print("  phone: \(nullUser.phone) (应使用默认值)")
    print("✅ null 值处理正确")
}

// MARK: 3. 数组属性
print("\n[测试 3] 数组属性测试")
@ZTJSON
struct ArrayTest {
    var tags: [String] = []
    var scores: [Int] = [0]
}

let arrayTestJSON = JSON([
    "tags": ["swift", "macro", "test"],
    "scores": [95, 87, 92]
])
if let arrayTest = try? ArrayTest(from: arrayTestJSON) {
    print("tags: \(arrayTest.tags)")
    print("scores: \(arrayTest.scores)")
    print("✅ 数组属性解析成功")
}

// MARK: 4. 字典属性
print("\n[测试 4] 字典属性测试")
@ZTJSON
struct DictTest {
    var metadata: [String: String] = [:]
}

let dictTestJSON = JSON([
    "metadata": ["key1": "value1", "key2": "value2"]
])
if let dictTest = try? DictTest(from: dictTestJSON) {
    print("metadata: \(dictTest.metadata)")
    print("✅ 字典属性解析成功")
}

// MARK: 5. Optional 显式测试
print("\n[测试 5] Optional 属性测试")
@ZTJSON
struct OptionalTest {
    var optionalName: String? = nil
    var requiredName: String = ""
}

// Optional 字段存在
let optJSON1 = JSON(["optionalName": "Alice", "requiredName": "Bob"])
if let opt1 = try? OptionalTest(from: optJSON1) {
    print("有 optionalName: \(opt1.optionalName ?? "nil")")
}

// Optional 字段不存在
let optJSON2 = JSON(["requiredName": "Charlie"])
if let opt2 = try? OptionalTest(from: optJSON2) {
    print("无 optionalName: \(opt2.optionalName ?? "nil")")
    print("✅ Optional 处理正确")
}

// MARK: 6. 负数索引 XPath
print("\n[测试 6] 负数索引 XPath 测试")
let usersJSONArray = JSON([
    ["name": "Alice", "age": 25],
    ["name": "Bob", "age": 30],
    ["name": "Charlie", "age": 35]
])

// 测试 -1 (最后一个)
if let lastName = usersJSONArray.find(xpath: "-1/name") {
    print("倒数第一个名字: \(lastName.stringValue)")
}

// 测试 -2 (倒数第二个)
if let age2 = usersJSONArray.find(xpath: "-2/age") {
    print("倒数第二个年龄: \(age2.intValue)")
    print("✅ 负数索引 XPath 正常工作")
}

// MARK: 7. Codable vs ZTJSONInitializable 对比
print("\n[测试 7] Codable vs ZTJSONInitializable 一致性对比")
let sourceJSON = JSON([
    "id": 999,
    "name": "Compare Test",
    "username": "compare",
    "email": "compare@test.com",
    "phone": "",
    "pet": "dog",
    "company": [
        "name": "",
        "catchPhrase": "",
        "bs": ""
    ]
])

// 方式 1: ZTJSONInitializable
do {
    let user1 = try User(from: sourceJSON)

    // 方式 2: 先用 Codable 编码，再用 Codable 解码
    let encoder = JSONEncoder()
    let encodedData = try encoder.encode(user1)
    let user2 = try JSONDecoder().decode(User.self, from: encodedData)

    let match = user1.id == user2.id && user1.name == user2.name
    print("ZTJSONInitializable id: \(user1.id), name: \(user1.name)")
    print("Codable (encode->decode) id: \(user2.id), name: \(user2.name)")
    print(match ? "✅ 两种方式结果一致" : "❌ 两种方式结果不一致")
} catch {
    print("⚠️ 测试失败: \(error)")
}

// MARK: 8. 嵌套数组 + XPath
print("\n[测试 8] 嵌套数组 + XPath 测试")
let nestedArrayJSON = JSON([
    "users": [
        ["name": "Alice"],
        ["name": "Bob"]
    ]
])

if let firstUserName = nestedArrayJSON.find(xpath: "users/0/name") {
    print("第一个用户的 name: \(firstUserName.stringValue)")
    print("✅ 嵌套数组 XPath 正常工作")
}

print("\n" + String(repeating: "=", count: 60))
print("所有测试完成")
print(String(repeating: "=", count: 60))

// MARK: - 性能基准测试
// 运行所有性能测试（ZTJSONInitializable + Codable），约需 15-20 分钟
// runPerformanceBenchmarks()

// 仅运行 ZTJSONInitializable 性能测试（与 HandyJSON 直接对比），约需 8-10 分钟
// runZTJSONInitializableBenchmarks()

// 仅运行 Codable 性能测试（包含 base64 编码开销），约需 8-10 分钟
// runCodableBenchmarks()

// ignoreXPath 性能对比测试（约需 2-3 分钟）
// runIgnoreXPathComparison()

// ZTJSON vs HandyJSON 性能对比（约需 2 分钟）
runHandyJSONComparison()

// MARK: - 多 Key 回退测试
// 测试结构：使用 @ZTJSONKey 配置多个可能的键名
@ZTJSON
struct MultiKeyTest {
    var id: Int = 0
    @ZTJSONKey("primary_name", "name", "username")
    var name: String = ""
}

func runMultiKeyFallbackTest() {
    print("\n" + String(repeating: "=", count: 60))
    print("[测试] 多 Key 回退功能测试")
    print(String(repeating: "=", count: 60))

    // 验证 CodingKeys 生成是否正确
    // 注意：CodingKeys case 名称现在是属性名（name），JSON 键名在 rawValue 中
    print("\n[CodingKeys 验证 - MultiKeyTest]")
    print("name: \(MultiKeyTest.CodingKeys.name.rawValue)")
    print("name_1: \(MultiKeyTest.CodingKeys.name_1.rawValue)")
    print("name_2: \(MultiKeyTest.CodingKeys.name_2.rawValue)")
    print("id: \(MultiKeyTest.CodingKeys.id.rawValue)")

    // 验证嵌套路径的 CodingKeys
    print("\n[CodingKeys 验证 - Address (嵌套路径 geo/lat, geo/lng)]")
    print("geo: \(Address.CodingKeys.geo.rawValue)")
    print("lat: \(Address.CodingKeys.lat.rawValue)")
    print("lng: \(Address.CodingKeys.lng.rawValue)")
    print("")

    // 测试 1: JSON 中只有 "name" 键（第二个回退键）
    let jsonWithName = """
    {
        "id": 1,
        "name": "Value from name key"
    }
    """.data(using: .utf8)!

    do {
        let test1 = try JSONDecoder().decode(MultiKeyTest.self, from: jsonWithName)
        print("测试 1 - 只有 'name' 键: \(test1.name)")
        print(test1.name == "Value from name key" ? "✅ 回退到 'name' 成功" : "❌ 回退失败")
    } catch {
        print("❌ 测试 1 失败: \(error)")
    }

    // 测试 2: JSON 中只有 "username" 键（第三个回退键）
    let jsonWithUsername = """
    {
        "id": 2,
        "username": "Value from username key"
    }
    """.data(using: .utf8)!

    do {
        let test2 = try JSONDecoder().decode(MultiKeyTest.self, from: jsonWithUsername)
        print("测试 2 - 只有 'username' 键: \(test2.name)")
        print(test2.name == "Value from username key" ? "✅ 回退到 'username' 成功" : "❌ 回退失败")
    } catch {
        print("❌ 测试 2 失败: \(error)")
    }

    // 测试 3: JSON 中有 "primary_name" 键（第一个主键）
    let jsonWithPrimary = """
    {
        "id": 3,
        "primary_name": "Value from primary_name key"
    }
    """.data(using: .utf8)!

    do {
        let test3 = try JSONDecoder().decode(MultiKeyTest.self, from: jsonWithPrimary)
        print("测试 3 - 有 'primary_name' 主键: \(test3.name)")
        print(test3.name == "Value from primary_name key" ? "✅ 使用主键 'primary_name' 成功" : "❌ 使用主键失败")
    } catch {
        print("❌ 测试 3 失败: \(error)")
    }

    // 测试 4: JSON 中有多个键，应优先使用第一个
    let jsonWithMultiple = """
    {
        "id": 4,
        "name": "Should not use this",
        "primary_name": "Should use this (primary)"
    }
    """.data(using: .utf8)!

    do {
        let test4 = try JSONDecoder().decode(MultiKeyTest.self, from: jsonWithMultiple)
        print("测试 4 - 多个键存在: \(test4.name)")
        print(test4.name == "Should use this (primary)" ? "✅ 正确优先使用第一个键" : "❌ 优先级错误")
    } catch {
        print("❌ 测试 4 失败: \(error)")
    }

    // 测试 5: JSON 中没有任何配置的键，应使用默认值
    let jsonWithNone = """
    {
        "id": 5,
        "other_key": "Some value"
    }
    """.data(using: .utf8)!

    do {
        let test5 = try JSONDecoder().decode(MultiKeyTest.self, from: jsonWithNone)
        print("测试 5 - 没有匹配的键: '\(test5.name)'")
        print(test5.name == "" ? "✅ 正确使用默认值" : "❌ 默认值处理错误")
    } catch {
        print("❌ 测试 5 失败: \(error)")
    }

    print("\n" + String(repeating: "=", count: 60))
    print("多 Key 回退功能测试完成！")
    print(String(repeating: "=", count: 60))
}

// 取消注释以运行多 Key 回退测试
// testMultiKeyFallback()

// MARK: - 测试键名重命名功能
print("\n" + String(repeating: "=", count: 60))
print("测试键名重命名功能 (zipCode -> zip)")
print(String(repeating: "=", count: 60))

@ZTJSON
struct Person {
    var id: Int = 0
    var name: String = ""

    @ZTJSONKey("user/email")
    var email: String = ""

    @ZTJSONKey("user/address/city")
    var city: String = ""

    @ZTJSONKey("user/address/zipCode")
    var zip: String = ""
}

let personJson = """
{
  "id": 1,
  "name": "John",
  "user": {
    "email": "john@example.com",
    "address": {
      "city": "New York",
      "zipCode": "10001"
    }
  }
}
""".data(using: .utf8)!

do {
    let person = try JSONDecoder().decode(Person.self, from: personJson)
    print("✅ 解码成功:")
    print("  id: \(person.id)")
    print("  name: \(person.name)")
    print("  email: \(person.email)")
    print("  city: \(person.city)")
    print("  zip: \(person.zip)")

    if person.zip == "10001" {
        print("✅ zipCode -> zip 映射正确！")
    } else {
        print("❌ zipCode 映射失败")
    }

    // 测试编码
    let encoded = try JSONEncoder().encode(person)
    if let encodedStr = String(data: encoded, encoding: .utf8) {
        print("\n编码后的 JSON:")
        print(encodedStr)

        // 检查编码是否使用正确的键名
        if encodedStr.contains("\"zipCode\"") {
            print("✅ 编码使用正确的键名 'zipCode'")
        } else {
            print("❌ 编码键名不正确")
        }
    }
} catch {
    print("❌ 解码失败: \(error)")
}

// MARK: - 测试 @ZTAPIParam 宏
print("\n" + String(repeating: "=", count: 60))
print("测试 @ZTAPIParam 宏")
print(String(repeating: "=", count: 60))

@ZTAPIParam
enum LoginParams {
    case userName(String)
    case password(String)
}

// 测试 key 属性
print("\n[key 属性测试]")
print("userName.key = \(LoginParams.userName("test").key)")
print("password.key = \(LoginParams.password("123456").key)")

let userNameKeyCorrect = LoginParams.userName("test").key == "user_name"
let passwordKeyCorrect = LoginParams.password("123456").key == "password"
print(userNameKeyCorrect ? "✅ userName -> user_name" : "❌ userName 转换失败")
print(passwordKeyCorrect ? "✅ password -> password" : "❌ password 转换失败")

// 测试 value 属性
print("\n[value 属性测试]")
let username = LoginParams.userName("john@example.com")
let password = LoginParams.password("secret123")
print("userName.value = \(username.value)")
print("password.value = \(password.value)")

// 测试 isValid 方法
print("\n[isValid 方法测试]")
let validParams: [String: Sendable] = ["user_name": "john", "password": "pass"]
let invalidParams1: [String: Sendable] = ["user_name": "john"]
let invalidParams2: [String: Sendable] = ["password": "pass"]
let emptyParams: [String: Sendable] = [:]

print("有效参数: \(LoginParams.isValid(validParams)) ? (预期: true)")
print("缺少 password: \(LoginParams.isValid(invalidParams1)) ? (预期: false)")
print("缺少 user_name: \(LoginParams.isValid(invalidParams2)) ? (预期: false)")
print("空参数: \(LoginParams.isValid(emptyParams)) ? (预期: false)")

if LoginParams.isValid(validParams) && !LoginParams.isValid(invalidParams1) && !LoginParams.isValid(invalidParams2) && !LoginParams.isValid(emptyParams) {
    print("✅ isValid 方法正确！")
} else {
    print("❌ isValid 方法有误")
}

// 测试更多驼峰命名转换
print("\n[驼峰命名转换测试]")
@ZTAPIParam
enum TestCaseNames {
    case firstName(String)
    case zipCode(String)
    case userID(String)
    case apiKey(String)
    case url(String)
}

let testCases = [
    ("firstName", "first_name"),
    ("zipCode", "zip_code"),
    ("userID", "user_id"),
    ("apiKey", "api_key"),
    ("url", "url"),
]

var allPass = true
for (caseName, expected) in testCases {
    let _ = TestCaseNames.firstName("")  // 占位，只测试 key
    // 需要重新构造正确的 case
    let key: String
    switch caseName {
    case "firstName":
        key = TestCaseNames.firstName("").key
    case "zipCode":
        key = TestCaseNames.zipCode("").key
    case "userID":
        key = TestCaseNames.userID("").key
    case "apiKey":
        key = TestCaseNames.apiKey("").key
    case "url":
        key = TestCaseNames.url("").key
    default:
        key = ""
    }

    let pass = key == expected
    allPass = allPass && pass
    print(pass ? "✅" : "❌", "\(caseName) -> \(key) (预期: \(expected))")
}

if allPass {
    print("✅ 所有命名转换正确！")
} else {
    print("❌ 部分命名转换失败")
}

// MARK: - 测试 @ZTAPIParamKey 自定义键名
print("\n" + String(repeating: "=", count: 60))
print("测试 @ZTAPIParamKey 自定义键名")
print(String(repeating: "=", count: 60))

@ZTAPIParam
enum CustomKeyParams {
    @ZTAPIParamKey("user_name")
    case userName(String)

    @ZTAPIParamKey("pwd")
    case password(String)

    // 没有注解，使用默认转换
    case emailAddress(String)
}

// 测试自定义键名
print("\n[自定义键名测试]")
print("userName.key = \(CustomKeyParams.userName("test").key) (预期: user_name)")
print("password.key = \(CustomKeyParams.password("123").key) (预期: pwd)")
print("emailAddress.key = \(CustomKeyParams.emailAddress("test@test.com").key) (预期: email_address)")

let tests = [
    (CustomKeyParams.userName("test").key, "user_name"),
    (CustomKeyParams.password("123").key, "pwd"),
    (CustomKeyParams.emailAddress("test@test.com").key, "email_address"),
]

var customKeyPass = tests.allSatisfy { $0.0 == $0.1 }
print(customKeyPass ? "✅ 所有键名正确！" : "❌ 键名错误")

// 测试 isValid 使用自定义键名
print("\n[isValid 使用自定义键名]")
let keyParams: [String: Sendable] = ["user_name": "john", "pwd": "pass", "email_address": "john@test.com"]
print("isValid(params) = \(CustomKeyParams.isValid(keyParams)) (预期: true)")

let missingKeyParams: [String: Sendable] = ["user_name": "john", "email_address": "john@test.com"]
print("缺少 pwd: isValid = \(CustomKeyParams.isValid(missingKeyParams)) (预期: false)")

if CustomKeyParams.isValid(keyParams) && !CustomKeyParams.isValid(missingKeyParams) {
    print("✅ isValid 方法使用自定义键名正确！")
} else {
    print("❌ isValid 方法有误")
}

// MARK: - 测试 Optional 关联值不加入 isValid
print("\n" + String(repeating: "=", count: 60))
print("测试 Optional 关联值不加入 isValid")
print(String(repeating: "=", count: 60))

@ZTAPIParam
enum MixedParams {
    case userName(String)      // 必需
    case password(String)      // 必需
    case email(String?)        // Optional，不加入 isValid
    case phone(String?)        // Optional，不加入 isValid
}

print("\n[Optional 测试]")
print("userName.key = \(MixedParams.userName("test").key)")
print("password.key = \(MixedParams.password("123").key)")
print("email.key = \(MixedParams.email(nil).key)")
print("phone.key = \(MixedParams.phone(nil).key)")

// 只有 userName 和 password 是必需的
let mixedValidParams: [String: Sendable] = ["user_name": "john", "password": "pass"]
print("\n只有必需参数: isValid = \(MixedParams.isValid(mixedValidParams)) (预期: true)")

// 缺少 password
let missingPassword: [String: Sendable] = ["user_name": "john"]
print("缺少 password: isValid = \(MixedParams.isValid(missingPassword)) (预期: false)")

// 包含 Optional 参数但缺少必需参数
let withOptionalButMissingRequired: [String: Sendable] = ["user_name": "john", "email": "test@test.com"]
print("有 email 但缺 password: isValid = \(MixedParams.isValid(withOptionalButMissingRequired)) (预期: false)")

if MixedParams.isValid(mixedValidParams) && !MixedParams.isValid(missingPassword) && !MixedParams.isValid(withOptionalButMissingRequired) {
    print("✅ Optional 参数不加入 isValid 检查正确！")
} else {
    print("❌ Optional 参数处理有误")
}

// 测试所有 case 都是 Optional 的情况
@ZTAPIParam
enum AllOptionalParams {
    case nickname(String?)
    case bio(String?)
}

print("\n[全部 Optional 测试]")
print("所有 case 都是 Optional 时 isValid 总是返回 true:")
print("isValid([:]) = \(AllOptionalParams.isValid([:])) (预期: true)")
print("isValid([\"nickname\": \"test\"]) = \(AllOptionalParams.isValid(["nickname": "test"])) (预期: true)")

if AllOptionalParams.isValid([:]) && AllOptionalParams.isValid(["nickname": "test"]) {
    print("✅ 全部 Optional 时 isValid 正确！")
} else {
    print("❌ 全部 Optional 处理有误")
}

// 测试没有关联值的枚举应该报错
print("\n[非关联枚举错误测试]")
print("以下代码应该编译报错：")
print("""
@ZTAPIParam
enum NoAssociatedValues {
    case case1
    case case2
}
""")

// MARK: - 测试 ZTAPIParamProtocol 协议遵循
print("\n" + String(repeating: "=", count: 60))
print("测试 ZTAPIParamProtocol 协议遵循")
print(String(repeating: "=", count: 60))

@ZTAPIParam
enum TestProtocolConformance {
    case id(Int)
    case name(String)
}

// 验证 enum 遵循 ZTAPIParamProtocol
let _: any ZTAPIParamProtocol.Type = TestProtocolConformance.self
print("✅ TestProtocolConformance 遵循 ZTAPIParamProtocol 协议")

// 验证实例可以使用协议属性
let testParam: any ZTAPIParamProtocol = TestProtocolConformance.id(123)
print("key: \(testParam.key)")
print("value: \(testParam.value)")

// 验证协议方法
let protocolParams: [String: Sendable] = ["id": 123, "name": "test"]
if TestProtocolConformance.isValid(protocolParams) {
    print("✅ 协议 isValid 方法工作正常")
} else {
    print("❌ 协议 isValid 方法失败")
}

// MARK: - Date 类型扩展示例
// ZTJSON 不再内置 Date 支持，用户需要根据 API 格式自行扩展

// 示例 1: ISO8601 格式（推荐使用，带 formatter 缓存优化）
extension Date: ZTJSONExportable {
    // 使用 nonisolated(unsafe) 标记，因为 ISO8601DateFormatter 是线程安全的
    // 但 Swift 6 无法自动推断，需要显式标记
    private nonisolated(unsafe) static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    public func asJSONValue() -> JSON {
        JSON(Self.iso8601Formatter.string(from: self))
    }
}

extension Date: ZTJSONInitializable {
    public init(from json: JSON) throws {
        guard let dateString = json.string,
              let date = Self.iso8601Formatter.date(from: dateString) else {
            throw ZTJSONError.error(code: ZTJSONError.Code.typeMismatch, msg: "expected ISO8601 date string, got \(json.type)")
        }
        self = date
    }
}

// 示例 2: 如果你的 API 使用 Unix 时间戳，可以这样扩展：
/*
extension Date: ZTJSONExportable {
    func asJSONValue() -> JSON {
        JSON(self.timeIntervalSince1970)
    }
}

extension Date: ZTJSONInitializable {
    init(from json: JSON) throws {
        guard let timestamp = json.double else {
            throw ZTJSONError.error(code: ZTJSONError.Code.typeMismatch, msg: "expected Unix timestamp, got \(json.type)")
        }
        self = Date(timeIntervalSince1970: timestamp)
    }
}
*/

// 示例 3: 如果你的 API 使用自定义日期格式（如 "yyyy-MM-dd HH:mm:ss"）：
/*
extension Date: ZTJSONExportable {
    private nonisolated(unsafe) static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    func asJSONValue() -> JSON {
        JSON(Self.customFormatter.string(from: self))
    }
}

extension Date: ZTJSONInitializable {
    init(from json: JSON) throws {
        guard let dateString = json.string,
              let date = Self.customFormatter.date(from: dateString) else {
            throw ZTJSONError.error(code: ZTJSONError.Code.typeMismatch, msg: "expected custom date format, got \(json.type)")
        }
        self = date
    }
}
*/

// MARK: - 测试类型别名形式的 Optional

typealias OptionalString = String?

@ZTJSON
struct AliasTest {
    var name: OptionalString = ""
}

func testAliasOptional() {
    print("\n=== 测试类型别名形式的 Optional ===")

    // 测试 1: 有字段的情况
    let json1 = JSON(["name": "test"])
    do {
        let obj1 = try AliasTest(from: json1)
        print("测试 1 - 有字段: \(obj1.name ?? "nil")")
    } catch {
        print("测试 1 - 失败: \(error)")
    }

    // 测试 2: 字段不存在的情况
    let json2 = JSON([:])
    do {
        let obj2 = try AliasTest(from: json2)
        print("测试 2 - 无字段: \(obj2.name ?? "nil")")
    } catch {
        print("测试 2 - 失败: \(error)")
    }

    // 测试 3: 字段为 null 的情况
    let json3 = JSON(["name": NSNull()])
    do {
        let obj3 = try AliasTest(from: json3)
        print("测试 3 - null 值: \(obj3.name ?? "nil")")
    } catch {
        print("测试 3 - 失败: \(error)")
    }

    // 测试 4: 导出 nil 值
    let testObj = AliasTest(name: nil)
    let exported = testObj.asJSONValue()
    print("测试 4 - 导出 nil: \(exported.rawString() ?? "")")

    print("=== 类型别名测试完成 ===\n")
}

testAliasOptional()

// MARK: - 测试新的错误系统

func testNewErrorSystem() {
    print("\n=== 测试新的错误系统 ===")

    // 测试 1: 类型不匹配错误
    let json1 = JSON(["age": "not_a_number"])
    do {
        _ = try Int(from: json1)
        print("测试 1 - 失败: 应该抛出错误")
    } catch let error as ZTJSONError {
        print("测试 1 - 类型不匹配:")
        print("  code: \(error.code)")
        print("  message: \(error.message)")
    } catch {
        print("测试 1 - 其他错误: \(error)")
    }

    // 测试 2: 数组类型不匹配
    let json2 = JSON(["items": "not_an_array"])
    do {
        _ = try [Int](from: json2)
        print("测试 2 - 失败: 应该抛出错误")
    } catch let error as ZTJSONError {
        print("测试 2 - 数组类型不匹配:")
        print("  code: \(error.code)")
        print("  message: \(error.message)")
    } catch {
        print("测试 2 - 其他错误: \(error)")
    }

    // 测试 3: 通用错误形式
    let customError = ZTJSONError.error(code: 9999, msg: "Custom error message")
    print("测试 3 - 通用错误:")
    print("  code: \(customError.code)")
    print("  message: \(customError.message)")

    print("=== 错误系统测试完成 ===\n")
}

testNewErrorSystem()

// MARK: - 测试批量查询区分未找到和空数组

func testFindAllLogic() {
    print("\n=== 测试批量查询 ===")

    // 测试 1: 路径不存在，返回 nil
    let json1 = JSON([
        "users": [
            ["name": "Alice", "age": 25],
            ["name": "Bob", "age": 30]
        ]
    ])
    let result1 = json1.find(xpath: "nonexistent/*/name")
    print("测试 1 - 路径不存在:")
    print("  result: \(result1?.rawString() ?? "nil")")
    print("  isNil: \(result1 == nil)")

    // 测试 2: 通配符匹配到空数组（路径存在但子元素为空）
    let json2 = JSON([
        "users": []
    ])
    let result2 = json2.find(xpath: "users/*/name")
    print("测试 2 - 空数组:")
    print("  result: \(result2?.rawString() ?? "nil")")
    print("  isNil: \(result2 == nil)")
    print("  isEmpty: \(result2?.arrayValue.isEmpty ?? true)")

    // 测试 3: 通配符匹配到空字典
    let json3 = JSON([
        "users": [:]
    ])
    let result3 = json3.find(xpath: "users/*/name")
    print("测试 3 - 空字典:")
    print("  result: \(result3?.rawString() ?? "nil")")
    print("  isNil: \(result3 == nil)")
    print("  isEmpty: \(result3?.arrayValue.isEmpty ?? true)")

    // 测试 4: 有匹配的情况
    let json4 = JSON([
        "users": [
            ["name": "Alice"],
            ["name": "Bob"]
        ]
    ])
    let result4 = json4.find(xpath: "users/*/name")
    print("测试 4 - 有匹配:")
    print("  result: \(result4?.rawString() ?? "nil")")
    print("  count: \(result4?.arrayValue.count ?? 0)")

    // 测试 5: 中间路径不存在，返回 nil
    let result5 = json1.find(xpath: "users/*/address/nonexistent")
    print("测试 5 - 中间路径不存在:")
    print("  result: \(result5?.rawString() ?? "nil")")
    print("  isNil: \(result5 == nil)")

    // 测试 6: 最后一个组件不匹配，返回空数组
    let result6 = json1.find(xpath: "users/*/nonexistent")
    print("测试 6 - 最后组件不匹配:")
    print("  result: \(result6?.rawString() ?? "nil")")
    print("  isNil: \(result6 == nil)")
    print("  isEmpty: \(result6?.arrayValue.isEmpty ?? true)")

    print("=== 批量查询测试完成 ===\n")
}

testFindAllLogic()

// MARK: - 测试 @ZTAPIParam Optional 检测

@ZTAPIParam
enum NormalOptionalTest {
    case count(Int?)         // 显式 Optional
    case name(String?)       // 显式 Optional
    case active(Bool)        // 非 Optional
    case score(Double?)      // 显式 Optional
}

func testAPIParamNormalOptional() {
    print("\n=== 测试 @ZTAPIParam 正常 Optional ===")

    // 测试 1: 只有必需参数
    let params1: [String: Sendable] = ["active": true]
    print("测试 1 - 只有必需参数 active:")
    print("  isValid: \(NormalOptionalTest.isValid(params1))")

    // 测试 2: 缺少所有 Optional 参数
    let params2: [String: Sendable] = ["active": true]
    print("测试 2 - 缺少所有 Optional 参数:")
    print("  isValid: \(NormalOptionalTest.isValid(params2))")

    // 测试 3: 包含 Optional 参数
    let params3: [String: Sendable] = ["active": true, "count": 42, "name": "Test"]
    print("测试 3 - 包含 Optional 参数:")
    print("  isValid: \(NormalOptionalTest.isValid(params3))")

    // 测试 4: 缺少必需参数
    let params4: [String: Sendable] = ["count": 42]
    print("测试 4 - 缺少必需参数 active:")
    print("  isValid: \(NormalOptionalTest.isValid(params4))")

    print("=== @ZTAPIParam 正常 Optional 测试完成 ===\n")
}

testAPIParamNormalOptional()

// MARK: - 测试 @ZTAPIParam 类型别名 Optional 检测

typealias OptionalInt = Int?

@ZTAPIParam
enum AliasOptionalTest {
    case count(OptionalInt)  // 类型别名形式的 Optional - 不支持
    case name(String)
    case active(Bool)
}

func testAPIParamAliasOptional() {
    print("\n=== 测试 @ZTAPIParam 类型别名 Optional ===")

    // 测试 1: 缺少 Optional 参数 count
    let params1: [String: Sendable] = [
        "name": "Test",
        "active": true
    ]
    print("测试 1 - 缺少 Optional 参数 count:")
    print("  isValid: \(AliasOptionalTest.isValid(params1))")
    print("  预期: false (类型别名 Optional 不被识别为 Optional)")

    // 测试 2: 包含所有参数
    let params2: [String: Sendable] = [
        "count": 42,
        "name": "Test",
        "active": true
    ]
    print("测试 2 - 包含所有参数:")
    print("  isValid: \(AliasOptionalTest.isValid(params2))")

    print("=== @ZTAPIParam 类型别名 Optional 测试完成 ===\n")
}

testAPIParamAliasOptional()

// MARK: - 测试 XPath 深度限制

func testXPathDepthLimit() {
    print("\n=== 测试 XPath 深度限制 ===")

    // 用 JSON 字符串直接构造测试数据
    // 构造一个 5 层嵌套的结构验证基本功能
    let testJSONString = """
    {
        "a": {
            "b": {
                "c": {
                    "d": {
                        "e": "found"
                    }
                }
            }
        }
    }
    """

    guard let json = try? JSON(data: testJSONString.data(using: .utf8)!) else {
        print("构造测试 JSON 失败")
        return
    }

    // 测试 1: 正常深度 (5 层)
    print("测试 1 - 正常深度 (5 层):")
    if let result = json.find(xpath: "a/b/c/d/e") {
        print("  预期: 找到结果 \(result)")
    } else {
        print("  意外: 返回 nil")
    }

    // 测试 2: 超过深度限制 (105 层)
    print("测试 2 - 深度超过限制 (105 层):")
    let deepPath = String(repeating: "x/", count: 105) + "y"
    if let result = json.find(xpath: deepPath) {
        print("  意外: 找到结果 \(result)")
    } else {
        print("  预期: 返回 nil (超过深度限制)")
    }

    // 测试 3: 通配符深度超过限制
    print("测试 3 - 通配符深度超过限制:")
    let wildcardPath = String(repeating: "*/", count: 105) + "value"
    if let result = json.find(xpath: wildcardPath) {
        print("  意外: 找到结果 \(result)")
    } else {
        print("  预期: 返回 nil (超过深度限制)")
    }

    // 测试 4: 通配符正常工作
    print("测试 4 - 通配符正常查询:")
    let json2: JSON = [
        "items": [
            ["name": "a"],
            ["name": "b"]
        ]
    ]
    if let result = json2.find(xpath: "items/*/name") {
        print("  预期: 找到结果 \(result)")
    } else {
        print("  意外: 返回 nil")
    }

    print("=== XPath 深度限制测试完成 ===\n")
}

testXPathDepthLimit()

// MARK: - 测试 @ZTJSONKey 参数验证

// 正确用法示例
@ZTJSON
struct KeyValidationCorrect {
    // 单个键
    @ZTJSONKey("custom_name")
    var name: String = ""

    // 多个回退键
    @ZTJSONKey("primary", "fallback1", "fallback2")
    var multiKey: String = ""

    // 嵌套路径
    @ZTJSONKey("path/to/value")
    var nested: String = ""
}

print("=== @ZTJSONKey 参数验证测试 ===")
print("正确用法: 编译通过")

// 以下用法会产生编译错误（已注释，仅作为文档）：
/*
// 错误 1: 没有参数
@ZTJSON
struct ErrorNoParams {
    @ZTJSONKey()
    var field: String = ""  // 编译错误: "@ZTJSONKey 至少需要一个参数"
}

// 错误 2: 参数过多（超过 5 个）
@ZTJSON
struct ErrorTooManyParams {
    @ZTJSONKey("a", "b", "c", "d", "e", "f")
    var field: String = ""  // 编译错误: "@ZTJSONKey 最多支持 5 个参数"
}
*/

print("错误用法（取消注释会触发编译错误）:")
print("  - @ZTJSONKey() 无参数: 至少需要一个参数")
print("  - @ZTJSONKey(\"a\",\"b\",\"c\",\"d\",\"e\",\"f\"): 最多支持 5 个参数")
print("=== @ZTJSONKey 参数验证测试完成 ===\n")

// MARK: - 测试 Subclass Encode 包含子类属性

@ZTJSON
open class BaseAnimal {
    var baseName: String = ""
    var baseAge: Int = 0
}

@ZTJSONSubclass
open class Dog: BaseAnimal {
    var breed: String = ""
    var isGoodBoy: Bool = true
}

func testSubclassEncode() {
    print("\n=== 测试 Subclass Encode 包含子类属性 ===")

    let dog = Dog()
    dog.baseName = "Buddy"
    dog.baseAge = 3
    dog.breed = "Golden Retriever"
    dog.isGoodBoy = true

    // 测试 asJSONValue() - 应该包含所有属性
    let json = dog.asJSONValue()
    print("asJSONValue():")
    print("  \(json.rawString() ?? "")")

    // 验证属性是否都存在
    let hasBaseName = json["baseName"].string == "Buddy"
    let hasBaseAge = json["baseAge"].int == 3
    let hasBreed = json["breed"].string == "Golden Retriever"
    let hasIsGoodBoy = json["isGoodBoy"].bool == true

    print("属性验证:")
    print("  baseName: \(hasBaseName ? "✓" : "✗")")
    print("  baseAge: \(hasBaseAge ? "✓" : "✗")")
    print("  breed: \(hasBreed ? "✓" : "✗")")
    print("  isGoodBoy: \(hasIsGoodBoy ? "✓" : "✗")")

    // 测试 Codable encode - 也应该包含所有属性
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(dog)
        if let encodedString = String(data: data, encoding: .utf8) {
            print("\nCodable encode():")
            print("  \(encodedString)")
        }

        let encodedJSON = try JSON(data: data)

        let encodedHasBaseName = encodedJSON["baseName"].string == "Buddy"
        let encodedHasBreed = encodedJSON["breed"].string == "Golden Retriever"

        print("Codable 属性验证:")
        print("  baseName: \(encodedHasBaseName ? "✓" : "✗")")
        print("  breed: \(encodedHasBreed ? "✓" : "✗")")

        // 调试：检查父类是否正确生成了 encode
        print("\n调试 - 直接编码父类:")
        let baseAnimal: BaseAnimal = dog
        let baseData = try encoder.encode(baseAnimal)
        let baseJSON = try JSON(data: baseData)
        print("  BaseAnimal.encode(): \(baseJSON.rawString() ?? "")")

        if hasBaseName && hasBaseAge && hasBreed && hasIsGoodBoy && encodedHasBaseName && encodedHasBreed {
            print("\n✓ 所有测试通过 - 子类属性正确编码")
        } else {
            print("\n✗ 测试失败 - 某些属性未正确编码")
        }
    } catch {
        print("Codable encode 错误: \(error)")
    }

    print("=== Subclass Encode 测试完成 ===\n")
}

testSubclassEncode()

// MARK: - 调用其他测试文件中的测试函数

// TransformerTest.swift 中的测试
runTransformerTests()

// BugFixTest.swift 中的测试
runBugFixTests()

print("\n=== 所有测试完成 ===\n")

// MARK: - 测试非 optional 属性默认值

// 测试1: var non-optional 不加默认值
