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

@Suite("DictionaryDecoder Tests")
struct DictionaryDecoderTests {
    // MARK: - Round Trip Tests

    @Test("Round trip encoding and decoding without options")
    func roundTripNoOptions() throws {
        let original = TestCodable()
        let encoder = DictionaryEncoder()
        let decoder = DictionaryDecoder()

        let dictionary = try encoder.encode(original)
        let decoded = try decoder.decode(TestCodable.self, from: dictionary)

        #expect(decoded.stringVar == original.stringVar)
        #expect(decoded.intVar == original.intVar)
        #expect(decoded.uintVar == original.uintVar)
        #expect(decoded.doubleVar == original.doubleVar)
        #expect(decoded.floatVar == original.floatVar)
        #expect(decoded.boolVar == original.boolVar)
        #expect(decoded.arrayIntVar == original.arrayIntVar)
    }

    @Test("Round trip encoding and decoding with options")
    func roundTripWithOptions() throws {
        let original = TestCodable()
        let encoder = DictionaryEncoder(options: KeepFoundationEncoderOptions())
        let decoder = DictionaryDecoder(options: KeepFoundationDecoderOptions())

        let dictionary = try encoder.encode(original)
        let decoded = try decoder.decode(TestCodable.self, from: dictionary)

        #expect(decoded.stringVar == original.stringVar)
        #expect(decoded.intVar == original.intVar)
        #expect(decoded.dateVar == original.dateVar)
        #expect(decoded.urlVar == original.urlVar)
    }

    @Test("Round trip with nested structures")
    func roundTripNestedStructures() throws {
        let original = TestCodable()
        let encoder = DictionaryEncoder()
        let decoder = DictionaryDecoder()

        let dictionary = try encoder.encode(original)
        let decoded = try decoder.decode(TestCodable.self, from: dictionary)

        #expect(decoded.arrayVar.count == original.arrayVar.count)
        #expect(decoded.arrayVar[0].stringVar == original.arrayVar[0].stringVar)
        #expect(decoded.arrayVar[0].nested.stringVar == original.arrayVar[0].nested.stringVar)
    }

    @Test("Round trip with enums")
    func roundTripEnums() throws {
        let original = TestCodableEnums()
        let encoder = DictionaryEncoder()
        let decoder = DictionaryDecoder()

        let dictionary = try encoder.encode(original)
        let decoded = try decoder.decode(TestCodableEnums.self, from: dictionary)

        #expect(decoded.stringEnum == original.stringEnum)
        #expect(decoded.intEnum == original.intEnum)
    }

    // MARK: - Primitive Decoding Tests

    @Test("Decode all primitive types")
    func decodePrimitives() throws {
        let dictionary: [String: Any] = [
            "stringVar": "test",
            "intVar": 42,
            "uintVar": UInt(100),
            "doubleVar": 3.14,
            "floatVar": Float(2.5),
            "boolVar": true,
            "int8Var": Int8(8),
            "int16Var": Int16(16),
            "int32Var": Int32(32),
            "int64Var": Int64(64),
            "uint8Var": UInt8(8),
            "uint16Var": UInt16(16),
            "uint32Var": UInt32(32),
            "uint64Var": UInt64(64),
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(AllPrimitives.self, from: dictionary)

        #expect(decoded.stringVar == "test")
        #expect(decoded.intVar == 42)
        #expect(decoded.uintVar == 100)
        #expect(decoded.doubleVar == 3.14)
        #expect(decoded.floatVar == 2.5)
        #expect(decoded.boolVar == true)
        #expect(decoded.int8Var == 8)
        #expect(decoded.int16Var == 16)
        #expect(decoded.int32Var == 32)
        #expect(decoded.int64Var == 64)
        #expect(decoded.uint8Var == 8)
        #expect(decoded.uint16Var == 16)
        #expect(decoded.uint32Var == 32)
        #expect(decoded.uint64Var == 64)
    }

    // MARK: - NSNumber Bridging Tests

    @Test("NSNumber bridging for numeric types")
    func nsNumberBridging() throws {
        let dictionary: [String: Any] = [
            "stringVar": "test",
            "intVar": NSNumber(value: 42),
            "uintVar": NSNumber(value: 100),
            "doubleVar": NSNumber(value: 3.14),
            "floatVar": NSNumber(value: 2.5),
            "boolVar": NSNumber(value: true),
            "int8Var": NSNumber(value: 8),
            "int16Var": NSNumber(value: 16),
            "int32Var": NSNumber(value: 32),
            "int64Var": NSNumber(value: 64),
            "uint8Var": NSNumber(value: 8),
            "uint16Var": NSNumber(value: 16),
            "uint32Var": NSNumber(value: 32),
            "uint64Var": NSNumber(value: 64),
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(AllPrimitives.self, from: dictionary)

        #expect(decoded.intVar == 42)
        #expect(decoded.boolVar == true)
        #expect(decoded.doubleVar == 3.14)
    }

    // MARK: - Optional Decoding Tests

    @Test("Decode optional values including nil")
    func decodeOptionals() throws {
        let dictionary: [String: Any] = [
            "presentValue": "hello",
            "nullValue": NSNull(),
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(OptionalValues.self, from: dictionary)

        #expect(decoded.presentValue == "hello")
        #expect(decoded.nullValue == nil)
        #expect(decoded.missingValue == nil)
    }

    // MARK: - Array Decoding Tests

    @Test("Decode array of objects")
    func decodeArray() throws {
        let dictionary: [String: Any] = [
            "items": [
                ["name": "Item 1"],
                ["name": "Item 2"],
                ["name": "Item 3"],
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(ArrayContainer.self, from: dictionary)

        #expect(decoded.items.count == 3)
        #expect(decoded.items[0].name == "Item 1")
        #expect(decoded.items[1].name == "Item 2")
        #expect(decoded.items[2].name == "Item 3")
    }

    @Test("Decode array of primitives")
    func decodePrimitiveArray() throws {
        let dictionary: [String: Any] = [
            "numbers": [1, 2, 3, 4, 5]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(PrimitiveArrayContainer.self, from: dictionary)

        #expect(decoded.numbers == [1, 2, 3, 4, 5])
    }

    // MARK: - Nested Dictionary Tests

    @Test("Decode nested dictionary")
    func decodeNestedDictionary() throws {
        let dictionary: [String: Any] = [
            "metadata": [
                "key1": "value1",
                "key2": "value2",
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(DictionaryContainer.self, from: dictionary)

        #expect(decoded.metadata["key1"] == "value1")
        #expect(decoded.metadata["key2"] == "value2")
    }

    // MARK: - Error Cases

    @Test("Type mismatch error")
    func typeMismatchError() throws {
        let dictionary: [String: Any] = [
            "stringVar": 123,
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(SimpleStruct.self, from: dictionary)
        }
    }

    @Test("Key not found error")
    func keyNotFoundError() throws {
        let dictionary: [String: Any] = [:]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(SimpleStruct.self, from: dictionary)
        }
    }

    // MARK: - Super Decoder Tests

    @Test("Super decoder for class inheritance")
    func superDecoder() throws {
        let dictionary: [String: Any] = [
            "bar": 42,
            "unkeyed": ["Bar", "Foo"],
            "super": "Foo",
            "foo": "Foo",
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(ChildKeyedDecodable.self, from: dictionary)

        #expect(decoded.bar == 42)
        #expect(decoded.foo == "Foo")
    }

    // MARK: - Unkeyed Container Primitive Tests

    @Test("Unkeyed container with all primitive types")
    func unkeyedContainerPrimitives() throws {
        let dictionary: [String: Any] = [
            "values": [
                true,
                "hello",
                3.14,
                Float(2.5),
                42,
                Int8(8),
                Int16(16),
                Int32(32),
                Int64(64),
                UInt(100),
                UInt8(8),
                UInt16(16),
                UInt32(32),
                UInt64(64),
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(UnkeyedPrimitives.self, from: dictionary)

        #expect(decoded.values.count == 14)
    }

    @Test("Unkeyed container with NSNumber values")
    func unkeyedContainerWithNSNumber() throws {
        let dictionary: [String: Any] = [
            "values": [
                NSNumber(value: true),
                NSNumber(value: 42),
                NSNumber(value: 3.14),
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(UnkeyedMixedNumbers.self, from: dictionary)

        #expect(decoded.values[0] == 1.0)
        #expect(decoded.values[1] == 42.0)
        #expect(abs(decoded.values[2] - 3.14) < 0.001)
    }

    @Test("Unkeyed container decode nil")
    func unkeyedContainerDecodeNil() throws {
        let dictionary: [String: Any] = [
            "values": [NSNull(), "hello", NSNull()]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(UnkeyedOptionals.self, from: dictionary)

        #expect(decoded.values[0] == nil)
        #expect(decoded.values[1] == "hello")
        #expect(decoded.values[2] == nil)
    }

    // MARK: - Nested Container Tests

    @Test("Nested keyed container in unkeyed")
    func nestedKeyedContainerInUnkeyed() throws {
        let dictionary: [String: Any] = [
            "items": [
                ["id": 1, "name": "First"],
                ["id": 2, "name": "Second"],
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(NestedKeyedInUnkeyed.self, from: dictionary)

        #expect(decoded.items.count == 2)
        #expect(decoded.items[0].id == 1)
        #expect(decoded.items[0].name == "First")
    }

    @Test("Nested unkeyed container in keyed")
    func nestedUnkeyedContainerInKeyed() throws {
        let dictionary: [String: Any] = [
            "matrix": [
                [1, 2, 3],
                [4, 5, 6],
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(NestedUnkeyedInKeyed.self, from: dictionary)

        #expect(decoded.matrix.count == 2)
        #expect(decoded.matrix[0] == [1, 2, 3])
        #expect(decoded.matrix[1] == [4, 5, 6])
    }

    @Test("Nested unkeyed container in unkeyed")
    func nestedUnkeyedContainerInUnkeyed() throws {
        let dictionary: [String: Any] = [
            "matrix": [
                [1, 2],
                [3, 4],
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(NestedUnkeyedInUnkeyed.self, from: dictionary)

        #expect(decoded.matrix == [[1, 2], [3, 4]])
    }

    @Test("Nested keyed container in keyed")
    func nestedKeyedContainerInKeyed() throws {
        let dictionary: [String: Any] = [
            "outer": [
                "inner": [
                    "value": "deep"
                ]
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(NestedKeyedInKeyed.self, from: dictionary)

        #expect(decoded.outer.inner.value == "deep")
    }

    // MARK: - DecodeNil Tests

    @Test("Keyed container decode nil")
    func keyedContainerDecodeNil() throws {
        let dictionary: [String: Any] = [
            "nullValue": NSNull(),
            "presentValue": "hello",
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(KeyedNilValues.self, from: dictionary)

        #expect(decoded.nullValue == nil)
        #expect(decoded.presentValue == "hello")
        #expect(decoded.missingValue == nil)
    }

    @Test("Single value container decode nil")
    func singleValueContainerDecodeNil() throws {
        let dictionary: [String: Any] = [
            "wrapper": NSNull()
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(SingleValueNilWrapper.self, from: dictionary)

        #expect(decoded.wrapper == nil)
    }

    // MARK: - Error Description Tests

    @Test("Type mismatch error description")
    func typeMismatchErrorDescription() throws {
        let dictionary: [String: Any] = [
            "stringVar": 123,
        ]

        let decoder = DictionaryDecoder()
        do {
            _ = try decoder.decode(SimpleStruct.self, from: dictionary)
            Issue.record("Expected error")
        } catch let error as DecodingError {
            let description = String(describing: error)
            #expect(description.contains("typeMismatch"))
        }
    }

    @Test("Key not found error description")
    func keyNotFoundErrorDescription() throws {
        let dictionary: [String: Any] = [:]

        let decoder = DictionaryDecoder()
        do {
            _ = try decoder.decode(SimpleStruct.self, from: dictionary)
            Issue.record("Expected error")
        } catch let error as DecodingError {
            let description = String(describing: error)
            #expect(description.contains("keyNotFound"))
        }
    }

    // MARK: - Unkeyed Container Error Tests

    @Test("Unkeyed type mismatch error")
    func unkeyedTypeMismatchError() throws {
        let dictionary: [String: Any] = [
            "numbers": ["not", "numbers"]
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(PrimitiveArrayContainer.self, from: dictionary)
        }
    }

    // MARK: - AllKeys Test

    @Test("Keyed container all keys")
    func keyedContainerAllKeys() throws {
        let dictionary: [String: Any] = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3",
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode([String: String].self, from: dictionary)

        #expect(decoded.count == 3)
        #expect(decoded["key1"] == "value1")
        #expect(decoded["key2"] == "value2")
        #expect(decoded["key3"] == "value3")
    }

    // MARK: - SuperDecoder for Key Tests

    @Test("Super decoder for specific key")
    func superDecoderForKey() throws {
        let dictionary: [String: Any] = [
            "bar": 42,
            "super": "Foo",
            "foo": "Foo",
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(ChildKeyedDecodable.self, from: dictionary)

        #expect(decoded.bar == 42)
        #expect(decoded.foo == "Foo")
    }

    // MARK: - Unkeyed SuperDecoder Tests

    @Test("Unkeyed super decoder")
    func unkeyedSuperDecoder() throws {
        let dictionary: [String: Any] = [
            "values": ["Bar", "Foo"]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(UnkeyedWithSuper.self, from: dictionary)

        #expect(decoded.bar == "Bar")
        #expect(decoded.foo == "Foo")
    }

    // MARK: - Container Type Mismatch Tests

    @Test("Expected dictionary but got array")
    func expectedDictionaryGotArray() throws {
        let dictionary: [String: Any] = [
            "value": [1, 2, 3]
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(ExpectsNestedDict.self, from: dictionary)
        }
    }

    @Test("Expected array but got dictionary")
    func expectedArrayGotDictionary() throws {
        let dictionary: [String: Any] = [
            "numbers": ["key": "value"]
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(PrimitiveArrayContainer.self, from: dictionary)
        }
    }

    // MARK: - Unkeyed Container Count Tests

    @Test("Unkeyed container count property")
    func unkeyedContainerCount() throws {
        let dictionary: [String: Any] = [
            "items": [1, 2, 3, 4, 5]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(UnkeyedCountCheck.self, from: dictionary)

        #expect(decoded.count == 5)
    }

    // MARK: - Nested Container Tests for Decoder

    @Test("Unkeyed container nested keyed container")
    func unkeyedNestedKeyedContainer() throws {
        let dictionary: [String: Any] = [
            "items": [
                ["name": "first"],
                ["name": "second"],
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(UnkeyedNestedKeyed.self, from: dictionary)

        #expect(decoded.names == ["first", "second"])
    }

    @Test("Unkeyed container nested unkeyed container")
    func unkeyedNestedUnkeyedContainer() throws {
        let dictionary: [String: Any] = [
            "matrix": [[1, 2], [3, 4]]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(UnkeyedNestedUnkeyed.self, from: dictionary)

        #expect(decoded.values == [1, 2, 3, 4])
    }

    @Test("Keyed container nested keyed container")
    func keyedNestedKeyedContainer() throws {
        let dictionary: [String: Any] = [
            "wrapper": [
                "name": "test"
            ]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(KeyedNestedKeyed.self, from: dictionary)

        #expect(decoded.name == "test")
    }

    @Test("Super decoder for specific key in keyed container")
    func superDecoderForSpecificKey() throws {
        let dictionary: [String: Any] = [
            "childValue": 42,
            "parentKey": "ParentValue",
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(SuperDecoderForKey.self, from: dictionary)

        #expect(decoded.childValue == 42)
        #expect(decoded.parentValue == "ParentValue")
    }

    // MARK: - NSNumber Bridging Tests for Bool

    @Test("Keyed container decode Bool from NSNumber")
    func keyedDecodeBoolFromNSNumber() throws {
        let dictionary: [String: Any] = [
            "boolValue": NSNumber(value: true)
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(BoolContainer.self, from: dictionary)

        #expect(decoded.boolValue == true)
    }

    @Test("Unkeyed container decode Bool from NSNumber")
    func unkeyedDecodeBoolFromNSNumber() throws {
        let dictionary: [String: Any] = [
            "values": [NSNumber(value: true), NSNumber(value: false)]
        ]

        let decoder = DictionaryDecoder()
        let decoded = try decoder.decode(UnkeyedBoolContainer.self, from: dictionary)

        #expect(decoded.values == [true, false])
    }

    // MARK: - Error Description Tests

    @Test("DictionaryDecoderError type mismatch description")
    func decoderErrorTypeMismatchDescription() throws {
        let error = DictionaryDecoderError.typeMismatch(
            expected: "String",
            actual: "Int",
            codingPath: ["testKey"]
        )
        let description = error.errorDescription
        #expect(description != nil)
        #expect(description?.contains("testKey") ?? false)
        #expect(description?.contains("String") ?? false)
    }

    @Test("DictionaryDecoderError key not found description")
    func decoderErrorKeyNotFoundDescription() throws {
        let error = DictionaryDecoderError.keyNotFound(
            "missingKey",
            codingPath: ["parent"]
        )
        let description = error.errorDescription
        #expect(description != nil)
        #expect(description?.contains("missingKey") ?? false)
    }

    @Test("DictionaryDecoderError value not found description")
    func decoderErrorValueNotFoundDescription() throws {
        let error = DictionaryDecoderError.valueNotFound(
            "String",
            codingPath: ["path"]
        )
        let description = error.errorDescription
        #expect(description != nil)
        #expect(description?.contains("String") ?? false)
    }

    // MARK: - Type Mismatch in Unkeyed Container

    @Test("Unkeyed container type mismatch for Bool")
    func unkeyedTypeMismatchForBool() throws {
        let dictionary: [String: Any] = [
            "values": ["not a bool"]
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(UnkeyedBoolContainer.self, from: dictionary)
        }
    }

    @Test("Unkeyed container type mismatch for String")
    func unkeyedTypeMismatchForString() throws {
        let dictionary: [String: Any] = [
            "values": [123]
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(UnkeyedStringContainer.self, from: dictionary)
        }
    }

    @Test("Unkeyed container nested keyed type mismatch")
    func unkeyedNestedKeyedTypeMismatch() throws {
        let dictionary: [String: Any] = [
            "items": ["not a dictionary"]
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(UnkeyedNestedKeyed.self, from: dictionary)
        }
    }

    @Test("Unkeyed container nested unkeyed type mismatch")
    func unkeyedNestedUnkeyedTypeMismatch() throws {
        let dictionary: [String: Any] = [
            "matrix": ["not an array"]
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(UnkeyedNestedUnkeyed.self, from: dictionary)
        }
    }

    // MARK: - Single Value Container Type Mismatch

    @Test("Single value container String type mismatch")
    func singleValueStringTypeMismatch() throws {
        let dictionary: [String: Any] = [
            "wrapper": 123
        ]

        let decoder = DictionaryDecoder()
        #expect(throws: DecodingError.self) {
            try decoder.decode(StringWrapper.self, from: dictionary)
        }
    }
}

// MARK: - Additional Test Types

struct UnkeyedCountCheck: Codable {
    var count: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .items)
        self.count = unkeyedContainer.count ?? 0
        // Consume all elements
        while !unkeyedContainer.isAtEnd {
            _ = try unkeyedContainer.decode(Int.self)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case items
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode([Int](repeating: 0, count: count), forKey: .items)
    }
}

struct UnkeyedNestedKeyed: Codable {
    var names: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .items)
        var names: [String] = []
        while !unkeyedContainer.isAtEnd {
            let nestedContainer = try unkeyedContainer.nestedContainer(keyedBy: ItemCodingKeys.self)
            names.append(try nestedContainer.decode(String.self, forKey: .name))
        }
        self.names = names
    }

    private enum CodingKeys: String, CodingKey {
        case items
    }

    private enum ItemCodingKeys: String, CodingKey {
        case name
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = container.nestedUnkeyedContainer(forKey: .items)
        for name in names {
            var itemContainer = nestedContainer.nestedContainer(keyedBy: ItemCodingKeys.self)
            try itemContainer.encode(name, forKey: .name)
        }
    }
}

struct UnkeyedNestedUnkeyed: Codable {
    var values: [Int]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .matrix)
        var values: [Int] = []
        while !unkeyedContainer.isAtEnd {
            var nestedUnkeyed = try unkeyedContainer.nestedUnkeyedContainer()
            while !nestedUnkeyed.isAtEnd {
                values.append(try nestedUnkeyed.decode(Int.self))
            }
        }
        self.values = values
    }

    private enum CodingKeys: String, CodingKey {
        case matrix
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode([[Int]](), forKey: .matrix)
    }
}

struct KeyedNestedKeyed: Codable {
    var name: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try container.nestedContainer(keyedBy: WrapperCodingKeys.self, forKey: .wrapper)
        self.name = try nestedContainer.decode(String.self, forKey: .name)
    }

    private enum CodingKeys: String, CodingKey {
        case wrapper
    }

    private enum WrapperCodingKeys: String, CodingKey {
        case name
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = container.nestedContainer(keyedBy: WrapperCodingKeys.self, forKey: .wrapper)
        try nestedContainer.encode(name, forKey: .name)
    }
}

struct SuperDecoderForKey: Codable {
    var childValue: Int
    var parentValue: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        childValue = try container.decode(Int.self, forKey: .childValue)
        let superDecoder = try container.superDecoder(forKey: .parentKey)
        let singleValue = try superDecoder.singleValueContainer()
        parentValue = try singleValue.decode(String.self)
    }

    private enum CodingKeys: String, CodingKey {
        case childValue
        case parentKey
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(childValue, forKey: .childValue)
        try container.encode(parentValue, forKey: .parentKey)
    }
}

struct BoolContainer: Codable {
    var boolValue: Bool
}

struct UnkeyedBoolContainer: Codable {
    var values: [Bool]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .values)
        var values: [Bool] = []
        while !unkeyedContainer.isAtEnd {
            values.append(try unkeyedContainer.decode(Bool.self))
        }
        self.values = values
    }

    private enum CodingKeys: String, CodingKey {
        case values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(values, forKey: .values)
    }
}

struct UnkeyedStringContainer: Codable {
    var values: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .values)
        var values: [String] = []
        while !unkeyedContainer.isAtEnd {
            values.append(try unkeyedContainer.decode(String.self))
        }
        self.values = values
    }

    private enum CodingKeys: String, CodingKey {
        case values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(values, forKey: .values)
    }
}

struct StringWrapper: Codable {
    var value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let singleValueDecoder = try container.superDecoder(forKey: .wrapper)
        let singleValue = try singleValueDecoder.singleValueContainer()
        self.value = try singleValue.decode(String.self)
    }

    private enum CodingKeys: String, CodingKey {
        case wrapper
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .wrapper)
    }
}

// MARK: - Test Types

struct TestCodable: Codable, Equatable {
    var stringVar = "string"
    var intVar = 1
    var uintVar: UInt = 2
    var doubleVar: Double = 3
    var floatVar: Float = 4
    var boolVar = true
    var dateVar = Date(timeIntervalSince1970: 1500)
    var urlVar: URL? = URL(string: "https://example.com")

    var arrayVar: [TestNestedCodable] = [TestNestedCodable(), TestNestedCodable()]
    var arrayIntVar: [Int] = [1, 2, 3, 4]
    var dictVar: [String: [String: [Int]]] = ["dictKey0": ["dictKey2": [1, 2, 3, 4]]]
}

struct TestNestedCodable: Codable, Equatable {
    var stringVar = "testNested"
    var nested = DoubleNestedCodable()

    struct DoubleNestedCodable: Codable, Equatable {
        var stringVar = "testDoubleNested"
    }
}

struct TestCodableEnums: Codable, Equatable {
    var stringEnum = StringEnum.testStringEnum
    var intEnum = IntEnum.one

    enum StringEnum: String, Codable {
        case testStringEnum
    }

    enum IntEnum: Int, Codable {
        case one = 1
    }
}

struct AllPrimitives: Codable {
    var stringVar: String
    var intVar: Int
    var uintVar: UInt
    var doubleVar: Double
    var floatVar: Float
    var boolVar: Bool
    var int8Var: Int8
    var int16Var: Int16
    var int32Var: Int32
    var int64Var: Int64
    var uint8Var: UInt8
    var uint16Var: UInt16
    var uint32Var: UInt32
    var uint64Var: UInt64
}

struct OptionalValues: Codable {
    var presentValue: String?
    var nullValue: String?
    var missingValue: String?
}

struct ArrayContainer: Codable {
    var items: [Item]

    struct Item: Codable {
        var name: String
    }
}

struct PrimitiveArrayContainer: Codable {
    var numbers: [Int]
}

struct DictionaryContainer: Codable {
    var metadata: [String: String]
}

struct SimpleStruct: Codable {
    var stringVar: String
}

struct UnkeyedPrimitives: Codable {
    var values: [AnyCodableValue]
}

struct AnyCodableValue: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            return
        }
        if let _ = try? container.decode(Bool.self) { return }
        if let _ = try? container.decode(String.self) { return }
        if let _ = try? container.decode(Double.self) { return }
        if let _ = try? container.decode(Int.self) { return }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

struct UnkeyedMixedNumbers: Codable {
    var values: [Double]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .values)
        var values: [Double] = []
        let boolValue = try unkeyedContainer.decode(Bool.self)
        values.append(boolValue ? 1.0 : 0.0)
        let intValue = try unkeyedContainer.decode(Int.self)
        values.append(Double(intValue))
        let doubleValue = try unkeyedContainer.decode(Double.self)
        values.append(doubleValue)
        self.values = values
    }

    private enum CodingKeys: String, CodingKey {
        case values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(values, forKey: .values)
    }
}

struct UnkeyedOptionals: Codable {
    var values: [String?]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .values)
        var values: [String?] = []
        while !unkeyedContainer.isAtEnd {
            if try unkeyedContainer.decodeNil() {
                values.append(nil)
            } else {
                values.append(try unkeyedContainer.decode(String.self))
            }
        }
        self.values = values
    }

    private enum CodingKeys: String, CodingKey {
        case values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(values, forKey: .values)
    }
}

struct NestedKeyedInUnkeyed: Codable {
    var items: [Item]

    struct Item: Codable {
        var id: Int
        var name: String
    }
}

struct NestedUnkeyedInKeyed: Codable {
    var matrix: [[Int]]
}

struct NestedUnkeyedInUnkeyed: Codable {
    var matrix: [[Int]]
}

struct NestedKeyedInKeyed: Codable {
    var outer: Outer

    struct Outer: Codable {
        var inner: Inner

        struct Inner: Codable {
            var value: String
        }
    }
}

struct KeyedNilValues: Codable {
    var nullValue: String?
    var presentValue: String?
    var missingValue: String?
}

struct SingleValueNilWrapper: Codable {
    var wrapper: String?
}

struct UnkeyedWithSuper: Codable {
    var bar: String
    var foo: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .values)
        bar = try unkeyedContainer.decode(String.self)
        let superDecoder = try unkeyedContainer.superDecoder()
        let singleValue = try superDecoder.singleValueContainer()
        foo = try singleValue.decode(String.self)
    }

    private enum CodingKeys: String, CodingKey {
        case values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .values)
        try unkeyedContainer.encode(bar)
        try unkeyedContainer.encode(foo)
    }
}

struct ExpectsNestedDict: Codable {
    var value: NestedDict

    struct NestedDict: Codable {
        var key: String
    }
}

class ParentSingleValueDecodable: Codable {
    var foo = "Foo"

    required init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        foo = try container.decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(foo)
    }
}

class ChildKeyedDecodable: ParentSingleValueDecodable {
    var bar = 1

    private enum CodingKeys: String, CodingKey {
        case bar
        case foo
    }

    required init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bar = try container.decode(Int.self, forKey: .bar)
        try super.init(from: container.superDecoder())
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bar, forKey: .bar)
        try super.encode(to: container.superEncoder())
        try super.encode(to: container.superEncoder(forKey: CodingKeys.foo))
    }
}

// MARK: - Options for Round Trip Testing

final class KeepFoundationEncoderOptions: DictionaryEncoder.Options {
    override func shouldEncode<T: Encodable>(_ value: T) -> Bool {
        if value is Date { return false }
        if value is URL { return false }
        return true
    }
}

final class KeepFoundationDecoderOptions: DictionaryDecoder.Options {
    override func shouldDecode<T: Decodable>(_ type: T.Type, value: Any) -> T? {
        if let date = value as? T, type == Date.self {
            return date
        }
        if let url = value as? T, type == URL.self {
            return url
        }
        return nil
    }
}
