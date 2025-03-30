# ZTJSON
基于SwiftyJSON的swift ORM库

```swift


// MARK: - Transform

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

// MARK: - Parse Enum

enum Animal: String, ZTJSONInitializable {
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


// MARK: - Normal

@ZTJSON
struct Company {
    var name: String = ""
    var catchPhrase: String = ""
    @ZTJSONKey("bussness", "bs")
    var bussness: String = ""
}


@ZTJSON
class BaseAddress {
    var street = ""
    var suite: String = ""
    // support expr init
    var city:String = Bool.random() ? "Shang Hai" : "Bei Jing"
    
    // ignore 
    var fullAddr: String {
        city + street + suite
    }
}


@ZTJSONSubclass
class Address: BaseAddress {
    var zipcode: String = ""
    
    // support transform
    @ZTJSONTransformer(TransformDouble)
    @ZTJSONKey("geo/lat")
    var lat: Double = 0
    
    @ZTJSONTransformer(TransformDouble)
    @ZTJSONKey("geo/lng")
    var lng = 0.0
}



@ZTJSON
struct Geo {
    @ZTJSONTransformer(TransformDouble)
    var lat: Double = 0
    
    @ZTJSONTransformer(TransformDouble)
    var lng = 0.0
}






@ZTJSON
class User {
    // ignore static 
    @MainActor
    static var clsName = "User"
    
    // ignore lazy 
    lazy var uuid = {
        UUID().uuidString
    }
    
    // lazy default value for let property
    @ZTJSONLetDefValue(0)
    let id: Int
    @ZTJSONLetDefValue("")
    let name: String
    @ZTJSONLetDefValue("")
    let username: String
    @ZTJSONLetDefValue("")
    let email: String
    
    // infer type
    var phone = ""
    
    @ZTJSONTransformer(TransformHttp)
    var website:URL?
    
    var company: Company = .init()
    
    // support Optional var property
    var address: Address?
    
    // support enum 
    var pet: Animal = .dog
}


extension User {
    @ZTJSON
    class A {
        var val3: [String: String] = [String: String].init()
        var val4: [Int] = [123] + [4]
    }
}




// MARK: - nest

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
    
    @ZTJSONTransformer(TransformDouble)
    @ZTJSONKey("address/geo/lat")
    var lat: Double = 0
    
    @ZTJSONTransformer(TransformDouble)
    @ZTJSONKey("address/geo/lng")
    var lng = 0.0
}








// MARK: - Demo

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
                print(json.type)
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
                }
                // Or
                if let usr: [User] = r[xpath: "/"] {
                    print("users", usr)
                }
                print("result \(r)")
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
            .init(type: [NestAddress].self)
])


```
