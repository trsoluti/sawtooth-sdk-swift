// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: validator.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

// Copyright 2016, 2017 Intel Corporation
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

/// A list of messages to be transmitted together.
public struct MessageList {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var messages: [Message] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// The message passed between the validator and client, containing the
/// header fields and content.
public struct Message {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The type of message, used to determine how to 'route' the message
  /// to the appropriate handler as well as how to deserialize the
  /// content.
  public var messageType: Message.MessageType = .default

  /// The identifier used to correlate response messages to their related
  /// request messages.  correlation_id should be set to a random string
  /// for messages which are not responses to previously sent messages.  For
  /// response messages, correlation_id should be set to the same string as
  /// contained in the request message.
  public var correlationID: String = String()

  /// The content of the message, defined by message_type.  In many
  /// cases, this data has been serialized with Protocol Buffers or
  /// CBOR.
  public var content: Data = SwiftProtobuf.Internal.emptyData

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum MessageType: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case `default` // = 0

    /// Registration request from the transaction processor to the validator
    case tpRegisterRequest // = 1

    /// Registration response from the validator to the
    /// transaction processor
    case tpRegisterResponse // = 2

    /// Tell the validator that the transaction processor
    /// won't take any more transactions
    case tpUnregisterRequest // = 3

    /// Response from the validator to the tp that it won't
    /// send any more transactions
    case tpUnregisterResponse // = 4

    /// Process Request from the validator/executor to the
    /// transaction processor
    case tpProcessRequest // = 5

    /// Process response from the transaction processor to the validator/executor
    case tpProcessResponse // = 6

    /// State get request from the transaction processor to validator/context_manager
    case tpStateGetRequest // = 7

    /// State get response from the validator/context_manager to the transaction processor
    case tpStateGetResponse // = 8

    /// State set request from the transaction processor to the validator/context_manager
    case tpStateSetRequest // = 9

    /// State set response from the validator/context_manager to the transaction processor
    case tpStateSetResponse // = 10

    /// State delete request from the transaction processor to the validator/context_manager
    case tpStateDeleteRequest // = 11

    /// State delete response from the validator/context_manager to the transaction processor
    case tpStateDeleteResponse // = 12

    /// Message to append data to a transaction receipt
    case tpReceiptAddDataRequest // = 13

    /// Response from validator to tell transaction processor that data has been appended
    case tpReceiptAddDataResponse // = 14

    /// Message to add event
    case tpEventAddRequest // = 15

    /// Response from validator to tell transaction processor that event has been created
    case tpEventAddResponse // = 16

    /// Submission of a batchlist from the web api or another client to the validator
    case clientBatchSubmitRequest // = 100

    /// Response from the validator to the web api/client that the submission was accepted
    case clientBatchSubmitResponse // = 101

    /// A request to list blocks from the web api/client to the validator
    case clientBlockListRequest // = 102
    case clientBlockListResponse // = 103
    case clientBlockGetByIDRequest // = 104
    case clientBlockGetResponse // = 105
    case clientBatchListRequest // = 106
    case clientBatchListResponse // = 107
    case clientBatchGetRequest // = 108
    case clientBatchGetResponse // = 109
    case clientTransactionListRequest // = 110
    case clientTransactionListResponse // = 111
    case clientTransactionGetRequest // = 112
    case clientTransactionGetResponse // = 113

    /// Client state request of the current state hash to be retrieved from the journal
    case clientStateCurrentRequest // = 114

    /// Response with the current state hash
    case clientStateCurrentResponse // = 115

    /// A request of all the addresses under a particular prefix, for a state hash.
    case clientStateListRequest // = 116

    /// The response of the addresses
    case clientStateListResponse // = 117

    /// Get the address:data entry at a particular address
    case clientStateGetRequest // = 118

    /// The response with the entry
    case clientStateGetResponse // = 119

    /// A request for the status of a batch or batches
    case clientBatchStatusRequest // = 120

    /// A response with the batch statuses
    case clientBatchStatusResponse // = 121

    /// A request for one or more transaction receipts
    case clientReceiptGetRequest // = 122

    /// A response with the receipts
    case clientReceiptGetResponse // = 123
    case clientBlockGetByNumRequest // = 124

    /// A request for a validator's peers
    case clientPeersGetRequest // = 125

    /// A response with the validator's peers
    case clientPeersGetResponse // = 126
    case clientBlockGetByTransactionIDRequest // = 127
    case clientBlockGetByBatchIDRequest // = 128

    /// A request for a validator's status
    case clientStatusGetRequest // = 129

    /// A response with the validator's status
    case clientStatusGetResponse // = 130

    /// Message types for events
    case clientEventsSubscribeRequest // = 500
    case clientEventsSubscribeResponse // = 501
    case clientEventsUnsubscribeRequest // = 502
    case clientEventsUnsubscribeResponse // = 503
    case clientEvents // = 504
    case clientEventsGetRequest // = 505
    case clientEventsGetResponse // = 506

    /// Temp message types until a discussion can be had about gossip msg
    case gossipMessage // = 200
    case gossipRegister // = 201
    case gossipUnregister // = 202
    case gossipBlockRequest // = 205
    case gossipBlockResponse // = 206
    case gossipBatchByBatchIDRequest // = 207
    case gossipBatchByTransactionIDRequest // = 208
    case gossipBatchResponse // = 209
    case gossipGetPeersRequest // = 210
    case gossipGetPeersResponse // = 211
    case gossipConsensusMessage // = 212
    case networkAck // = 300
    case networkConnect // = 301
    case networkDisconnect // = 302

    /// Message types for Authorization Types
    case authorizationConnectionResponse // = 600
    case authorizationViolation // = 601
    case authorizationTrustRequest // = 602
    case authorizationTrustResponse // = 603
    case authorizationChallengeRequest // = 604
    case authorizationChallengeResponse // = 605
    case authorizationChallengeSubmit // = 606
    case authorizationChallengeResult // = 607
    case pingRequest // = 700
    case pingResponse // = 701

    /// Consensus service messages
    case consensusRegisterRequest // = 800
    case consensusRegisterResponse // = 801
    case consensusSendToRequest // = 802
    case consensusSendToResponse // = 803
    case consensusBroadcastRequest // = 804
    case consensusBroadcastResponse // = 805
    case consensusInitializeBlockRequest // = 806
    case consensusInitializeBlockResponse // = 807
    case consensusFinalizeBlockRequest // = 808
    case consensusFinalizeBlockResponse // = 809
    case consensusSummarizeBlockRequest // = 828
    case consensusSummarizeBlockResponse // = 829
    case consensusCancelBlockRequest // = 810
    case consensusCancelBlockResponse // = 811
    case consensusCheckBlocksRequest // = 812
    case consensusCheckBlocksResponse // = 813
    case consensusCommitBlockRequest // = 814
    case consensusCommitBlockResponse // = 815
    case consensusIgnoreBlockRequest // = 816
    case consensusIgnoreBlockResponse // = 817
    case consensusFailBlockRequest // = 818
    case consensusFailBlockResponse // = 819
    case consensusSettingsGetRequest // = 820
    case consensusSettingsGetResponse // = 821
    case consensusStateGetRequest // = 822
    case consensusStateGetResponse // = 823
    case consensusBlocksGetRequest // = 824
    case consensusBlocksGetResponse // = 825
    case consensusChainHeadGetRequest // = 826
    case consensusChainHeadGetResponse // = 827

    /// Consensus notification messages
    case consensusNotifyPeerConnected // = 900
    case consensusNotifyPeerDisconnected // = 901
    case consensusNotifyPeerMessage // = 902
    case consensusNotifyBlockNew // = 903
    case consensusNotifyBlockValid // = 904
    case consensusNotifyBlockInvalid // = 905
    case consensusNotifyBlockCommit // = 906
    case consensusNotifyEngineActivated // = 907
    case consensusNotifyEngineDeactivated // = 908
    case consensusNotifyAck // = 999
    case UNRECOGNIZED(Int)

    public init() {
      self = .default
    }

    public init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .default
      case 1: self = .tpRegisterRequest
      case 2: self = .tpRegisterResponse
      case 3: self = .tpUnregisterRequest
      case 4: self = .tpUnregisterResponse
      case 5: self = .tpProcessRequest
      case 6: self = .tpProcessResponse
      case 7: self = .tpStateGetRequest
      case 8: self = .tpStateGetResponse
      case 9: self = .tpStateSetRequest
      case 10: self = .tpStateSetResponse
      case 11: self = .tpStateDeleteRequest
      case 12: self = .tpStateDeleteResponse
      case 13: self = .tpReceiptAddDataRequest
      case 14: self = .tpReceiptAddDataResponse
      case 15: self = .tpEventAddRequest
      case 16: self = .tpEventAddResponse
      case 100: self = .clientBatchSubmitRequest
      case 101: self = .clientBatchSubmitResponse
      case 102: self = .clientBlockListRequest
      case 103: self = .clientBlockListResponse
      case 104: self = .clientBlockGetByIDRequest
      case 105: self = .clientBlockGetResponse
      case 106: self = .clientBatchListRequest
      case 107: self = .clientBatchListResponse
      case 108: self = .clientBatchGetRequest
      case 109: self = .clientBatchGetResponse
      case 110: self = .clientTransactionListRequest
      case 111: self = .clientTransactionListResponse
      case 112: self = .clientTransactionGetRequest
      case 113: self = .clientTransactionGetResponse
      case 114: self = .clientStateCurrentRequest
      case 115: self = .clientStateCurrentResponse
      case 116: self = .clientStateListRequest
      case 117: self = .clientStateListResponse
      case 118: self = .clientStateGetRequest
      case 119: self = .clientStateGetResponse
      case 120: self = .clientBatchStatusRequest
      case 121: self = .clientBatchStatusResponse
      case 122: self = .clientReceiptGetRequest
      case 123: self = .clientReceiptGetResponse
      case 124: self = .clientBlockGetByNumRequest
      case 125: self = .clientPeersGetRequest
      case 126: self = .clientPeersGetResponse
      case 127: self = .clientBlockGetByTransactionIDRequest
      case 128: self = .clientBlockGetByBatchIDRequest
      case 129: self = .clientStatusGetRequest
      case 130: self = .clientStatusGetResponse
      case 200: self = .gossipMessage
      case 201: self = .gossipRegister
      case 202: self = .gossipUnregister
      case 205: self = .gossipBlockRequest
      case 206: self = .gossipBlockResponse
      case 207: self = .gossipBatchByBatchIDRequest
      case 208: self = .gossipBatchByTransactionIDRequest
      case 209: self = .gossipBatchResponse
      case 210: self = .gossipGetPeersRequest
      case 211: self = .gossipGetPeersResponse
      case 212: self = .gossipConsensusMessage
      case 300: self = .networkAck
      case 301: self = .networkConnect
      case 302: self = .networkDisconnect
      case 500: self = .clientEventsSubscribeRequest
      case 501: self = .clientEventsSubscribeResponse
      case 502: self = .clientEventsUnsubscribeRequest
      case 503: self = .clientEventsUnsubscribeResponse
      case 504: self = .clientEvents
      case 505: self = .clientEventsGetRequest
      case 506: self = .clientEventsGetResponse
      case 600: self = .authorizationConnectionResponse
      case 601: self = .authorizationViolation
      case 602: self = .authorizationTrustRequest
      case 603: self = .authorizationTrustResponse
      case 604: self = .authorizationChallengeRequest
      case 605: self = .authorizationChallengeResponse
      case 606: self = .authorizationChallengeSubmit
      case 607: self = .authorizationChallengeResult
      case 700: self = .pingRequest
      case 701: self = .pingResponse
      case 800: self = .consensusRegisterRequest
      case 801: self = .consensusRegisterResponse
      case 802: self = .consensusSendToRequest
      case 803: self = .consensusSendToResponse
      case 804: self = .consensusBroadcastRequest
      case 805: self = .consensusBroadcastResponse
      case 806: self = .consensusInitializeBlockRequest
      case 807: self = .consensusInitializeBlockResponse
      case 808: self = .consensusFinalizeBlockRequest
      case 809: self = .consensusFinalizeBlockResponse
      case 810: self = .consensusCancelBlockRequest
      case 811: self = .consensusCancelBlockResponse
      case 812: self = .consensusCheckBlocksRequest
      case 813: self = .consensusCheckBlocksResponse
      case 814: self = .consensusCommitBlockRequest
      case 815: self = .consensusCommitBlockResponse
      case 816: self = .consensusIgnoreBlockRequest
      case 817: self = .consensusIgnoreBlockResponse
      case 818: self = .consensusFailBlockRequest
      case 819: self = .consensusFailBlockResponse
      case 820: self = .consensusSettingsGetRequest
      case 821: self = .consensusSettingsGetResponse
      case 822: self = .consensusStateGetRequest
      case 823: self = .consensusStateGetResponse
      case 824: self = .consensusBlocksGetRequest
      case 825: self = .consensusBlocksGetResponse
      case 826: self = .consensusChainHeadGetRequest
      case 827: self = .consensusChainHeadGetResponse
      case 828: self = .consensusSummarizeBlockRequest
      case 829: self = .consensusSummarizeBlockResponse
      case 900: self = .consensusNotifyPeerConnected
      case 901: self = .consensusNotifyPeerDisconnected
      case 902: self = .consensusNotifyPeerMessage
      case 903: self = .consensusNotifyBlockNew
      case 904: self = .consensusNotifyBlockValid
      case 905: self = .consensusNotifyBlockInvalid
      case 906: self = .consensusNotifyBlockCommit
      case 907: self = .consensusNotifyEngineActivated
      case 908: self = .consensusNotifyEngineDeactivated
      case 999: self = .consensusNotifyAck
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    public var rawValue: Int {
      switch self {
      case .default: return 0
      case .tpRegisterRequest: return 1
      case .tpRegisterResponse: return 2
      case .tpUnregisterRequest: return 3
      case .tpUnregisterResponse: return 4
      case .tpProcessRequest: return 5
      case .tpProcessResponse: return 6
      case .tpStateGetRequest: return 7
      case .tpStateGetResponse: return 8
      case .tpStateSetRequest: return 9
      case .tpStateSetResponse: return 10
      case .tpStateDeleteRequest: return 11
      case .tpStateDeleteResponse: return 12
      case .tpReceiptAddDataRequest: return 13
      case .tpReceiptAddDataResponse: return 14
      case .tpEventAddRequest: return 15
      case .tpEventAddResponse: return 16
      case .clientBatchSubmitRequest: return 100
      case .clientBatchSubmitResponse: return 101
      case .clientBlockListRequest: return 102
      case .clientBlockListResponse: return 103
      case .clientBlockGetByIDRequest: return 104
      case .clientBlockGetResponse: return 105
      case .clientBatchListRequest: return 106
      case .clientBatchListResponse: return 107
      case .clientBatchGetRequest: return 108
      case .clientBatchGetResponse: return 109
      case .clientTransactionListRequest: return 110
      case .clientTransactionListResponse: return 111
      case .clientTransactionGetRequest: return 112
      case .clientTransactionGetResponse: return 113
      case .clientStateCurrentRequest: return 114
      case .clientStateCurrentResponse: return 115
      case .clientStateListRequest: return 116
      case .clientStateListResponse: return 117
      case .clientStateGetRequest: return 118
      case .clientStateGetResponse: return 119
      case .clientBatchStatusRequest: return 120
      case .clientBatchStatusResponse: return 121
      case .clientReceiptGetRequest: return 122
      case .clientReceiptGetResponse: return 123
      case .clientBlockGetByNumRequest: return 124
      case .clientPeersGetRequest: return 125
      case .clientPeersGetResponse: return 126
      case .clientBlockGetByTransactionIDRequest: return 127
      case .clientBlockGetByBatchIDRequest: return 128
      case .clientStatusGetRequest: return 129
      case .clientStatusGetResponse: return 130
      case .gossipMessage: return 200
      case .gossipRegister: return 201
      case .gossipUnregister: return 202
      case .gossipBlockRequest: return 205
      case .gossipBlockResponse: return 206
      case .gossipBatchByBatchIDRequest: return 207
      case .gossipBatchByTransactionIDRequest: return 208
      case .gossipBatchResponse: return 209
      case .gossipGetPeersRequest: return 210
      case .gossipGetPeersResponse: return 211
      case .gossipConsensusMessage: return 212
      case .networkAck: return 300
      case .networkConnect: return 301
      case .networkDisconnect: return 302
      case .clientEventsSubscribeRequest: return 500
      case .clientEventsSubscribeResponse: return 501
      case .clientEventsUnsubscribeRequest: return 502
      case .clientEventsUnsubscribeResponse: return 503
      case .clientEvents: return 504
      case .clientEventsGetRequest: return 505
      case .clientEventsGetResponse: return 506
      case .authorizationConnectionResponse: return 600
      case .authorizationViolation: return 601
      case .authorizationTrustRequest: return 602
      case .authorizationTrustResponse: return 603
      case .authorizationChallengeRequest: return 604
      case .authorizationChallengeResponse: return 605
      case .authorizationChallengeSubmit: return 606
      case .authorizationChallengeResult: return 607
      case .pingRequest: return 700
      case .pingResponse: return 701
      case .consensusRegisterRequest: return 800
      case .consensusRegisterResponse: return 801
      case .consensusSendToRequest: return 802
      case .consensusSendToResponse: return 803
      case .consensusBroadcastRequest: return 804
      case .consensusBroadcastResponse: return 805
      case .consensusInitializeBlockRequest: return 806
      case .consensusInitializeBlockResponse: return 807
      case .consensusFinalizeBlockRequest: return 808
      case .consensusFinalizeBlockResponse: return 809
      case .consensusCancelBlockRequest: return 810
      case .consensusCancelBlockResponse: return 811
      case .consensusCheckBlocksRequest: return 812
      case .consensusCheckBlocksResponse: return 813
      case .consensusCommitBlockRequest: return 814
      case .consensusCommitBlockResponse: return 815
      case .consensusIgnoreBlockRequest: return 816
      case .consensusIgnoreBlockResponse: return 817
      case .consensusFailBlockRequest: return 818
      case .consensusFailBlockResponse: return 819
      case .consensusSettingsGetRequest: return 820
      case .consensusSettingsGetResponse: return 821
      case .consensusStateGetRequest: return 822
      case .consensusStateGetResponse: return 823
      case .consensusBlocksGetRequest: return 824
      case .consensusBlocksGetResponse: return 825
      case .consensusChainHeadGetRequest: return 826
      case .consensusChainHeadGetResponse: return 827
      case .consensusSummarizeBlockRequest: return 828
      case .consensusSummarizeBlockResponse: return 829
      case .consensusNotifyPeerConnected: return 900
      case .consensusNotifyPeerDisconnected: return 901
      case .consensusNotifyPeerMessage: return 902
      case .consensusNotifyBlockNew: return 903
      case .consensusNotifyBlockValid: return 904
      case .consensusNotifyBlockInvalid: return 905
      case .consensusNotifyBlockCommit: return 906
      case .consensusNotifyEngineActivated: return 907
      case .consensusNotifyEngineDeactivated: return 908
      case .consensusNotifyAck: return 999
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  public init() {}
}

#if swift(>=4.2)

extension Message.MessageType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [Message.MessageType] = [
    .default,
    .tpRegisterRequest,
    .tpRegisterResponse,
    .tpUnregisterRequest,
    .tpUnregisterResponse,
    .tpProcessRequest,
    .tpProcessResponse,
    .tpStateGetRequest,
    .tpStateGetResponse,
    .tpStateSetRequest,
    .tpStateSetResponse,
    .tpStateDeleteRequest,
    .tpStateDeleteResponse,
    .tpReceiptAddDataRequest,
    .tpReceiptAddDataResponse,
    .tpEventAddRequest,
    .tpEventAddResponse,
    .clientBatchSubmitRequest,
    .clientBatchSubmitResponse,
    .clientBlockListRequest,
    .clientBlockListResponse,
    .clientBlockGetByIDRequest,
    .clientBlockGetResponse,
    .clientBatchListRequest,
    .clientBatchListResponse,
    .clientBatchGetRequest,
    .clientBatchGetResponse,
    .clientTransactionListRequest,
    .clientTransactionListResponse,
    .clientTransactionGetRequest,
    .clientTransactionGetResponse,
    .clientStateCurrentRequest,
    .clientStateCurrentResponse,
    .clientStateListRequest,
    .clientStateListResponse,
    .clientStateGetRequest,
    .clientStateGetResponse,
    .clientBatchStatusRequest,
    .clientBatchStatusResponse,
    .clientReceiptGetRequest,
    .clientReceiptGetResponse,
    .clientBlockGetByNumRequest,
    .clientPeersGetRequest,
    .clientPeersGetResponse,
    .clientBlockGetByTransactionIDRequest,
    .clientBlockGetByBatchIDRequest,
    .clientStatusGetRequest,
    .clientStatusGetResponse,
    .clientEventsSubscribeRequest,
    .clientEventsSubscribeResponse,
    .clientEventsUnsubscribeRequest,
    .clientEventsUnsubscribeResponse,
    .clientEvents,
    .clientEventsGetRequest,
    .clientEventsGetResponse,
    .gossipMessage,
    .gossipRegister,
    .gossipUnregister,
    .gossipBlockRequest,
    .gossipBlockResponse,
    .gossipBatchByBatchIDRequest,
    .gossipBatchByTransactionIDRequest,
    .gossipBatchResponse,
    .gossipGetPeersRequest,
    .gossipGetPeersResponse,
    .gossipConsensusMessage,
    .networkAck,
    .networkConnect,
    .networkDisconnect,
    .authorizationConnectionResponse,
    .authorizationViolation,
    .authorizationTrustRequest,
    .authorizationTrustResponse,
    .authorizationChallengeRequest,
    .authorizationChallengeResponse,
    .authorizationChallengeSubmit,
    .authorizationChallengeResult,
    .pingRequest,
    .pingResponse,
    .consensusRegisterRequest,
    .consensusRegisterResponse,
    .consensusSendToRequest,
    .consensusSendToResponse,
    .consensusBroadcastRequest,
    .consensusBroadcastResponse,
    .consensusInitializeBlockRequest,
    .consensusInitializeBlockResponse,
    .consensusFinalizeBlockRequest,
    .consensusFinalizeBlockResponse,
    .consensusSummarizeBlockRequest,
    .consensusSummarizeBlockResponse,
    .consensusCancelBlockRequest,
    .consensusCancelBlockResponse,
    .consensusCheckBlocksRequest,
    .consensusCheckBlocksResponse,
    .consensusCommitBlockRequest,
    .consensusCommitBlockResponse,
    .consensusIgnoreBlockRequest,
    .consensusIgnoreBlockResponse,
    .consensusFailBlockRequest,
    .consensusFailBlockResponse,
    .consensusSettingsGetRequest,
    .consensusSettingsGetResponse,
    .consensusStateGetRequest,
    .consensusStateGetResponse,
    .consensusBlocksGetRequest,
    .consensusBlocksGetResponse,
    .consensusChainHeadGetRequest,
    .consensusChainHeadGetResponse,
    .consensusNotifyPeerConnected,
    .consensusNotifyPeerDisconnected,
    .consensusNotifyPeerMessage,
    .consensusNotifyBlockNew,
    .consensusNotifyBlockValid,
    .consensusNotifyBlockInvalid,
    .consensusNotifyBlockCommit,
    .consensusNotifyEngineActivated,
    .consensusNotifyEngineDeactivated,
    .consensusNotifyAck,
  ]
}

#endif  // swift(>=4.2)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension MessageList: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "MessageList"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "messages"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.messages)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.messages.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.messages, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: MessageList, rhs: MessageList) -> Bool {
    if lhs.messages != rhs.messages {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Message: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = "Message"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "message_type"),
    2: .standard(proto: "correlation_id"),
    3: .same(proto: "content"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularEnumField(value: &self.messageType)
      case 2: try decoder.decodeSingularStringField(value: &self.correlationID)
      case 3: try decoder.decodeSingularBytesField(value: &self.content)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.messageType != .default {
      try visitor.visitSingularEnumField(value: self.messageType, fieldNumber: 1)
    }
    if !self.correlationID.isEmpty {
      try visitor.visitSingularStringField(value: self.correlationID, fieldNumber: 2)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularBytesField(value: self.content, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Message, rhs: Message) -> Bool {
    if lhs.messageType != rhs.messageType {return false}
    if lhs.correlationID != rhs.correlationID {return false}
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Message.MessageType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "DEFAULT"),
    1: .same(proto: "TP_REGISTER_REQUEST"),
    2: .same(proto: "TP_REGISTER_RESPONSE"),
    3: .same(proto: "TP_UNREGISTER_REQUEST"),
    4: .same(proto: "TP_UNREGISTER_RESPONSE"),
    5: .same(proto: "TP_PROCESS_REQUEST"),
    6: .same(proto: "TP_PROCESS_RESPONSE"),
    7: .same(proto: "TP_STATE_GET_REQUEST"),
    8: .same(proto: "TP_STATE_GET_RESPONSE"),
    9: .same(proto: "TP_STATE_SET_REQUEST"),
    10: .same(proto: "TP_STATE_SET_RESPONSE"),
    11: .same(proto: "TP_STATE_DELETE_REQUEST"),
    12: .same(proto: "TP_STATE_DELETE_RESPONSE"),
    13: .same(proto: "TP_RECEIPT_ADD_DATA_REQUEST"),
    14: .same(proto: "TP_RECEIPT_ADD_DATA_RESPONSE"),
    15: .same(proto: "TP_EVENT_ADD_REQUEST"),
    16: .same(proto: "TP_EVENT_ADD_RESPONSE"),
    100: .same(proto: "CLIENT_BATCH_SUBMIT_REQUEST"),
    101: .same(proto: "CLIENT_BATCH_SUBMIT_RESPONSE"),
    102: .same(proto: "CLIENT_BLOCK_LIST_REQUEST"),
    103: .same(proto: "CLIENT_BLOCK_LIST_RESPONSE"),
    104: .same(proto: "CLIENT_BLOCK_GET_BY_ID_REQUEST"),
    105: .same(proto: "CLIENT_BLOCK_GET_RESPONSE"),
    106: .same(proto: "CLIENT_BATCH_LIST_REQUEST"),
    107: .same(proto: "CLIENT_BATCH_LIST_RESPONSE"),
    108: .same(proto: "CLIENT_BATCH_GET_REQUEST"),
    109: .same(proto: "CLIENT_BATCH_GET_RESPONSE"),
    110: .same(proto: "CLIENT_TRANSACTION_LIST_REQUEST"),
    111: .same(proto: "CLIENT_TRANSACTION_LIST_RESPONSE"),
    112: .same(proto: "CLIENT_TRANSACTION_GET_REQUEST"),
    113: .same(proto: "CLIENT_TRANSACTION_GET_RESPONSE"),
    114: .same(proto: "CLIENT_STATE_CURRENT_REQUEST"),
    115: .same(proto: "CLIENT_STATE_CURRENT_RESPONSE"),
    116: .same(proto: "CLIENT_STATE_LIST_REQUEST"),
    117: .same(proto: "CLIENT_STATE_LIST_RESPONSE"),
    118: .same(proto: "CLIENT_STATE_GET_REQUEST"),
    119: .same(proto: "CLIENT_STATE_GET_RESPONSE"),
    120: .same(proto: "CLIENT_BATCH_STATUS_REQUEST"),
    121: .same(proto: "CLIENT_BATCH_STATUS_RESPONSE"),
    122: .same(proto: "CLIENT_RECEIPT_GET_REQUEST"),
    123: .same(proto: "CLIENT_RECEIPT_GET_RESPONSE"),
    124: .same(proto: "CLIENT_BLOCK_GET_BY_NUM_REQUEST"),
    125: .same(proto: "CLIENT_PEERS_GET_REQUEST"),
    126: .same(proto: "CLIENT_PEERS_GET_RESPONSE"),
    127: .same(proto: "CLIENT_BLOCK_GET_BY_TRANSACTION_ID_REQUEST"),
    128: .same(proto: "CLIENT_BLOCK_GET_BY_BATCH_ID_REQUEST"),
    129: .same(proto: "CLIENT_STATUS_GET_REQUEST"),
    130: .same(proto: "CLIENT_STATUS_GET_RESPONSE"),
    200: .same(proto: "GOSSIP_MESSAGE"),
    201: .same(proto: "GOSSIP_REGISTER"),
    202: .same(proto: "GOSSIP_UNREGISTER"),
    205: .same(proto: "GOSSIP_BLOCK_REQUEST"),
    206: .same(proto: "GOSSIP_BLOCK_RESPONSE"),
    207: .same(proto: "GOSSIP_BATCH_BY_BATCH_ID_REQUEST"),
    208: .same(proto: "GOSSIP_BATCH_BY_TRANSACTION_ID_REQUEST"),
    209: .same(proto: "GOSSIP_BATCH_RESPONSE"),
    210: .same(proto: "GOSSIP_GET_PEERS_REQUEST"),
    211: .same(proto: "GOSSIP_GET_PEERS_RESPONSE"),
    212: .same(proto: "GOSSIP_CONSENSUS_MESSAGE"),
    300: .same(proto: "NETWORK_ACK"),
    301: .same(proto: "NETWORK_CONNECT"),
    302: .same(proto: "NETWORK_DISCONNECT"),
    500: .same(proto: "CLIENT_EVENTS_SUBSCRIBE_REQUEST"),
    501: .same(proto: "CLIENT_EVENTS_SUBSCRIBE_RESPONSE"),
    502: .same(proto: "CLIENT_EVENTS_UNSUBSCRIBE_REQUEST"),
    503: .same(proto: "CLIENT_EVENTS_UNSUBSCRIBE_RESPONSE"),
    504: .same(proto: "CLIENT_EVENTS"),
    505: .same(proto: "CLIENT_EVENTS_GET_REQUEST"),
    506: .same(proto: "CLIENT_EVENTS_GET_RESPONSE"),
    600: .same(proto: "AUTHORIZATION_CONNECTION_RESPONSE"),
    601: .same(proto: "AUTHORIZATION_VIOLATION"),
    602: .same(proto: "AUTHORIZATION_TRUST_REQUEST"),
    603: .same(proto: "AUTHORIZATION_TRUST_RESPONSE"),
    604: .same(proto: "AUTHORIZATION_CHALLENGE_REQUEST"),
    605: .same(proto: "AUTHORIZATION_CHALLENGE_RESPONSE"),
    606: .same(proto: "AUTHORIZATION_CHALLENGE_SUBMIT"),
    607: .same(proto: "AUTHORIZATION_CHALLENGE_RESULT"),
    700: .same(proto: "PING_REQUEST"),
    701: .same(proto: "PING_RESPONSE"),
    800: .same(proto: "CONSENSUS_REGISTER_REQUEST"),
    801: .same(proto: "CONSENSUS_REGISTER_RESPONSE"),
    802: .same(proto: "CONSENSUS_SEND_TO_REQUEST"),
    803: .same(proto: "CONSENSUS_SEND_TO_RESPONSE"),
    804: .same(proto: "CONSENSUS_BROADCAST_REQUEST"),
    805: .same(proto: "CONSENSUS_BROADCAST_RESPONSE"),
    806: .same(proto: "CONSENSUS_INITIALIZE_BLOCK_REQUEST"),
    807: .same(proto: "CONSENSUS_INITIALIZE_BLOCK_RESPONSE"),
    808: .same(proto: "CONSENSUS_FINALIZE_BLOCK_REQUEST"),
    809: .same(proto: "CONSENSUS_FINALIZE_BLOCK_RESPONSE"),
    810: .same(proto: "CONSENSUS_CANCEL_BLOCK_REQUEST"),
    811: .same(proto: "CONSENSUS_CANCEL_BLOCK_RESPONSE"),
    812: .same(proto: "CONSENSUS_CHECK_BLOCKS_REQUEST"),
    813: .same(proto: "CONSENSUS_CHECK_BLOCKS_RESPONSE"),
    814: .same(proto: "CONSENSUS_COMMIT_BLOCK_REQUEST"),
    815: .same(proto: "CONSENSUS_COMMIT_BLOCK_RESPONSE"),
    816: .same(proto: "CONSENSUS_IGNORE_BLOCK_REQUEST"),
    817: .same(proto: "CONSENSUS_IGNORE_BLOCK_RESPONSE"),
    818: .same(proto: "CONSENSUS_FAIL_BLOCK_REQUEST"),
    819: .same(proto: "CONSENSUS_FAIL_BLOCK_RESPONSE"),
    820: .same(proto: "CONSENSUS_SETTINGS_GET_REQUEST"),
    821: .same(proto: "CONSENSUS_SETTINGS_GET_RESPONSE"),
    822: .same(proto: "CONSENSUS_STATE_GET_REQUEST"),
    823: .same(proto: "CONSENSUS_STATE_GET_RESPONSE"),
    824: .same(proto: "CONSENSUS_BLOCKS_GET_REQUEST"),
    825: .same(proto: "CONSENSUS_BLOCKS_GET_RESPONSE"),
    826: .same(proto: "CONSENSUS_CHAIN_HEAD_GET_REQUEST"),
    827: .same(proto: "CONSENSUS_CHAIN_HEAD_GET_RESPONSE"),
    828: .same(proto: "CONSENSUS_SUMMARIZE_BLOCK_REQUEST"),
    829: .same(proto: "CONSENSUS_SUMMARIZE_BLOCK_RESPONSE"),
    900: .same(proto: "CONSENSUS_NOTIFY_PEER_CONNECTED"),
    901: .same(proto: "CONSENSUS_NOTIFY_PEER_DISCONNECTED"),
    902: .same(proto: "CONSENSUS_NOTIFY_PEER_MESSAGE"),
    903: .same(proto: "CONSENSUS_NOTIFY_BLOCK_NEW"),
    904: .same(proto: "CONSENSUS_NOTIFY_BLOCK_VALID"),
    905: .same(proto: "CONSENSUS_NOTIFY_BLOCK_INVALID"),
    906: .same(proto: "CONSENSUS_NOTIFY_BLOCK_COMMIT"),
    907: .same(proto: "CONSENSUS_NOTIFY_ENGINE_ACTIVATED"),
    908: .same(proto: "CONSENSUS_NOTIFY_ENGINE_DEACTIVATED"),
    999: .same(proto: "CONSENSUS_NOTIFY_ACK"),
  ]
}
