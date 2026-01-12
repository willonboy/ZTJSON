import Foundation
import ZTJSON
import SwiftyJSON

// 测试编译时类型检查

// 不支持 ZTJSONExportable 的自定义类型
struct UnsupportedType {
    var value: String = ""
}

// 为 UnsupportedType 扩展 ZTJSONExportable
extension UnsupportedType: ZTJSONExportable {
    func asJSONValue() -> JSON {
        JSON(["value": value])
    }
}

extension UnsupportedType: ZTJSONInitializable {
    init(from json: JSON) throws {
        guard let v = json.dictionaryValue["value"]?.string else {
            throw ZTJSONError.error(code: ZTJSONError.Code.invalidValue, msg: "missing or not a string")
        }
        self.value = v
    }
}

extension UnsupportedType: Codable {}
extension UnsupportedType: Sendable {}

@ZTJSON
struct ShouldCompile {
    var id: Int = 0
    var unsupported: UnsupportedType = UnsupportedType()
}

// 验证已扩展的类型可以正常工作
// 取消下面的注释来验证
/*
let testObj = ShouldCompile(id: 1, unsupported: UnsupportedType(value: "test"))
let json = testObj.asJSONValue()
print("Type check test passed: \(json.rawString() ?? "")")
*/
