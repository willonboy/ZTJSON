import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ZTJSONPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ZTJSON.self,
        ZTJSONSubclass.self,
        ZTJSONKey.self,
        ZTJSONTransformer.self,
        ZTJSONLetDefValue.self,
        ZTJSONExport.self,
        ZTJSONExportSubclass.self,
    ]
}
