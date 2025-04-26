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

extension Animal: ZTJSONExportable {
    public func asJSONValue() -> JSON {
        JSON(self.rawValue)
    }
}




@ZTJSONExport
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

@ZTJSONExport
@ZTJSON
public class BaseAddress {
    var street = ""
    var suite: String = ""
    var city:String = Bool.random() ? "Shang Hai" : "Bei Jing"
    
    var fullAddr: String {
        city + street + suite
    }
}

@ZTJSONExportSubclass
@ZTJSONSubclass
public class Address: BaseAddress {
    var zipcode: String = ""
    
    @ZTJSONTransformer(TransformDouble)
    @ZTJSONKey("geo/lat")
    var lat: Double = 0
    
    @ZTJSONTransformer(TransformDouble)
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

@ZTJSONExport
@ZTJSON
struct Geo {
    @ZTJSONTransformer(TransformDouble)
    var lat: Double = 0
    
    @ZTJSONTransformer(TransformDouble)
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


@ZTJSONExport
@ZTJSON
class User {
    @MainActor
    static var clsName = "User"
    
    lazy var uuid = {
        UUID().uuidString
    }
    @ZTJSONLetDefValue(0)
    let id: Int
    @ZTJSONLetDefValue("")
    let name: String
    @ZTJSONLetDefValue("")
    let username: String
    @ZTJSONLetDefValue("")
    let email: String
    
    var phone = ""
    
    @ZTJSONTransformer(TransformHttp)
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




@ZTJSONExport
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

extension NestAddress: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
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
                    print("json string \n\n")
                    print("\(usr.asJSONValue().rawString() ?? "")")
                }
                // Or
                if let usr: [User] = r[xpath: "/"] {
                    print("users", usr)
                    print("json string \n\n")
                    print("\(usr.asJSONValue().rawString() ?? "")")
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
            // OR
            //.init(type: [NestAddress].self)
])


