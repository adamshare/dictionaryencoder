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

import Foundation

extension DictionaryDecoder {
    /// Decodes values from an `Array`.
    ///
    /// An `UnkeyedDecoder` is created when decoding an unkeyed container (Array).
    /// Each decode call advances through the array.
    struct UnkeyedDecoder: UnkeyedDecodingContainer {
        var decoder: SingleValueDecoder
        var codingPath: [CodingKey]
        var array: [Any]

        var count: Int? { array.count }
        var isAtEnd: Bool { currentIndex >= array.count }
        private(set) var currentIndex: Int = 0

        mutating func decodeNil() throws -> Bool {
            guard !isAtEnd else {
                throw outOfBoundsError()
            }
            if array[currentIndex] is NSNull {
                currentIndex += 1
                return true
            }
            return false
        }

        mutating func decode(_ type: Bool.Type) throws -> Bool {
            let value = try getCurrentValue()
            if let bool = value as? Bool {
                currentIndex += 1
                return bool
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.boolValue
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: String.Type) throws -> String {
            let value = try getCurrentValue()
            guard let string = value as? String else {
                throw typeMismatchError(type, value: value)
            }
            currentIndex += 1
            return string
        }

        mutating func decode(_ type: Double.Type) throws -> Double {
            let value = try getCurrentValue()
            if let double = value as? Double {
                currentIndex += 1
                return double
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.doubleValue
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: Float.Type) throws -> Float {
            let value = try getCurrentValue()
            if let float = value as? Float {
                currentIndex += 1
                return float
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.floatValue
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: Int.Type) throws -> Int {
            let value = try getCurrentValue()
            if let int = value as? Int {
                currentIndex += 1
                return int
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.intValue
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            let value = try getCurrentValue()
            if let int = value as? Int8 {
                currentIndex += 1
                return int
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.int8Value
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            let value = try getCurrentValue()
            if let int = value as? Int16 {
                currentIndex += 1
                return int
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.int16Value
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            let value = try getCurrentValue()
            if let int = value as? Int32 {
                currentIndex += 1
                return int
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.int32Value
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            let value = try getCurrentValue()
            if let int = value as? Int64 {
                currentIndex += 1
                return int
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.int64Value
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: UInt.Type) throws -> UInt {
            let value = try getCurrentValue()
            if let uint = value as? UInt {
                currentIndex += 1
                return uint
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.uintValue
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            let value = try getCurrentValue()
            if let uint = value as? UInt8 {
                currentIndex += 1
                return uint
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.uint8Value
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            let value = try getCurrentValue()
            if let uint = value as? UInt16 {
                currentIndex += 1
                return uint
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.uint16Value
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            let value = try getCurrentValue()
            if let uint = value as? UInt32 {
                currentIndex += 1
                return uint
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.uint32Value
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            let value = try getCurrentValue()
            if let uint = value as? UInt64 {
                currentIndex += 1
                return uint
            }
            if let number = value as? NSNumber {
                currentIndex += 1
                return number.uint64Value
            }
            throw typeMismatchError(type, value: value)
        }

        mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            let value = try getCurrentValue()
            let nestedDecoder = SingleValueDecoder(
                value: value,
                codingPath: codingPath + [AnyCodingKey(currentIndex)],
                options: decoder.options,
                userInfo: decoder.userInfo
            )
            let result = try nestedDecoder.decode(type)
            currentIndex += 1
            return result
        }

        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            let value = try getCurrentValue()
            guard let nestedDictionary = value as? [String: Any] else {
                throw typeMismatchError([String: Any].self, value: value)
            }
            currentIndex += 1
            return KeyedDecodingContainer(KeyedDecoder<NestedKey>(
                decoder: decoder,
                codingPath: codingPath + [AnyCodingKey(currentIndex - 1)],
                dictionary: nestedDictionary
            ))
        }

        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let value = try getCurrentValue()
            guard let nestedArray = value as? [Any] else {
                throw typeMismatchError([Any].self, value: value)
            }
            currentIndex += 1
            return UnkeyedDecoder(
                decoder: decoder,
                codingPath: codingPath + [AnyCodingKey(currentIndex - 1)],
                array: nestedArray
            )
        }

        mutating func superDecoder() throws -> Decoder {
            let value = try getCurrentValue()
            currentIndex += 1
            return SingleValueDecoder(
                value: value,
                codingPath: codingPath + [AnyCodingKey(currentIndex - 1)],
                options: decoder.options,
                userInfo: decoder.userInfo
            )
        }

        private func getCurrentValue() throws -> Any {
            guard !isAtEnd else {
                throw outOfBoundsError()
            }
            return array[currentIndex]
        }

        private func outOfBoundsError() -> DecodingError {
            DecodingError.valueNotFound(
                Any.self,
                DecodingError.Context(
                    codingPath: codingPath + [AnyCodingKey(currentIndex)],
                    debugDescription: "Unkeyed container is at end (index \(currentIndex), count \(array.count))"
                )
            )
        }

        private func typeMismatchError(_ type: Any.Type, value: Any) -> DecodingError {
            DecodingError.typeMismatch(
                type,
                DecodingError.Context(
                    codingPath: codingPath + [AnyCodingKey(currentIndex)],
                    debugDescription: "Expected \(type) but found \(Swift.type(of: value))"
                )
            )
        }
    }
}
