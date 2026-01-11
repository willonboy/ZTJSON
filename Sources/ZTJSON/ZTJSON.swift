// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftyJSON

@attached(member, names: named(init(from:)), named(encode(to:)), named(asJSONValue), arbitrary)
@attached(extension, conformances: ZTJSONInitializable, ZTJSONExportable, Codable)
public macro ZTJSON(ignoreXPath: Bool = true) = #externalMacro(module: "ZTJSONMacros", type: "ZTJSON")

@attached(member, names: named(init(from:)), named(encode(to:)), named(asJSONValue), arbitrary)
public macro ZTJSONSubclass(ignoreXPath: Bool = true) = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONSubclass")

@attached(peer)
public macro ZTJSONKey(_ key: String ...) = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONKey")

@attached(peer)
public macro ZTJSONTransformer(_ transformer: any ZTTransform.Type) = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONTransformer")

@attached(peer)
public macro ZTJSONLetDefValue(_ defValue: Any) = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONLetDefValue")

@attached(peer)
public macro ZTJSONIgnore() = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONIgnore")

@attached(member, names: named(key), named(value), arbitrary)
public macro ZTAPIParam() = #externalMacro(module: "ZTJSONMacros", type: "ZTAPIParam")

@attached(peer)
public macro ZTAPIParamKey(_ key: String) = #externalMacro(module: "ZTJSONMacros", type: "ZTAPIParamKey")
