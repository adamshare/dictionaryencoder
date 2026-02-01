# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

```bash
# Build the package
swift build

# Run all tests
swift test

# Run a specific test
swift test --filter DictionaryEncoderTests/testDictEncoder

# Format code (requires SwiftFormat)
./swiftformat.sh
```

## Architecture Overview

DictionaryEncoder is a Swift package that encodes `Encodable` types directly into `[String: Any]` dictionaries, avoiding the overhead of JSON serialization. It conforms to Combine's `TopLevelEncoder` protocol.

### Container Hierarchy

The encoder implements Swift's `Encoder` protocol through a container-based architecture:

- **`SingleValueContainer`** (`Containers/SingleValueContainer.swift`): The core encoder that manages a stack of `Container` structs. Acts as both the `Encoder` and `SingleValueEncodingContainer`. As nested values encode, they push to the stack and pop when complete.

- **`KeyedContainer`** (`Containers/KeyedContainer.swift`): Handles struct/class/dictionary encoding. Stores values in a `Dictionary.Ref` wrapper that provides mutable access to the underlying storage.

- **`UnkeyedContainer`** (`Containers/UnkeyedContainer.swift`): Handles array encoding. Uses `Array.Ref` for mutable storage access.

- **`ReferencingEncoder`** (`Containers/ReferencingEncoder.swift`): Handles `superEncoder()` calls for class inheritance. Writes back to the parent container on deinit.

### Reference Wrappers

To handle Swift's copy-on-write semantics for value types, the encoder uses reference wrappers:

- **`Dictionary.Ref`** (`Dictionary+Ref.swift`): Captures a closure that mutates the underlying dictionary storage.
- **`Array.Ref`** (`Array+Ref.swift`): Same pattern for arrays.

### Customization

`DictionaryEncoder.Options` allows skipping encoding for specific types via `shouldEncode<T>(_:)`. This is useful when you want types like `Date` or `URL` to remain as-is rather than being encoded into their Codable representation.
