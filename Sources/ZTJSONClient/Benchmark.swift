import Foundation
import ZTJSON
import SwiftyJSON

// MARK: - 性能基准测试
// 基于 SwiftBenchmarkJSON 项目中 HandyJSON 的测试结构
// https://github.com/mczachurski/SwiftBenchmarkJSON

// MARK: - 测试数据模型

@ZTJSON
struct TaskClassDto {
    var id: String = ""
    var title: String = ""
    var dueDate: Date = Date()
    var priority: Int = 0
    var status: String = ""
    var tags: [String] = []
    var assignee: AssigneeDto? = nil
    var comments: [CommentDto] = []
    var attachments: [AttachmentDto] = []
    var metadata: [String: String] = [:]
    var isUrgent: Bool = false
    var progress: Double = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

@ZTJSON
struct AssigneeDto {
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var avatarUrl: String? = nil
    var department: String = ""
}

@ZTJSON
struct CommentDto {
    var id: String = ""
    var text: String = ""
    var author: String = ""
    var timestamp: Date = Date()
}

@ZTJSON
struct AttachmentDto {
    var id: String = ""
    var fileName: String = ""
    var fileSize: Int = 0
    var mimeType: String = ""
    var url: String = ""
}

// MARK: - 测试数据生成

extension Date {
    static func randomDate(in range: ClosedRange<Int> = 1...365) -> Date {
        let days = Int.random(in: range)
        return Calendar.current.date(byAdding: .day, value: -days, to: Date())!
    }
}

class TestDataGenerator {
    static func generateSingleTask() -> TaskClassDto {
        TaskClassDto(
            id: UUID().uuidString,
            title: "Complete project documentation \(Int.random(in: 1...1000))",
            dueDate: .randomDate(),
            priority: Int.random(in: 1...5),
            status: ["pending", "in_progress", "completed", "on_hold"].randomElement()!,
            tags: ["documentation", "urgent", "backend", "frontend"].shuffled().prefix(Int.random(in: 1...3)).map { $0 },
            assignee: AssigneeDto(
                id: UUID().uuidString,
                name: "John Doe",
                email: "john.doe@example.com",
                avatarUrl: "https://example.com/avatar.jpg",
                department: "Engineering"
            ),
            comments: (1..<Int.random(in: 1...5)).map { _ in
                CommentDto(
                    id: UUID().uuidString,
                    text: "This is a comment about the task progress and status updates",
                    author: ["Alice", "Bob", "Charlie"].randomElement()!,
                    timestamp: .randomDate(in: 30...90)
                )
            },
            attachments: (0..<Int.random(in: 0...3)).map { _ in
                AttachmentDto(
                    id: UUID().uuidString,
                    fileName: "document_\(Int.random(in: 1...100)).pdf",
                    fileSize: Int.random(in: 1024...1048576),
                    mimeType: "application/pdf",
                    url: "https://example.com/files/\(UUID().uuidString)"
                )
            },
            metadata: [
                "project": "ZTJSON",
                "sprint": "Sprint \(Int.random(in: 1...12))",
                "team": "Platform"
            ],
            isUrgent: Bool.random(),
            progress: Double.random(in: 0...100),
            createdAt: .randomDate(in: 90...365),
            updatedAt: .randomDate(in: 1...30)
        )
    }

    static func generateTaskList(count: Int = 100) -> [TaskClassDto] {
        (1...count).map { _ in generateSingleTask() }
    }

    static func generateJSONString(for task: TaskClassDto) -> String {
        let dateFormatter = ISO8601DateFormatter()
        return """
        {
            "id": "\(task.id)",
            "title": "\(task.title)",
            "dueDate": "\(dateFormatter.string(from: task.dueDate))",
            "priority": \(task.priority),
            "status": "\(task.status)",
            "tags": \(task.tags.description),
            "assignee": {
                "id": "\(task.assignee!.id)",
                "name": "\(task.assignee!.name)",
                "email": "\(task.assignee!.email)",
                "avatarUrl": "\(task.assignee!.avatarUrl ?? "")",
                "department": "\(task.assignee!.department)"
            },
            "comments": [
                {
                    "id": "\(task.comments.first?.id ?? "")",
                    "text": "\(task.comments.first?.text ?? "")",
                    "author": "\(task.comments.first?.author ?? "")",
                    "timestamp": "\(dateFormatter.string(from: task.comments.first?.timestamp ?? Date()))"
                }
            ],
            "attachments": [
                {
                    "id": "\(task.attachments.first?.id ?? "")",
                    "fileName": "\(task.attachments.first?.fileName ?? "")",
                    "fileSize": \(task.attachments.first?.fileSize ?? 0),
                    "mimeType": "\(task.attachments.first?.mimeType ?? "")",
                    "url": "\(task.attachments.first?.url ?? "")"
                }
            ],
            "metadata": \(task.metadata.description),
            "isUrgent": \(task.isUrgent),
            "progress": \(task.progress),
            "createdAt": "\(dateFormatter.string(from: task.createdAt))",
            "updatedAt": "\(dateFormatter.string(from: task.updatedAt))"
        }
        """
    }
}

// MARK: - 基准测试执行器

struct BenchmarkResult {
    let testName: String
    let iterations: Int
    let totalTime: TimeInterval
    let avgTime: TimeInterval
    let opsPerSecond: Double

    var description: String {
        let timeStr: String
        if totalTime < 1 {
            timeStr = String(format: "%.3f ms", totalTime * 1000)
        } else {
            timeStr = String(format: "%.3f s", totalTime)
        }
        return """
        \(testName.padding(toLength: 40, withPad: " ", startingAt: 0)) \
        | \(timeStr.padding(toLength: 12, withPad: " ", startingAt: 0)) \
        | \(String(format: "%.2f ms/op", avgTime * 1000).padding(toLength: 15, withPad: " ", startingAt: 0)) \
        | \(String(format: "%.0f ops/s", opsPerSecond).padding(toLength: 12, withPad: " ", startingAt: 0))
        """
    }
}

class BenchmarkRunner {
    static func run(_ name: String, iterations: Int = 10_000, warmup: Int = 100, block: () -> Void) -> BenchmarkResult {
        // Warmup
        print("  [Warming up \(name)...]")
        for _ in 0..<warmup {
            block()
        }

        // Measure
        print("  [Running \(iterations) iterations...]")
        let startTime = Date()
        for _ in 0..<iterations {
            block()
        }
        let endTime = Date()
        let totalTime = endTime.timeIntervalSince(startTime)
        let avgTime = totalTime / Double(iterations)
        let opsPerSecond = 1.0 / avgTime

        return BenchmarkResult(
            testName: name,
            iterations: iterations,
            totalTime: totalTime,
            avgTime: avgTime,
            opsPerSecond: opsPerSecond
        )
    }
}

// MARK: - 主测试执行

/// ZTJSONInitializable 方式测试 - 直接使用 init(from: JSON)
func runZTJSONInitializableBenchmarks() {
    print("\n" + String(repeating: "=", count: 120))
    print("ZTJSONInitializable 性能基准测试".center(width: 120))
    print("直接使用 init(from: JSON) 方法 - 与 HandyJSON 对比")
    print(String(repeating: "=", count: 120))

    var results: [BenchmarkResult] = []

    // 准备测试数据
    let singleObject = TestDataGenerator.generateSingleTask()
    let objectList = TestDataGenerator.generateTaskList(count: 100)
    let singleTaskJSON = singleObject.asJSONValue()
    let taskListJSON = objectList.asJSONValue()

    // MARK: Test 1: Encoding single object (asJSONValue)
    print("\n[Test 1] 编码单个对象 (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let encodeSingleResult = BenchmarkRunner.run("Encode single object") {
        _ = singleObject.asJSONValue()
    }
    results.append(encodeSingleResult)

    // MARK: Test 2: Encoding list of 100 objects
    print("\n[Test 2] 编码 100 个对象列表 (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let encodeListResult = BenchmarkRunner.run("Encode list of 100 objects") {
        _ = objectList.asJSONValue()
    }
    results.append(encodeListResult)

    // MARK: Test 3: Decoding single object (ZTJSONInitializable)
    print("\n[Test 3] 解码单个对象 - ZTJSONInitializable.init(from: JSON) (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let decodeSingleResult = BenchmarkRunner.run("Decode single (ZTJSONInit)") {
        _ = try! TaskClassDto(from: singleTaskJSON)
    }
    results.append(decodeSingleResult)

    // MARK: Test 4: Decoding list of 100 objects (ZTJSONInitializable)
    print("\n[Test 4] 解码 100 个对象列表 - ZTJSONInitializable.init(from: JSON) (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let decodeListResult = BenchmarkRunner.run("Decode list (ZTJSONInit)") {
        _ = try! [TaskClassDto](from: taskListJSON)
    }
    results.append(decodeListResult)

    // MARK: Print summary
    print("\n" + String(repeating: "=", count: 120))
    print("ZTJSONInitializable 测试结果汇总".center(width: 120))
    print(String(repeating: "=", count: 120))
    print(String(repeating: "-", count: 120))
    print("Test Name".padding(toLength: 40, withPad: " ", startingAt: 0) +
          " | " + "Total Time".padding(toLength: 12, withPad: " ", startingAt: 0) +
          " | " + "Avg Time".padding(toLength: 15, withPad: " ", startingAt: 0) +
          " | " + "Throughput".padding(toLength: 12, withPad: " ", startingAt: 0))
    print(String(repeating: "-", count: 120))

    for result in results {
        print(result.description)
    }

    print(String(repeating: "-", count: 120))
    print("\n参考: HandyJSON 相同测试结果 (来自 SwiftBenchmarkJSON):")
    print("  编码单个对象 (10k):     ~3.885 s    (~0.389 ms/op, ~2,574 ops/s)")
    print("  编码100对象列表 (10k):  ~336.651 s  (~33.665 ms/op, ~30 ops/s)")
    print("  解码单个对象 (10k):     ~3.550 s    (~0.355 ms/op, ~2,817 ops/s)")
    print("  解码100对象列表 (10k):  ~318.817 s  (~31.882 ms/op, ~31 ops/s)")
    print(String(repeating: "=", count: 120))
}

/// Codable 方式测试 - 使用 JSONEncoder/JSONDecoder
func runCodableBenchmarks() {
    print("\n" + String(repeating: "=", count: 120))
    print("Codable 性能基准测试".center(width: 120))
    print("使用 JSONEncoder/JSONDecoder - 包含 base64 编码开销")
    print(String(repeating: "=", count: 120))

    var results: [BenchmarkResult] = []

    // 准备测试数据
    let singleObject = TestDataGenerator.generateSingleTask()
    let objectList = TestDataGenerator.generateTaskList(count: 100)
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    // 预先编码一次，获取测试用的 Data
    let singleEncodedData = try! encoder.encode(singleObject)
    let listEncodedData = try! encoder.encode(objectList)

    // MARK: Test 1: Encoding single object (Codable)
    print("\n[Test 1] 编码单个对象 (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let encodeSingleResult = BenchmarkRunner.run("Encode single (Codable)") {
        _ = try! encoder.encode(singleObject)
    }
    results.append(encodeSingleResult)

    // MARK: Test 2: Encoding list of 100 objects (Codable)
    print("\n[Test 2] 编码 100 个对象列表 (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let encodeListResult = BenchmarkRunner.run("Encode list (Codable)") {
        _ = try! encoder.encode(objectList)
    }
    results.append(encodeListResult)

    // MARK: Test 3: Decoding single object (Codable)
    print("\n[Test 3] 解码单个对象 - JSONDecoder.decode (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let decodeSingleResult = BenchmarkRunner.run("Decode single (Codable)") {
        _ = try! decoder.decode(TaskClassDto.self, from: singleEncodedData)
    }
    results.append(decodeSingleResult)

    // MARK: Test 4: Decoding list of 100 objects (Codable)
    print("\n[Test 4] 解码 100 个对象列表 - JSONDecoder.decode (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let decodeListResult = BenchmarkRunner.run("Decode list (Codable)") {
        _ = try! decoder.decode([TaskClassDto].self, from: listEncodedData)
    }
    results.append(decodeListResult)

    // MARK: Print summary
    print("\n" + String(repeating: "=", count: 120))
    print("Codable 测试结果汇总".center(width: 120))
    print(String(repeating: "=", count: 120))
    print(String(repeating: "-", count: 120))
    print("Test Name".padding(toLength: 40, withPad: " ", startingAt: 0) +
          " | " + "Total Time".padding(toLength: 12, withPad: " ", startingAt: 0) +
          " | " + "Avg Time".padding(toLength: 15, withPad: " ", startingAt: 0) +
          " | " + "Throughput".padding(toLength: 12, withPad: " ", startingAt: 0))
    print(String(repeating: "-", count: 120))

    for result in results {
        print(result.description)
    }

    print(String(repeating: "-", count: 120))
    print("\n注意: Codable 方式由于需要 base64 编码/解码 JSON 数据，性能会低于 ZTJSONInitializable")
    print(String(repeating: "=", count: 120))
}

/// 综合测试 - 对比 ZTJSONInitializable 和 Codable
func runPerformanceBenchmarks() {
    runZTJSONInitializableBenchmarks()
    runCodableBenchmarks()
}

// MARK: - ignoreXPath 性能对比测试

/// 使用 ignoreXPath: false（旧实现，base64 编码）的测试模型
@ZTJSON(ignoreXPath: false)
struct LegacyCodableDto {
    var id: String = ""
    var title: String = ""
    var priority: Int = 0
    var status: String = ""
    var tags: [String] = []
    var isUrgent: Bool = false
    var progress: Double = 0
}

/// 使用 ignoreXPath: true（新实现，标准 Codable）的测试模型
@ZTJSON(ignoreXPath: true)
struct StandardCodableDto {
    var id: String = ""
    var title: String = ""
    var priority: Int = 0
    var status: String = ""
    var tags: [String] = []
    var isUrgent: Bool = false
    var progress: Double = 0
}

/// 对比 ignoreXPath: true 和 ignoreXPath: false 的性能
func runIgnoreXPathComparison() {
    print("\n" + String(repeating: "=", count: 120))
    print("ignoreXPath 性能对比测试".center(width: 120))
    print("对比标准 Codable vs base64 编码方式的性能差异")
    print(String(repeating: "=", count: 120))

    var results: [BenchmarkResult] = []

    // 准备测试数据
    func makeDto() -> StandardCodableDto {
        StandardCodableDto(
            id: UUID().uuidString,
            title: "Task \(Int.random(in: 1...1000))",
            priority: Int.random(in: 1...5),
            status: ["pending", "done", "in_progress"].randomElement()!,
            tags: ["tag1", "tag2"],
            isUrgent: Bool.random(),
            progress: Double.random(in: 0...100)
        )
    }

    let dtoList = (1..<100).map { _ in makeDto() }

    // MARK: Test 1: 标准 Codable (ignoreXPath: true) 编码
    print("\n[Test 1] 标准 Codable 编码 - ignoreXPath: true (10,000 次迭代)")
    print(String(repeating: "-", count: 60))
    let encoder = JSONEncoder()
    let encodeStandardResult = BenchmarkRunner.run("Encode (ignoreXPath: true)") {
        _ = try! encoder.encode(dtoList)
    }
    results.append(encodeStandardResult)

    // MARK: Test 2: 旧版 Codable (ignoreXPath: false) 编码
    print("\n[Test 2] 旧版 Codable 编码 - ignoreXPath: false (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    // 转换为 LegacyCodableDto 类型
    let legacyList = dtoList.map { dto -> LegacyCodableDto in
        LegacyCodableDto(
            id: dto.id,
            title: dto.title,
            priority: dto.priority,
            status: dto.status,
            tags: dto.tags,
            isUrgent: dto.isUrgent,
            progress: dto.progress
        )
    }

    let encodeLegacyResult = BenchmarkRunner.run("Encode (ignoreXPath: false)") {
        _ = try! encoder.encode(legacyList)
    }
    results.append(encodeLegacyResult)

    // MARK: Test 3: 标准 Codable 解码
    print("\n[Test 3] 标准 Codable 解码 - ignoreXPath: true (10,000 次迭代)")
    print(String(repeating: "-", count: 60))
    let standardData = try! encoder.encode(dtoList)
    let decoder = JSONDecoder()
    let decodeStandardResult = BenchmarkRunner.run("Decode (ignoreXPath: true)") {
        _ = try! decoder.decode([StandardCodableDto].self, from: standardData)
    }
    results.append(decodeStandardResult)

    // MARK: Test 4: 旧版 Codable 解码
    print("\n[Test 4] 旧版 Codable 解码 - ignoreXPath: false (10,000 次迭代)")
    print(String(repeating: "-", count: 60))
    let legacyData = try! encoder.encode(legacyList)
    let decodeLegacyResult = BenchmarkRunner.run("Decode (ignoreXPath: false)") {
        _ = try! decoder.decode([LegacyCodableDto].self, from: legacyData)
    }
    results.append(decodeLegacyResult)

    // MARK: Print summary
    print("\n" + String(repeating: "=", count: 120))
    print("ignoreXPath 对比结果汇总".center(width: 120))
    print(String(repeating: "=", count: 120))
    print(String(repeating: "-", count: 120))
    print("Test Name".padding(toLength: 40, withPad: " ", startingAt: 0) +
          " | " + "Total Time".padding(toLength: 12, withPad: " ", startingAt: 0) +
          " | " + "Avg Time".padding(toLength: 15, withPad: " ", startingAt: 0) +
          " | " + "Throughput".padding(toLength: 12, withPad: " ", startingAt: 0))
    print(String(repeating: "-", count: 120))

    for result in results {
        print(result.description)
    }

    // 计算性能提升
    if encodeStandardResult.totalTime > 0 && encodeLegacyResult.totalTime > 0 {
        let encodeSpeedup = encodeLegacyResult.totalTime / encodeStandardResult.totalTime
        print(String(repeating: "-", count: 120))
        print("编码性能提升: \(String(format: "%.2fx", encodeSpeedup)) 倍")
    }
    if decodeStandardResult.totalTime > 0 && decodeLegacyResult.totalTime > 0 {
        let decodeSpeedup = decodeLegacyResult.totalTime / decodeStandardResult.totalTime
        print("解码性能提升: \(String(format: "%.2fx", decodeSpeedup)) 倍")
    }
    print(String(repeating: "=", count: 120))
}

// MARK: - 与 HandyJSON 的性能对比

/// ZTJSON (ignoreXPath: true) 与 HandyJSON 的性能对比
/// 使用与 HandyJSON 相同的数据结构 (TaskClassDto) 进行公平对比
func runHandyJSONComparison() {
    print("\n" + String(repeating: "=", count: 120))
    print("ZTJSON vs HandyJSON 性能对比 (相同数据结构)".center(width: 120))
    print("数据来源: SwiftBenchmarkJSON (https://github.com/mczachurski/SwiftBenchmarkJSON)")
    print(String(repeating: "=", count: 120))

    // HandyJSON 性能数据 (来自 SwiftBenchmarkJSON，使用 TaskClassDto)
    // 测试: 10,000 次迭代
    struct HandyJSONData {
        let encodeSingle: Double = 0.389      // ms/op
        let encodeList100: Double = 33.665    // ms/op
        let decodeSingle: Double = 0.355      // ms/op
        let decodeList100: Double = 31.882    // ms/op
    }

    // ZTJSON (ignoreXPath: true) 性能数据
    struct ZTJSONData {
        let encodeSingle: Double
        let encodeList100: Double
        let decodeSingle: Double
        let decodeList100: Double
    }

    let handy = HandyJSONData()

    // 使用 TaskClassDto (与 HandyJSON 相同的数据结构)
    let singleObject = TestDataGenerator.generateSingleTask()
    let objectList = TestDataGenerator.generateTaskList(count: 100)
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    // 测试 ZTJSON (ignoreXPath: true，默认值)
    print("\n[ZTJSON 测试 - 使用 TaskClassDto] (10,000 次迭代)")
    print(String(repeating: "-", count: 60))

    let ztEncodeSingle = BenchmarkRunner.run("ZTJSON encode single") {
        _ = try! encoder.encode(singleObject)
    }

    let ztEncodeList = BenchmarkRunner.run("ZTJSON encode list") {
        _ = try! encoder.encode(objectList)
    }

    let singleData = try! encoder.encode(singleObject)
    let listData = try! encoder.encode(objectList)

    let ztDecodeSingle = BenchmarkRunner.run("ZTJSON decode single") {
        _ = try! decoder.decode(TaskClassDto.self, from: singleData)
    }

    let ztDecodeList = BenchmarkRunner.run("ZTJSON decode list") {
        _ = try! decoder.decode([TaskClassDto].self, from: listData)
    }

    let zt = ZTJSONData(
        encodeSingle: ztEncodeSingle.avgTime * 1000,
        encodeList100: ztEncodeList.avgTime * 1000,
        decodeSingle: ztDecodeSingle.avgTime * 1000,
        decodeList100: ztDecodeList.avgTime * 1000
    )

    // 打印对比结果
    print("\n" + String(repeating: "=", count: 120))
    print("性能对比汇总 (单位: ms/op)".center(width: 120))
    print(String(repeating: "=", count: 120))
    print(String(repeating: "-", count: 120))

    let header1 = "".padding(toLength: 25, withPad: " ", startingAt: 0)
    let header2 = "ZTJSON".padding(toLength: 15, withPad: " ", startingAt: 0)
    let header3 = "HandyJSON".padding(toLength: 15, withPad: " ", startingAt: 0)
    let header4 = "差异".padding(toLength: 15, withPad: " ", startingAt: 0)
    let header5 = "对比".padding(toLength: 10, withPad: " ", startingAt: 0)
    print(header1 + " | " + header2 + " | " + header3 + " | " + header4 + " | " + header5)
    print(String(repeating: "-", count: 120))

    func printCompareRow(zt: Double, handy: Double, name: String) {
        let ztStr = String(format: "%.3f", zt).padding(toLength: 15, withPad: " ", startingAt: 0)
        let handyStr = String(format: "%.3f", handy).padding(toLength: 15, withPad: " ", startingAt: 0)
        let diff = ((zt - handy) / handy * 100)
        let diffStr = String(format: "%+.1f%%", diff).padding(toLength: 15, withPad: " ", startingAt: 0)
        let comparison = diff < -10 ? "更快" : (diff > 50 ? "慢" : "接近")
        let compStr = comparison.padding(toLength: 10, withPad: " ", startingAt: 0)
        let nameStr = "    " + name.padding(toLength: 21, withPad: " ", startingAt: 0)
        print(nameStr + " | " + ztStr + " | " + handyStr + " | " + diffStr + " | " + compStr)
    }

    printCompareRow(zt: zt.encodeSingle, handy: handy.encodeSingle, name: "编码单个对象")
    printCompareRow(zt: zt.encodeList100, handy: handy.encodeList100, name: "编码100对象列表")
    printCompareRow(zt: zt.decodeSingle, handy: handy.decodeSingle, name: "解码单个对象")
    printCompareRow(zt: zt.decodeList100, handy: handy.decodeList100, name: "解码100对象列表")

    print(String(repeating: "-", count: 120))
    print("\n说明:")
    print("  - ZTJSON 使用 @ZTJSON(ignoreXPath: true) - 标准 keyedContainer 实现")
    print("  - HandyJSON 数据来自 SwiftBenchmarkJSON，使用运行时反射")
    print("  - 正值表示 ZTJSON 更慢，负值表示 ZTJSON 更快")
    print(String(repeating: "=", count: 120))
}

// Extension for centering text
extension String {
    func center(width: Int) -> String {
        let padding = width - self.count
        if padding <= 0 { return self }
        let leftPadding = padding / 2
        let rightPadding = padding - leftPadding
        return String(repeating: " ", count: leftPadding) + self + String(repeating: " ", count: rightPadding)
    }
}

// Note: Call runPerformanceBenchmarks() from main.swift to execute benchmarks
