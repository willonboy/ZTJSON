import Foundation
import ZTJSON
import SwiftyJSON

// 测试 @ZTJSON 宏的展开
@ZTJSON
struct TestUser {
    var name: String = ""
    var age: Int = 0
}

// 这个宏会自动生成：
// 1. CodingKeys 枚举
// 2. init(from json: JSON) 方法 - 用于 ZTJSONInitializable
// 3. init(from decoder: any Decoder) 方法 - 用于 Codable
// 4. encode(to encoder: any Encoder) 方法 - 用于 Codable
// 5. Memberwise init 方法
