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
    /// Acts as both the `Decoder` and the `SingleValueDecodingContainer`.
    ///
    /// The decoder contains the current value being decoded.
    /// As nested values are decoded, new decoders are created with the nested value.
    class SingleValueDecoder: Decoder, SingleValueDecodingContainer {
        var options: Options
        var value: Any
        public var codingPath: [CodingKey]
        public var userInfo: [CodingUserInfoKey: Any]

        init(value: Any, codingPath: [CodingKey], options: Options, userInfo: [CodingUserInfoKey: Any]) {
            self.value = value
            self.codingPath = codingPath
            self.options = options
            self.userInfo = userInfo
        }

        public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
            guard let dictionary = value as? [String: Any] else {
                throw DecodingError.typeMismatch(
                    [String: Any].self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Expected dictionary but found \(Swift.type(of: value))"
                    )
                )
            }
            return KeyedDecodingContainer(KeyedDecoder<Key>(decoder: self, codingPath: codingPath, dictionary: dictionary))
        }

        public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            guard let array = value as? [Any] else {
                throw DecodingError.typeMismatch(
                    [Any].self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "Expected array but found \(Swift.type(of: value))"
                    )
                )
            }
            return UnkeyedDecoder(decoder: self, codingPath: codingPath, array: array)
        }

        public func singleValueContainer() throws -> SingleValueDecodingContainer {
            self
        }

        public func decodeNil() -> Bool {
            value is NSNull
        }

        public func decode(_ type: Bool.Type) throws -> Bool {
            if let bool = value as? Bool {
                return bool
            }
            // Handle NSNumber bridging
            if let number = value as? NSNumber {
                return number.boolValue
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: String.Type) throws -> String {
            guard let string = value as? String else {
                throw typeMismatchError(type)
            }
            return string
        }

        public func decode(_ type: Double.Type) throws -> Double {
            if let double = value as? Double {
                return double
            }
            if let number = value as? NSNumber {
                return number.doubleValue
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: Float.Type) throws -> Float {
            if let float = value as? Float {
                return float
            }
            if let number = value as? NSNumber {
                return number.floatValue
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: Int.Type) throws -> Int {
            if let int = value as? Int {
                return int
            }
            if let number = value as? NSNumber {
                return number.intValue
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: Int8.Type) throws -> Int8 {
            if let int = value as? Int8 {
                return int
            }
            if let number = value as? NSNumber {
                return number.int8Value
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: Int16.Type) throws -> Int16 {
            if let int = value as? Int16 {
                return int
            }
            if let number = value as? NSNumber {
                return number.int16Value
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: Int32.Type) throws -> Int32 {
            if let int = value as? Int32 {
                return int
            }
            if let number = value as? NSNumber {
                return number.int32Value
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: Int64.Type) throws -> Int64 {
            if let int = value as? Int64 {
                return int
            }
            if let number = value as? NSNumber {
                return number.int64Value
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: UInt.Type) throws -> UInt {
            if let uint = value as? UInt {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uintValue
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: UInt8.Type) throws -> UInt8 {
            if let uint = value as? UInt8 {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uint8Value
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: UInt16.Type) throws -> UInt16 {
            if let uint = value as? UInt16 {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uint16Value
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: UInt32.Type) throws -> UInt32 {
            if let uint = value as? UInt32 {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uint32Value
            }
            throw typeMismatchError(type)
        }

        public func decode(_ type: UInt64.Type) throws -> UInt64 {
            if let uint = value as? UInt64 {
                return uint
            }
            if let number = value as? NSNumber {
                return number.uint64Value
            }
            throw typeMismatchError(type)
        }

        public func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            // Check if options provide a direct value
            if let directValue = options.shouldDecode(type, value: value) {
                return directValue
            }
            // Check if value is already the expected type
            if let typedValue = value as? T {
                return typedValue
            }
            return try T(from: self)
        }

        private func typeMismatchError(_ type: Any.Type) -> DecodingError {
            DecodingError.typeMismatch(
                type,
                DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(type) but found \(Swift.type(of: value))"
                )
            )
        }
    }
}
