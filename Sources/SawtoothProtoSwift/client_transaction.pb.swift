// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: client_transaction.proto
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

/// A request to return a list of txns from the validator. May include the id
/// of a particular block to be the `head` of the chain being requested. In that
/// case the list will include the txns from that block, and all txns
/// previous to that block on the chain. Filter with specific `transaction_ids`.
public struct ClientTransactionListRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var headID: String {
    get {return _storage._headID}
    set {_uniqueStorage()._headID = newValue}
  }

  public var transactionIds: [String] {
    get {return _storage._transactionIds}
    set {_uniqueStorage()._transactionIds = newValue}
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

/// A response that lists transactions from newest to oldest.
///
/// Statuses:
///   * OK - everything worked as expected
///   * INTERNAL_ERROR - general error, such as protobuf failing to deserialize
///   * NOT_READY - the validator does not yet have a genesis block
///   * NO_ROOT - the head block specified was not found
///   * NO_RESOURCE - no txns were found with the parameters specified
///   * INVALID_PAGING - the paging controls were malformed or out of range
///   * INVALID_SORT - the sorting controls were malformed or invalid
public struct ClientTransactionListResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var status: ClientTransactionListResponse.Status {
    get {return _storage._status}
    set {_uniqueStorage()._status = newValue}
  }

  public var transactions: [Transaction] {
    get {return _storage._transactions}
    set {_uniqueStorage()._transactions = newValue}
  }

  public var headID: String {
    get {return _storage._headID}
    set {_uniqueStorage()._headID = newValue}
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
    case invalidID // = 8
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
      case 8: self = .invalidID
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
      case .invalidID: return 8
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

#if swift(>=4.2)

extension ClientTransactionListResponse.Status: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ClientTransactionListResponse.Status] = [
    .unset,
    .ok,
    .internalError,
    .notReady,
    .noRoot,
    .noResource,
    .invalidPaging,
    .invalidSort,
    .invalidID,
  ]
}

#endif  // swift(>=4.2)

/// Fetches a specific txn by its id (header_signature) from the blockchain.
public struct ClientTransactionGetRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var transactionID: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// A response that returns the txn specified by a ClientTransactionGetRequest.
///
/// Statuses:
///   * OK - everything worked as expected, txn has been fetched
///   * INTERNAL_ERROR - general error, such as protobuf failing to deserialize
///   * NO_RESOURCE - no txn with the specified id exists
public struct ClientTransactionGetResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var status: ClientTransactionGetResponse.Status {
    get {return _storage._status}
    set {_uniqueStorage()._status = newValue}
  }

  public var transaction: Transaction {
    get {return _storage._transaction ?? Transaction()}
    set {_uniqueStorage()._transaction = newValue}
  }
  /// Returns true if `transaction` has been explicitly set.
  public var hasTransaction: Bool {return _storage._transaction != nil}
  /// Clears the value of `transaction`. Subsequent reads from it will return its default value.
  public mutating func clearTransaction() {_uniqueStorage()._transaction = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum Status: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case unset // = 0
    case ok // = 1
    case internalError // = 2
    case noResource // = 5
    case invalidID // = 8
    case UNRECOGNIZED(Int)

    public init() {
      self = .unset
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unset
      case 1: self = .ok
      case 2: self = .internalError
      case 5: self = .noResource
      case 8: self = .invalidID
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public var rawValue: Int {
      switch self {
      case .unset: return 0
      case .ok: return 1
      case .internalError: return 2
      case .noResource: return 5
      case .invalidID: return 8
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

#if swift(>=4.2)

extension ClientTransactionGetResponse.Status: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ClientTransactionGetResponse.Status] = [
    .unset,
    .ok,
    .internalError,
    .noResource,
    .invalidID,
  ]
}

#endif  // swift(>=4.2)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension ClientTransactionListRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "ClientTransactionListRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "head_id"),
    2: .standard(proto: "transaction_ids"),
    3: .same(proto: "paging"),
    4: .same(proto: "sorting"),
  ]

  fileprivate class _StorageClass {
    var _headID: String = String()
    var _transactionIds: [String] = []
    var _paging: ClientPagingControls? = nil
    var _sorting: [ClientSortControls] = []

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _headID = source._headID
      _transactionIds = source._transactionIds
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
        case 1: try decoder.decodeSingularStringField(value: &_storage._headID)
        case 2: try decoder.decodeRepeatedStringField(value: &_storage._transactionIds)
        case 3: try decoder.decodeSingularMessageField(value: &_storage._paging)
        case 4: try decoder.decodeRepeatedMessageField(value: &_storage._sorting)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._headID.isEmpty {
        try visitor.visitSingularStringField(value: _storage._headID, fieldNumber: 1)
      }
      if !_storage._transactionIds.isEmpty {
        try visitor.visitRepeatedStringField(value: _storage._transactionIds, fieldNumber: 2)
      }
      if let v = _storage._paging {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
      if !_storage._sorting.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._sorting, fieldNumber: 4)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientTransactionListRequest, rhs: ClientTransactionListRequest) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._headID != rhs_storage._headID {return false}
        if _storage._transactionIds != rhs_storage._transactionIds {return false}
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

extension ClientTransactionListResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "ClientTransactionListResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "status"),
    2: .same(proto: "transactions"),
    3: .standard(proto: "head_id"),
    4: .same(proto: "paging"),
  ]

  fileprivate class _StorageClass {
    var _status: ClientTransactionListResponse.Status = .unset
    var _transactions: [Transaction] = []
    var _headID: String = String()
    var _paging: ClientPagingResponse? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _status = source._status
      _transactions = source._transactions
      _headID = source._headID
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
        case 2: try decoder.decodeRepeatedMessageField(value: &_storage._transactions)
        case 3: try decoder.decodeSingularStringField(value: &_storage._headID)
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
      if !_storage._transactions.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._transactions, fieldNumber: 2)
      }
      if !_storage._headID.isEmpty {
        try visitor.visitSingularStringField(value: _storage._headID, fieldNumber: 3)
      }
      if let v = _storage._paging {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientTransactionListResponse, rhs: ClientTransactionListResponse) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._status != rhs_storage._status {return false}
        if _storage._transactions != rhs_storage._transactions {return false}
        if _storage._headID != rhs_storage._headID {return false}
        if _storage._paging != rhs_storage._paging {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ClientTransactionListResponse.Status: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "STATUS_UNSET"),
    1: .same(proto: "OK"),
    2: .same(proto: "INTERNAL_ERROR"),
    3: .same(proto: "NOT_READY"),
    4: .same(proto: "NO_ROOT"),
    5: .same(proto: "NO_RESOURCE"),
    6: .same(proto: "INVALID_PAGING"),
    7: .same(proto: "INVALID_SORT"),
    8: .same(proto: "INVALID_ID"),
  ]
}

extension ClientTransactionGetRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "ClientTransactionGetRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "transaction_id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.transactionID)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.transactionID.isEmpty {
      try visitor.visitSingularStringField(value: self.transactionID, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientTransactionGetRequest, rhs: ClientTransactionGetRequest) -> Bool {
    if lhs.transactionID != rhs.transactionID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ClientTransactionGetResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "ClientTransactionGetResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "status"),
    2: .same(proto: "transaction"),
  ]

  fileprivate class _StorageClass {
    var _status: ClientTransactionGetResponse.Status = .unset
    var _transaction: Transaction? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _status = source._status
      _transaction = source._transaction
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
        case 2: try decoder.decodeSingularMessageField(value: &_storage._transaction)
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
      if let v = _storage._transaction {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ClientTransactionGetResponse, rhs: ClientTransactionGetResponse) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._status != rhs_storage._status {return false}
        if _storage._transaction != rhs_storage._transaction {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ClientTransactionGetResponse.Status: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "STATUS_UNSET"),
    1: .same(proto: "OK"),
    2: .same(proto: "INTERNAL_ERROR"),
    5: .same(proto: "NO_RESOURCE"),
    8: .same(proto: "INVALID_ID"),
  ]
}
