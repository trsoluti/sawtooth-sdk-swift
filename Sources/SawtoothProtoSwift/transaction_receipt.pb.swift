// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: transaction_receipt.proto
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

public struct TransactionReceipt {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// State changes made by this transaction
  /// StateChange is defined in protos/transaction_receipt.proto
  public var stateChanges: [StateChange] = []

  /// Events fired by this transaction
  public var events: [Event] = []

  /// Transaction family defined data
  public var data: [Data] = []

  public var transactionID: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

///  StateChange objects have the type of SET, which is either an insert or
///  update, or DELETE. Items marked as a DELETE will have no byte value.
public struct StateChange {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var address: String = String()

  public var value: Data = SwiftProtobuf.Internal.emptyData

  public var type: StateChange.TypeEnum = .unset

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum TypeEnum: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case unset // = 0
    case set // = 1
    case delete // = 2
    case UNRECOGNIZED(Int)

    public init() {
      self = .unset
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unset
      case 1: self = .set
      case 2: self = .delete
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public var rawValue: Int {
      switch self {
      case .unset: return 0
      case .set: return 1
      case .delete: return 2
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  public init() {}
}

#if swift(>=4.2)

extension StateChange.TypeEnum: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [StateChange.TypeEnum] = [
    .unset,
    .set,
    .delete,
  ]
}

#endif  // swift(>=4.2)

/// A collection of state changes.
public struct StateChangeList {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var stateChanges: [StateChange] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension TransactionReceipt: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "TransactionReceipt"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "state_changes"),
    2: .same(proto: "events"),
    3: .same(proto: "data"),
    4: .standard(proto: "transaction_id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.stateChanges)
      case 2: try decoder.decodeRepeatedMessageField(value: &self.events)
      case 3: try decoder.decodeRepeatedBytesField(value: &self.data)
      case 4: try decoder.decodeSingularStringField(value: &self.transactionID)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stateChanges.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.stateChanges, fieldNumber: 1)
    }
    if !self.events.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.events, fieldNumber: 2)
    }
    if !self.data.isEmpty {
      try visitor.visitRepeatedBytesField(value: self.data, fieldNumber: 3)
    }
    if !self.transactionID.isEmpty {
      try visitor.visitSingularStringField(value: self.transactionID, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: TransactionReceipt, rhs: TransactionReceipt) -> Bool {
    if lhs.stateChanges != rhs.stateChanges {return false}
    if lhs.events != rhs.events {return false}
    if lhs.data != rhs.data {return false}
    if lhs.transactionID != rhs.transactionID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension StateChange: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "StateChange"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "address"),
    2: .same(proto: "value"),
    3: .same(proto: "type"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.address)
      case 2: try decoder.decodeSingularBytesField(value: &self.value)
      case 3: try decoder.decodeSingularEnumField(value: &self.type)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.address.isEmpty {
      try visitor.visitSingularStringField(value: self.address, fieldNumber: 1)
    }
    if !self.value.isEmpty {
      try visitor.visitSingularBytesField(value: self.value, fieldNumber: 2)
    }
    if self.type != .unset {
      try visitor.visitSingularEnumField(value: self.type, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: StateChange, rhs: StateChange) -> Bool {
    if lhs.address != rhs.address {return false}
    if lhs.value != rhs.value {return false}
    if lhs.type != rhs.type {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension StateChange.TypeEnum: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "TYPE_UNSET"),
    1: .same(proto: "SET"),
    2: .same(proto: "DELETE"),
  ]
}

extension StateChangeList: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "StateChangeList"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "state_changes"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.stateChanges)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.stateChanges.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.stateChanges, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: StateChangeList, rhs: StateChangeList) -> Bool {
    if lhs.stateChanges != rhs.stateChanges {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
