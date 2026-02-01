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

import Combine
import Foundation

/// Errors from `DictionaryDecoder`
public enum DictionaryDecoderError: LocalizedError {
    /// The dictionary value could not be decoded to the expected type.
    case typeMismatch(expected: Any.Type, actual: Any, codingPath: [CodingKey])
    /// A required key was not found in the dictionary.
    case keyNotFound(CodingKey, codingPath: [CodingKey])
    /// The value was null or missing when a non-optional was expected.
    case valueNotFound(Any.Type, codingPath: [CodingKey])

    public var errorDescription: String? {
        switch self {
        case let .typeMismatch(expected, actual, codingPath):
            let path = codingPath.map(\.stringValue).joined(separator: ".")
            return "Type mismatch at '\(path)': expected \(expected) but found \(type(of: actual))."
        case let .keyNotFound(key, codingPath):
            let path = codingPath.map(\.stringValue).joined(separator: ".")
            return "Key '\(key.stringValue)' not found at '\(path)'."
        case let .valueNotFound(type, codingPath):
            let path = codingPath.map(\.stringValue).joined(separator: ".")
            return "Value of type \(type) not found at '\(path)'."
        }
    }
}

/// Top level decoder that enables decoding `Dictionary` representations into instances.
///
/// Decoder has been modeled to match `DictionaryEncoder`.
///
/// This custom decoder enables converting a `Dictionary` representation back into custom types.
/// All types will be decoded from a `Dictionary`, `Array` or primitive representation unless specified using the `Options` handler.
///
public final class DictionaryDecoder: TopLevelDecoder {
    public typealias Input = [String: Any]

    public var options: Options
    public var userInfo: [CodingUserInfoKey: Any]

    public init(options: Options = Options(),
                userInfo: [CodingUserInfoKey: Any] = [:])
    {
        self.options = options
        self.userInfo = userInfo
    }

    public func decode<T>(_ type: T.Type, from dictionary: [String: Any]) throws -> T where T: Decodable {
        let decoder = SingleValueDecoder(value: dictionary, codingPath: [], options: options, userInfo: userInfo)
        return try T(from: decoder)
    }

    /// Options to configure `DictionaryDecoder`.
    open class Options {
        public init() {}

        /// If false the value will be returned as-is without decoding.
        /// This allows types like Date or URL to be extracted directly from the dictionary.
        open func shouldDecode<T: Decodable>(_: T.Type, value: Any) -> T? {
            nil
        }
    }
}
