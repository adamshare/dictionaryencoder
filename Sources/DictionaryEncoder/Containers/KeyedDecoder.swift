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
    /// Decodes values from a `Dictionary`.
    ///
    /// Created when decoding a keyed container (struct, class, Dictionary, enum with associated values).
    struct KeyedDecoder<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var decoder: SingleValueDecoder
        var codingPath: [CodingKey]
        var dictionary: [String: Any]

        var allKeys: [Key] {
            dictionary.keys.compactMap { Key(stringValue: $0) }
        }

        func contains(_ key: Key) -> Bool {
            dictionary[key.stringValue] != nil
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            guard let value = dictionary[key.stringValue] else {
                return true
            }
            return value is NSNull
        }

        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            let value = try getValue(forKey: key)
            if let bool = value as? Bool {
                return bool
            }
            if let number = value as? NSNumber {
                return number.boolValue
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            let value = try getValue(forKey: key)
            guard let string = value as? String else {
                throw typeMismatchError(type, forKey: key, value: value)
            }
            return string
        }

        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            let value = try getValue(forKey: key)
            if let double = value as? Double {
                return double
            }
            if let number = value as? NSNumber {
                return number.doubleValue
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            let value = try getValue(forKey: key)
            if let float = value as? Float {
                return float
            }
            if let number = value as? NSNumber {
                return number.floatValue
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            let value = try getValue(forKey: key)
            if let int = value as? Int {
                return int
            }
            if let number = value as? NSNumber {
                return number.intValue
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            let value = try getValue(forKey: key)
            if let int = value as? Int8 {
                return int
            }
            if let number = value as? NSNumber {
                return number.int8Value
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            let value = try getValue(forKey: key)
            if let int = value as? Int16 {
                return int
            }
            if let number = value as? NSNumber {
                return number.int16Value
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            let value = try getValue(forKey: key)
            if let int = value as? Int32 {
                return int
            }
            if let number = value as? NSNumber {
                return number.int32Value
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            let value = try getValue(forKey: key)
            if let int = value as? Int64 {
                return int
            }
            if let number = value as? NSNumber {
                return number.int64Value
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            let value = try getValue(forKey: key)
            if let uint = value as? UInt {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uintValue
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            let value = try getValue(forKey: key)
            if let uint = value as? UInt8 {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uint8Value
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            let value = try getValue(forKey: key)
            if let uint = value as? UInt16 {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uint16Value
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            let value = try getValue(forKey: key)
            if let uint = value as? UInt32 {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uint32Value
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            let value = try getValue(forKey: key)
            if let uint = value as? UInt64 {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uint64Value
            }
            throw typeMismatchError(type, forKey: key, value: value)
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            let value = try getValue(forKey: key)
            let nestedDecoder = SingleValueDecoder(
                value: value,
                codingPath: codingPath + [key],
                options: decoder.options,
                userInfo: decoder.userInfo
            )
            return try nestedDecoder.decode(type)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            let value = try getValue(forKey: key)
            guard let nestedDictionary = value as? [String: Any] else {
                throw typeMismatchError([String: Any].self, forKey: key, value: value)
            }
            return KeyedDecodingContainer(KeyedDecoder<NestedKey>(
                decoder: decoder,
                codingPath: codingPath + [key],
                dictionary: nestedDictionary
            ))
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            let value = try getValue(forKey: key)
            guard let nestedArray = value as? [Any] else {
                throw typeMismatchError([Any].self, forKey: key, value: value)
            }
            return UnkeyedDecoder(
                decoder: decoder,
                codingPath: codingPath + [key],
                array: nestedArray
            )
        }

        func superDecoder() throws -> Decoder {
            let key = AnyCodingKey("super")
            let value = dictionary[key.stringValue] ?? [String: Any]()
            return SingleValueDecoder(
                value: value,
                codingPath: codingPath + [key],
                options: decoder.options,
                userInfo: decoder.userInfo
            )
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            let value = dictionary[key.stringValue] ?? [String: Any]()
            return SingleValueDecoder(
                value: value,
                codingPath: codingPath + [key],
                options: decoder.options,
                userInfo: decoder.userInfo
            )
        }

        private func getValue(forKey key: Key) throws -> Any {
            guard let value = dictionary[key.stringValue] else {
                throw DecodingError.keyNotFound(
                    key,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Key '\(key.stringValue)' not found"
                    )
                )
            }
            return value
        }

        private func typeMismatchError(_ type: Any.Type, forKey key: Key, value: Any) -> DecodingError {
            DecodingError.typeMismatch(
                type,
                DecodingError.Context(
                    codingPath: codingPath + [key],
                    debugDescription: "Expected \(type) but found \(Swift.type(of: value))"
                )
            )
        }
    }
}
