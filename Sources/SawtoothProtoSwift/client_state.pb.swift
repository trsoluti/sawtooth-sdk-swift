// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: client_state.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

// Copyright 2017 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// A request to list every entry in global state. Defaults to the most current
/// tree, but can fetch older state by specifying a state root. Results can be
/// further filtered by specifying a subtree with a partial address.
public struct ClientStateListRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var stateRoot: String {
    get {return _storage._stateRoot}
    set {_uniqueStorage()._stateRoot = newValue}
  }

  public var address: String {
    get {return _storage._address}
    set {_uniqueStorage()._address = newValue}
  }

  public var paging: ClientPagingControls {
    get {return _storage._paging ?? ClientPagingControls()}
    set {_uniqueStorage()._paging = newValue}
  }
  /// Returns true if `paging` has been explicitly set.
  public var hasPaging: Bool {return _storage._paging != nil}
  /// Clears the value of `paging`. Subsequent reads from it will return its default value.
  public mutating func clearPaging() {_uniqueStorage()._paging = nil}

  public var sorting: [ClientSortControls] {
    get {return _storage._sorting}
    set {_uniqueStorage()._sorting = newValue}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

public struct ClientStateListResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var status: ClientStateListResponse.Status {
    get {return _storage._status}
    set {_uniqueStorage()._status = newValue}
  }

  public var entries: [ClientStateListResponse.Entry] {
    get {return _storage._entries}
    set {_uniqueStorage()._entries = newValue}
  }

  public var stateRoot: String {
    get {return _storage._stateRoot}
    set {_uniqueStorage()._stateRoot = newValue}
  }

  public var paging: ClientPagingResponse {
    get {return _storage._paging ?? ClientPagingResponse()}
    set {_uniqueStorage()._paging = newValue}
  }
  /// Returns true if `paging` has been explicitly set.
  public var hasPaging: Bool {return _storage._paging != nil}
  /// Clears the value of `paging`. Subsequent reads from it will return its default value.
  public mutating func clearPaging() {_uniqueStorage()._paging = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum Status: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case unset // = 0
    case ok // = 1
    case internalError // = 2
    case notReady // = 3
    case noRoot // = 4
    case noResource // = 5
    case invalidPaging // = 6
    case invalidSort // = 7
    case invalidAddress // = 8
    case invalidRoot // = 9
    case UNRECOGNIZED(Int)

    public init() {
      self = .unset
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unset
      case 1: self = .ok
      case 2: self = .internalError
      case 3: self = .notReady
      case 4: self = .noRoot
      case 5: self = .noResource
      case 6: self = .invalidPaging
      case 7: self = .invalidSort
      case 8: self = .invalidAddress
      case 9: self = .invalidRoot
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public var rawValue: Int {
      switch self {
      case .unset: return 0
      case .ok: return 1
      case .internalError: return 2
      case .notReady: return 3
      case .noRoot: return 4
      case .noResource: return 5
      case .invalidPaging: return 6
      case .invalidSort: return 7
      case .invalidAddress: return 8
      case .invalidRoot: return 9
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  /// An entry in the State
  public struct Entry {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    public var address: String = String()

    public var data: Data = SwiftProtobuf.Internal.emptyData

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}
  }

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

#if swift(>=4.2)

extension ClientStateListResponse.Status: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ClientStateListResponse.Status] = [
    .unset,
    .ok,
    .internalError,
    .notReady,
    .noRoot,
    .noResource,
    .invalidPaging,
    .invalidSort,
    .invalidAddress,
    .invalidRoot,
  ]
}

#endif  // swift(>=4.2)

/// A request from a client for a particular entry in global state.
/// Like State List, it defaults to the newest state, but a state root
/// can be used to specify older data. Unlike State List the request must be
/// provided with a full address that corresponds to a single entry.
public struct ClientStateGetRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var stateRoot: String = String()

  public var address: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// The response to a State Get Request from the client. Sends back just
/// the data stored at the entry, not the address. Also sends back the
/// head block id used to facilitate further requests.
///
/// Statuses:
///   * OK - everything worked as expected
///   * INTERNAL_ERROR - general error, such as protobuf failing to deserialize
///   * NOT_READY - the validator does not yet have a genesis block
///   * NO_ROOT - the state_root specified was not found
///   * NO_RESOURCE - the address specified doesn't exist
///   * INVALID_ADDRESS - address isn't a valid, i.e. it's a subtree (truncated)
public struct ClientStateGetResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var status: ClientStateGetResponse.Status = .unset

  public var value: Data = SwiftProtobuf.Internal.emptyData

  public var stateRoot: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum Status: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case unset // = 0
    case ok // = 1
    case internalError // = 2
    case notReady // = 3
    case noRoot // = 4
    case noResource // = 5
    case invalidAddress // = 6
    case invalidRoot // = 7
    case UNRECOGNIZED(Int)

    public init() {
      self = .unset
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unset
      case 1: self = .ok
      case 2: self = .internalError
      case 3: self = .notReady
      case 4: self = .noRoot
      case 5: self = .noResource
      case 6: self = .invalidAddress
      case 7: self = .invalidRoot
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public var rawValue: Int {
      switch self {
      case .unset: return 0
      case .ok: return 1
      case .internalError: return 2
      case .notReady: return 3
      case .noRoot: return 4
      case .noResource: return 5
      case .invalidAddress: return 6
      case .invalidRoot: return 7
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  public init() {}
}

#if swift(>=4.2)

extension ClientStateGetResponse.Status: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ClientStateGetResponse.Status] = [
    .unset,
    .ok,
    .internalError,
    .notReady,
    .noRoot,
    .noResource,
    .invalidAddress,
    .invalidRoot,
  ]
}

#endif  // swift(>=4.2)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension ClientStateListRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "ClientStateListRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "state_root"),
    3: .same(proto: "address"),
    4: .same(proto: "paging"),
    5: .same(proto: "sorting"),
  ]

  fileprivate class _StorageClass {
    var _stateRoot: String = String()
    var _address: String = String()
    var _paging: ClientPagingControls? = nil
    var _sorting: [ClientSortControls] = []

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _stateRoot = source._stateRoot
      _address = source._address
      _paging = source._paging
      _sorting = source._sorting
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularStringField(value: &_storage._stateRoot)
        case 3: try decoder.decodeSingularStringField(value: &_storage._address)
        case 4: try decoder.decodeSingularMessageField(value: &_storage._paging)
        case 5: try decoder.decodeRepeatedMessageField(value: &_storage._sorting)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._stateRoot.isEmpty {
        try visitor.visitSingularStringField(value: _storage._stateRoot, fieldNumber: 1)
      }
      if !_storage._address.isEmpty {
        try visitor.visitSingularStringField(value: _storage._address, fieldNumber: 3)
      }
      if let v = _storage._paging {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      }
      if !_storage._sorting.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._sorting, fieldNumber: 5)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientStateListRequest, rhs: ClientStateListRequest) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._stateRoot != rhs_storage._stateRoot {return false}
        if _storage._address != rhs_storage._address {return false}
        if _storage._paging != rhs_storage._paging {return false}
        if _storage._sorting != rhs_storage._sorting {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ClientStateListResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "ClientStateListResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "status"),
    2: .same(proto: "entries"),
    3: .standard(proto: "state_root"),
    4: .same(proto: "paging"),
  ]

  fileprivate class _StorageClass {
    var _status: ClientStateListResponse.Status = .unset
    var _entries: [ClientStateListResponse.Entry] = []
    var _stateRoot: String = String()
    var _paging: ClientPagingResponse? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _status = source._status
      _entries = source._entries
      _stateRoot = source._stateRoot
      _paging = source._paging
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularEnumField(value: &_storage._status)
        case 2: try decoder.decodeRepeatedMessageField(value: &_storage._entries)
        case 3: try decoder.decodeSingularStringField(value: &_storage._stateRoot)
        case 4: try decoder.decodeSingularMessageField(value: &_storage._paging)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if _storage._status != .unset {
        try visitor.visitSingularEnumField(value: _storage._status, fieldNumber: 1)
      }
      if !_storage._entries.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._entries, fieldNumber: 2)
      }
      if !_storage._stateRoot.isEmpty {
        try visitor.visitSingularStringField(value: _storage._stateRoot, fieldNumber: 3)
      }
      if let v = _storage._paging {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientStateListResponse, rhs: ClientStateListResponse) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._status != rhs_storage._status {return false}
        if _storage._entries != rhs_storage._entries {return false}
        if _storage._stateRoot != rhs_storage._stateRoot {return false}
        if _storage._paging != rhs_storage._paging {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ClientStateListResponse.Status: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "STATUS_UNSET"),
    1: .same(proto: "OK"),
    2: .same(proto: "INTERNAL_ERROR"),
    3: .same(proto: "NOT_READY"),
    4: .same(proto: "NO_ROOT"),
    5: .same(proto: "NO_RESOURCE"),
    6: .same(proto: "INVALID_PAGING"),
    7: .same(proto: "INVALID_SORT"),
    8: .same(proto: "INVALID_ADDRESS"),
    9: .same(proto: "INVALID_ROOT"),
  ]
}

extension ClientStateListResponse.Entry: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = ClientStateListResponse.protoMessageName + ".Entry"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "address"),
    2: .same(proto: "data"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.address)
      case 2: try decoder.decodeSingularBytesField(value: &self.data)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.address.isEmpty {
      try visitor.visitSingularStringField(value: self.address, fieldNumber: 1)
    }
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientStateListResponse.Entry, rhs: ClientStateListResponse.Entry) -> Bool {
    if lhs.address != rhs.address {return false}
    if lhs.data != rhs.data {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ClientStateGetRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "ClientStateGetRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "state_root"),
    3: .same(proto: "address"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.stateRoot)
      case 3: try decoder.decodeSingularStringField(value: &self.address)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stateRoot.isEmpty {
      try visitor.visitSingularStringField(value: self.stateRoot, fieldNumber: 1)
    }
    if !self.address.isEmpty {
      try visitor.visitSingularStringField(value: self.address, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientStateGetRequest, rhs: ClientStateGetRequest) -> Bool {
    if lhs.stateRoot != rhs.stateRoot {return false}
    if lhs.address != rhs.address {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ClientStateGetResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "ClientStateGetResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "status"),
    2: .same(proto: "value"),
    3: .standard(proto: "state_root"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularEnumField(value: &self.status)
      case 2: try decoder.decodeSingularBytesField(value: &self.value)
      case 3: try decoder.decodeSingularStringField(value: &self.stateRoot)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.status != .unset {
      try visitor.visitSingularEnumField(value: self.status, fieldNumber: 1)
    }
    if !self.value.isEmpty {
      try visitor.visitSingularBytesField(value: self.value, fieldNumber: 2)
    }
    if !self.stateRoot.isEmpty {
      try visitor.visitSingularStringField(value: self.stateRoot, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientStateGetResponse, rhs: ClientStateGetResponse) -> Bool {
    if lhs.status != rhs.status {return false}
    if lhs.value != rhs.value {return false}
    if lhs.stateRoot != rhs.stateRoot {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ClientStateGetResponse.Status: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "STATUS_UNSET"),
    1: .same(proto: "OK"),
    2: .same(proto: "INTERNAL_ERROR"),
    3: .same(proto: "NOT_READY"),
    4: .same(proto: "NO_ROOT"),
    5: .same(proto: "NO_RESOURCE"),
    6: .same(proto: "INVALID_ADDRESS"),
    7: .same(proto: "INVALID_ROOT"),
  ]
}
