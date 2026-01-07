// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftyJSON

@attached(member, names: named(init(from:)), named(encode(to:)), arbitrary)
@attached(extension, conformances: ZTJSONInitializable, Codable)
public macro ZTJSON() = #externalMacro(module: "ZTJSONMacros", type: "ZTJSON")

@attached(member, names: named(init(from:)), named(encode(to:)), arbitrary)
public macro ZTJSONSubclass() = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONSubclass")

@attached(peer)
public macro ZTJSONKey(_ key: String ...) = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONKey")

@attached(peer)
public macro ZTJSONTransformer(_ transformer: any ZTTransform.Type) = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONTransformer")

@attached(peer)
public macro ZTJSONLetDefValue(_ defValue: Any) = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONLetDefValue")

@attached(peer)
public macro ZTJSONIgnore() = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONIgnore")


@attached(member, names: named(asJSONValue), arbitrary)
@attached(extension, conformances: ZTJSONExportable)
public macro ZTJSONExport() = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONExport")

@attached(member, names: named(asJSONValue), arbitrary)
public macro ZTJSONExportSubclass() = #externalMacro(module: "ZTJSONMacros", type: "ZTJSONExportSubclass")
