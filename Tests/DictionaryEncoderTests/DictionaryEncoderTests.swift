//
//  Copyright (c) 2022. Adam Share
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@testable import DictionaryEncoder
import Foundation
import Testing

@Suite("DictionaryEncoder Tests")
struct DictionaryEncoderTests {
    @Test("Encode without options")
    func encodeNoOptions() throws {
        let encoder = DictionaryEncoder()
        let dictionary: [String: Any] = try encoder.encode(TestEncodable())
        #expect(dictionary == TestEncodable.asEncodedNoOptions)
    }

    @Test("Encode with options")
    func encodeWithOptions() throws {
        let encoder = DictionaryEncoder(options: KeepFoundationOptions())
        let dictionary: [String: Any] = try encoder.encode(TestEncodable())
        #expect(dictionary == TestEncodable.asEncoded)
    }

    @Test("Encode enums")
    func enumsEncoding() throws {
        let encoder = DictionaryEncoder()
        let dictionary: [String: Any] = try encoder.encode(TestEnums())
        #expect(dictionary == TestEnums.asEncoded)
    }

    @Test("Super encoder")
    func superEncoder() throws {
        let encoder = DictionaryEncoder()
        let dictionary: [String: Any] = try encoder.encode(ChildKeyedEncodable())
        #expect(dictionary == ChildKeyedEncodable.asEncoded)
    }

    // MARK: - Nested Container Tests

    @Test("Nested unkeyed container in keyed")
    func nestedUnkeyedContainerInKeyed() throws {
        let encoder = DictionaryEncoder()
        let value = EncoderNestedUnkeyedInKeyed(matrix: [[1, 2], [3, 4]])
        let dictionary = try encoder.encode(value)

        let matrix = dictionary["matrix"] as? [[Int]]
        #expect(matrix == [[1, 2], [3, 4]])
    }

    @Test("Nested keyed container in unkeyed")
    func nestedKeyedContainerInUnkeyed() throws {
        let encoder = DictionaryEncoder()
        let value = EncoderNestedKeyedInUnkeyed(items: [
            EncoderNestedKeyedInUnkeyed.Item(id: 1, name: "First"),
            EncoderNestedKeyedInUnkeyed.Item(id: 2, name: "Second"),
        ])
        let dictionary = try encoder.encode(value)

        let items = dictionary["items"] as? [[String: Any]]
        #expect(items?.count == 2)
        #expect(items?[0]["id"] as? Int == 1)
        #expect(items?[0]["name"] as? String == "First")
    }

    // MARK: - EncodeNil Tests

    @Test("Encode nil in keyed container")
    func encodeNilInKeyedContainer() throws {
        let encoder = DictionaryEncoder()
        let value = EncoderNilValue()
        let dictionary = try encoder.encode(value)

        #expect(dictionary["nullValue"] is NSNull)
        #expect(dictionary["stringValue"] as? String == "hello")
    }

    @Test("Encode nil in unkeyed container")
    func encodeNilInUnkeyedContainer() throws {
        let encoder = DictionaryEncoder()
        let value = EncoderUnkeyedNilValue()
        let dictionary = try encoder.encode(value)

        let values = dictionary["values"] as? [Any]
        #expect(values?.count == 3)
        #expect(values?[0] is NSNull)
        #expect(values?[1] as? String == "hello")
        #expect(values?[2] is NSNull)
    }

    // MARK: - Primitive Encoding Tests

    @Test("Encode all primitive types")
    func allPrimitivesEncoding() throws {
        let encoder = DictionaryEncoder()
        let value = EncoderAllPrimitives(
            boolVar: true,
            stringVar: "test",
            doubleVar: 3.14,
            floatVar: 2.5,
            intVar: 42,
            int8Var: 8,
            int16Var: 16,
            int32Var: 32,
            int64Var: 64,
            uintVar: 100,
            uint8Var: 8,
            uint16Var: 16,
            uint32Var: 32,
            uint64Var: 64
        )
        let dictionary = try encoder.encode(value)

        #expect(dictionary["boolVar"] as? Bool == true)
        #expect(dictionary["stringVar"] as? String == "test")
        #expect(dictionary["doubleVar"] as? Double == 3.14)
        #expect(dictionary["floatVar"] as? Float == 2.5)
        #expect(dictionary["intVar"] as? Int == 42)
        #expect(dictionary["int8Var"] as? Int8 == 8)
        #expect(dictionary["int16Var"] as? Int16 == 16)
        #expect(dictionary["int32Var"] as? Int32 == 32)
        #expect(dictionary["int64Var"] as? Int64 == 64)
        #expect(dictionary["uintVar"] as? UInt == 100)
        #expect(dictionary["uint8Var"] as? UInt8 == 8)
        #expect(dictionary["uint16Var"] as? UInt16 == 16)
        #expect(dictionary["uint32Var"] as? UInt32 == 32)
        #expect(dictionary["uint64Var"] as? UInt64 == 64)
    }

    // MARK: - Error Tests

    @Test("Encoding non-keyed container throws")
    func encodingNonKeyedContainerThrows() throws {
        let encoder = DictionaryEncoder()

        // Single value container at top level should throw
        #expect(throws: DictionaryEncoderError.self) {
            try encoder.encode("just a string")
        }
    }

    @Test("Encoding array throws")
    func encodingArrayThrows() throws {
        let encoder = DictionaryEncoder()

        // Array at top level should throw
        #expect(throws: DictionaryEncoderError.self) {
            try encoder.encode([1, 2, 3])
        }
    }

    @Test("Error description")
    func errorDescription() throws {
        let error = DictionaryEncoderError.notKeyedContainer("test")
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.contains("test") ?? false)
    }

    // MARK: - Unkeyed Container Tests

    @Test("Unkeyed container encode Encodable type")
    func unkeyedContainerEncodeEncodable() throws {
        let encoder = DictionaryEncoder()
        let value = EncoderUnkeyedEncodable(items: [
            EncoderUnkeyedEncodable.Item(name: "first"),
            EncoderUnkeyedEncodable.Item(name: "second"),
        ])
        let dictionary = try encoder.encode(value)

        let items = dictionary["items"] as? [[String: Any]]
        #expect(items?.count == 2)
        #expect(items?[0]["name"] as? String == "first")
        #expect(items?[1]["name"] as? String == "second")
    }

    @Test("Unkeyed container nested unkeyed container")
    func unkeyedNestedUnkeyedContainer() throws {
        let encoder = DictionaryEncoder()
        let value = EncoderUnkeyedNestedUnkeyed(matrix: [[1, 2], [3, 4]])
        let dictionary = try encoder.encode(value)

        let matrix = dictionary["matrix"] as? [[Any]]
        #expect(matrix?.count == 2)
    }

    @Test("Unkeyed container encode Bool")
    func unkeyedContainerEncodeBool() throws {
        let encoder = DictionaryEncoder()
        let value = EncoderUnkeyedBool(values: [true, false, true])
        let dictionary = try encoder.encode(value)

        let values = dictionary["values"] as? [Bool]
        #expect(values == [true, false, true])
    }
}

struct TestEncodable: Encodable {
    var stringVar = "string"
    var intVar = 1
    var uintVar: UInt = 2
    var doubleVar: Double = 3
    var floatVar: Float = 4
    var boolVar = true
    var dateVar = Date(timeIntervalSince1970: 1500)
    var urlVar: URL? = URL(string: "tryotter.com")
    var nullVar = NSNull()

    var enums = TestEnums()
    var arrayVar: [TestNestedEncodable] = [TestNestedEncodable(), TestNestedEncodable()]
    var arrayIntVar: [Int] = [1, 2, 3, 4]
    var dictNestedVar: [String: [TestNestedEncodable]] = ["keyNested": [TestNestedEncodable(), TestNestedEncodable()]]
    var dictVar: [String: [String: [Int]]] = ["dictKey0": ["dictKey2": [1, 2, 3, 4]]]

    static var asEncoded: [String: Any] {
        [
            "stringVar": "string",
            "intVar": Int(1),
            "uintVar": UInt(2),
            "doubleVar": Double(3),
            "floatVar": Float(4),
            "boolVar": true,
            "dateVar": Date(timeIntervalSince1970: 1500.0),
            "urlVar": URL(string: "tryotter.com")! as Any,
            "nullVar": NSNull(),
            "enums": TestEnums.asEncoded,
            "arrayVar": [
                TestNestedEncodable.asEncoded,
                TestNestedEncodable.asEncoded,
            ],
            "arrayIntVar": [1, 2, 3, 4],
            "dictNestedVar": [
                "keyNested": [
                    TestNestedEncodable.asEncoded,
                    TestNestedEncodable.asEncoded,
                ],
            ],
            "dictVar": ["dictKey0": ["dictKey2": [1, 2, 3, 4]]],
        ]
    }

    static var asEncodedNoOptions: [String: Any] {
        [
            "stringVar": "string",
            "intVar": Int(1),
            "uintVar": UInt(2),
            "doubleVar": Double(3),
            "floatVar": Float(4),
            "boolVar": true,
            "dateVar": TimeInterval(-978_305_700),
            "urlVar": ["relative": "tryotter.com"],
            "nullVar": NSNull(),
            "enums": TestEnums.asEncoded,
            "arrayVar": [
                TestNestedEncodable.asEncoded,
                TestNestedEncodable.asEncoded,
            ],
            "arrayIntVar": [1, 2, 3, 4],
            "dictNestedVar": [
                "keyNested": [
                    TestNestedEncodable.asEncoded,
                    TestNestedEncodable.asEncoded,
                ],
            ],
            "dictVar": ["dictKey0": ["dictKey2": [1, 2, 3, 4]]],
        ]
    }
}

struct TestEnums: Encodable {
    var keyedEnumEmpty = KeyedEnum.empty
    var keyedEnumWithString = KeyedEnum.withString(stringValue: "test string")
    var unkeyedEnumEmpty = UnkeyedEnum.empty
    var unkeyedEnumWithString = UnkeyedEnum.withString("test string")
    var stringEnum = StringEnum.testStringEnum
    var intEnum = IntEnum.one

    enum KeyedEnum: Encodable {
        case empty
        case withString(stringValue: String)
    }

    enum UnkeyedEnum: Encodable {
        case empty
        case withString(String)
    }

    enum StringEnum: String, Encodable {
        case testStringEnum
    }

    enum IntEnum: Int, Encodable {
        case one = 1
    }

    static var asEncoded: [String: Any] {
        [
            "unkeyedEnumWithString": [
                "withString": [
                    "_0": "test string",
                ],
            ],
            "stringEnum": "testStringEnum",
            "unkeyedEnumEmpty": [
                "empty": [:],
            ],
            "keyedEnumEmpty": [
                "empty": [:],
            ],
            "keyedEnumWithString": [
                "withString": [
                    "stringValue": "test string",
                ],
            ],
            "intEnum": 1,
        ]
    }
}

struct TestNestedEncodable: Encodable {
    var stringVar = "testNested"
    var nested = DoubleNestedEncodable()

    static var asEncoded: [String: Any] {
        [
            "stringVar": "testNested",
            "nested": DoubleNestedEncodable.asEncoded,
        ]
    }

    struct DoubleNestedEncodable: Encodable {
        var stringVar = "testDoubleNested"

        static var asEncoded: [String: Any] {
            [
                "stringVar": "testDoubleNested",
            ]
        }
    }
}

extension NSNull: @retroactive Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class ParentSingleValueEncodable: Encodable {
    var foo = "Foo"

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(foo)
    }
}

class ChildKeyedEncodable: ParentSingleValueEncodable {
    var bar = 1
    var unkeyed = ChildUnkeyedEncodable()

    private enum CodingKeys: String, CodingKey {
        case bar
        case foo
        case unkeyed
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bar, forKey: .bar)
        try container.encode(unkeyed, forKey: .unkeyed)
        // try super.encode(to: encoder) cannot be called because super uses a different container type.
        try super.encode(to: container.superEncoder())
        try super.encode(to: container.superEncoder(forKey: CodingKeys.foo))
    }

    static var asEncoded: [String: Any] {
        [
            "bar": 1,
            "foo": "Foo",
            "super": "Foo",
            "unkeyed": [
                "Bar",
                "Foo",
            ],
        ]
    }
}

class ChildUnkeyedEncodable: ParentSingleValueEncodable {
    var bar = "Bar"

    override func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(bar)
        // try super.encode(to: encoder) cannot be called because super uses a different container type.
        try super.encode(to: container.superEncoder())
    }
}

// MARK: - Additional Test Types

struct EncoderNestedUnkeyedInKeyed: Encodable {
    var matrix: [[Int]]

    private enum CodingKeys: String, CodingKey {
        case matrix
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .matrix)
        for row in matrix {
            try nestedContainer.encode(row)
        }
    }
}

struct EncoderNestedKeyedInUnkeyed: Encodable {
    var items: [Item]

    struct Item: Encodable {
        var id: Int
        var name: String
    }

    private enum CodingKeys: String, CodingKey {
        case items
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .items)
        for item in items {
            var itemContainer = nestedContainer.nestedContainer(keyedBy: ItemCodingKeys.self)
            try itemContainer.encode(item.id, forKey: .id)
            try itemContainer.encode(item.name, forKey: .name)
        }
    }

    private enum ItemCodingKeys: String, CodingKey {
        case id
        case name
    }
}

struct EncoderNilValue: Encodable {
    private enum CodingKeys: String, CodingKey {
        case nullValue
        case stringValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeNil(forKey: .nullValue)
        try container.encode("hello", forKey: .stringValue)
    }
}

struct EncoderUnkeyedNilValue: Encodable {
    private enum CodingKeys: String, CodingKey {
        case values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .values)
        try nestedContainer.encodeNil()
        try nestedContainer.encode("hello")
        try nestedContainer.encodeNil()
    }
}

struct EncoderAllPrimitives: Encodable {
    var boolVar: Bool
    var stringVar: String
    var doubleVar: Double
    var floatVar: Float
    var intVar: Int
    var int8Var: Int8
    var int16Var: Int16
    var int32Var: Int32
    var int64Var: Int64
    var uintVar: UInt
    var uint8Var: UInt8
    var uint16Var: UInt16
    var uint32Var: UInt32
    var uint64Var: UInt64
}

struct EncoderUnkeyedEncodable: Encodable {
    var items: [Item]

    struct Item: Encodable {
        var name: String
    }

    private enum CodingKeys: String, CodingKey {
        case items
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .items)
        for item in items {
            try nestedContainer.encode(item)
        }
    }
}

struct EncoderUnkeyedNestedUnkeyed: Encodable {
    var matrix: [[Int]]

    private enum CodingKeys: String, CodingKey {
        case matrix
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .matrix)
        for row in matrix {
            var rowContainer = nestedContainer.nestedUnkeyedContainer()
            for value in row {
                try rowContainer.encode(value)
            }
        }
    }
}

struct EncoderUnkeyedBool: Encodable {
    var values: [Bool]

    private enum CodingKeys: String, CodingKey {
        case values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .values)
        for value in values {
            try nestedContainer.encode(value)
        }
    }
}

final class KeepFoundationOptions: DictionaryEncoder.Options {
    /// Ensure types that mixpanel will serialize with their own logic do not get encoded into primitives.
    override func shouldEncode<T: Encodable>(_ value: T) -> Bool {
        if let _ = value as? Date {
            return false
        }
        if let _ = value as? URL {
            return false
        }
        if let _ = value as? NSNull {
            return false
        }
        return true
    }
}

extension Dictionary where Value: Any {
    static func == (left: [Key: Value], right: [Key: Value]) -> Bool {
        if left.count != right.count { return false }
        for element in left where !areEqual(right[element.key], element.value) {
            return false
        }
        return true
    }
}

extension Array where Element: Any {
    static func == (left: [Element], right: [Element]) -> Bool {
        if left.count != right.count { return false }
        for (lhs, rhs) in zip(left, right) where !areEqual(lhs, rhs) {
            return false
        }
        return true
    }
}

func areEqual(_ left: Any?, _ right: Any?) -> Bool {
    if type(of: left) == type(of: right),
       String(describing: left) == String(describing: right) { return true }
    if let left = left as? [Any], let right = right as? [Any] { return left == right }
    if let left = left as? [AnyHashable: Any], let right = right as? [AnyHashable: Any] { return left == right }
    return false
}
