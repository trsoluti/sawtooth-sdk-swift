//
//  ZMQService.swift
//  sawtooth-sdk-swift
//
//  Created by Teaching on 8/7/19.
//

import Foundation // needed for Data type
import Dispatch

// /*
//  * Copyright 2018 Intel Corporation
//  *
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *     http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  * ------------------------------------------------------------------------------
//  */
//
// use protobuf;
// TODO: get the protobuf message protocol from the protobuf package:
import SwiftProtobuf
// use rand;
// use rand::Rng;
//
// use consensus::engine::*;
// use consensus::service::Service;
//
// use messaging::stream::MessageSender;
// use messaging::zmq_stream::ZmqMessageSender;
//
// use messages::consensus::*;
// use messages::validator::Message_MessageType;
import SawtoothProtoSwift
//
// use std::collections::HashMap;
// use std::time::Duration;
//
// /// Generates a random correlation id for use in Message
// Already in ZMQDriver.swift
// fn generate_correlation_id() -> String {
//     const LENGTH: usize = 16;
//     rand::thread_rng().gen_ascii_chars().take(LENGTH).collect()
// }
//
// pub struct ZmqService {
public class ZmqService {
    // sender: ZmqMessageSender,
    var sender: ZmqMessageSender
    // timeout: Duration,
    let timeout: Duration
    // pub fn new(sender: ZmqMessageSender, timeout: Duration) -> Self {
    public init(sender: ZmqMessageSender, timeout: Duration) {
        // ZmqService { sender, timeout }
        self.sender = sender
        self.timeout = timeout
    }
    // }
    //
}
// }
//
// impl ZmqService {
public extension ZmqService {
    // /// Serialize and send a request, wait for the default timeout, and receive and parse an
    // /// expected response.
    // pub fn rpc<I: protobuf::Message, O: protobuf::Message>(
    func rpc<I: SwiftProtobuf.Message, O: SwiftProtobuf.Message>(
        // &mut self,
        // request: &I,
        request: I,
        // request_type: Message_MessageType,
        requestType: SawtoothProtoSwift.Message.MessageType,
        // response_type: Message_MessageType,
        responseType: SawtoothProtoSwift.Message.MessageType
    )
    // ) -> Result<O, Error> {
    throws -> O {
        // let corr_id = generate_correlation_id();
        let corrID = generateCorrelationID()
        // let mut future = self
        //     .sender
        //     .send(request_type, &corr_id, &request.write_to_bytes()?)?;
        let future = try self.sender.send(
            destination: requestType,
            correlationID: corrID,
            contents: request.serializedData()
        )
        //
        // let msg = future.get_timeout(self.timeout)?;
        let msg = try future.getTimeout(timeout: self.timeout).get()
        // let msg_type = msg.get_message_type();
        let msgType = msg.messageType
        // if msg_type == response_type {
        if msgType == responseType {
            // let response = protobuf::parse_from_bytes(msg.get_content())?;
            // Ok(response)
            return try O.init(serializedData: msg.content)
        }
        // } else {
        else {
            // Err(Error::ReceiveError(format!(
            //     "Received unexpected message type: {:?}",
            //     msg_type
            // )))
            throw ConsensusError.ReceiveError("Received unexpected message type \(msgType)")
        }
        // }
    }
    // }
}
// }
//
// /// Return Ok(()) if $r.get_status() matches $ok
// macro_rules! check_ok {
//     ($r:expr, $ok:pat) => {
//         match $r.get_status() {
//             $ok => Ok(()),
//             status => Err(Error::ReceiveError(format!(
//                 "Failed with status {:?}",
//                 status
//             ))),
//         }
//     };
// }

//
// impl Service for ZmqService {
extension ZmqService: Service {
    // fn send_to(
    public func sendTo(
        // peer: &PeerId,
        peer: PeerId,
        // message_type: &str,
        messageType: String,
        // payload: Vec<u8>,
        payload: [UInt8]
    )
    // ) -> Result<(), Error> {
    throws {
        // let mut request = ConsensusSendToRequest::new();
        var request = ConsensusSendToRequest()
        // request.set_content(payload);
        request.content = Data(payload)
        // request.set_message_type(message_type.into());
        request.messageType = messageType
        // request.set_receiver_id((*peer).clone());
        request.receiverID = Data(peer)
        //
        // let response: ConsensusSendToResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_SEND_TO_REQUEST,
        //     Message_MessageType::CONSENSUS_SEND_TO_RESPONSE,
        // )?;
        let response: ConsensusSendToResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusSendToRequest,
            responseType: Message.MessageType.consensusSendToResponse
        )
        //
        // check_ok!(response, ConsensusSendToResponse_Status::OK)
        if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
    }
    // }
    //
    // fn broadcast(&mut self, message_type: &str, payload: Vec<u8>) -> Result<(), Error> {
    public func broadcast(messageType: String, payload: [UInt8]) throws {
        // let mut request = ConsensusBroadcastRequest::new();
        var request = ConsensusBroadcastRequest()
        // request.set_content(payload);
        request.content = Data(payload)
        // request.set_message_type(message_type.into());
        request.messageType = messageType
        //
        // let response: ConsensusBroadcastResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_BROADCAST_REQUEST,
        //     Message_MessageType::CONSENSUS_BROADCAST_RESPONSE,
        // )?;
        let response: ConsensusBroadcastResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusBroadcastRequest,
            responseType: Message.MessageType.consensusBroadcastResponse)
        //
        // check_ok!(response, ConsensusBroadcastResponse_Status::OK)
        if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
    }
    // }
    //
    // fn initialize_block(&mut self, previous_id: Option<BlockId>) -> Result<(), Error> {
    public func initializeBlock(previousID: BlockId?) throws {
        // let mut request = ConsensusInitializeBlockRequest::new();
        var request = ConsensusInitializeBlockRequest()
        // if let Some(previous_id) = previous_id {
        if let previousID = previousID {
            // request.set_previous_id(previous_id);
            request.previousID = Data(previousID)
        }
        // }
        //
        // let response: ConsensusInitializeBlockResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_INITIALIZE_BLOCK_REQUEST,
        //     Message_MessageType::CONSENSUS_INITIALIZE_BLOCK_RESPONSE,
        // )?;
        let response: ConsensusInitializeBlockResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusInitializeBlockRequest,
            responseType: Message.MessageType.consensusInitializeBlockResponse
        )
        //
        // if response.get_status() == sensusInitializeBlockResponse_Status::INVALID_STATE {
        if response.status == .invalidState {
            // return Err(Error::InvalidState(
            //     "Cannot initialize block in current state".into(),
            // ));
            throw ConsensusError.InvalidState("Cannot initialize block in current state")
        }
        // }
        //
        // if response.get_status() == ConsensusInitializeBlockResponse_Status::UNKNOWN_BLOCK {
        if response.status == .unknownBlock {
            // return Err(Error::UnknownBlock("Block not found".into()));
            throw ConsensusError.UnknownBlock("Block not found")
        }
        // }
        //
        // check_ok!(response, ConsensusInitializeBlockResponse_Status::OK)
        if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
    }
    // }
    //
    // fn summarize_block(&mut self) -> Result<Vec<u8>, Error> {
    public func summarizeBlock() throws -> [UInt8] {
        // let request = ConsensusSummarizeBlockRequest::new();
        let request = ConsensusSummarizeBlockRequest()
        //
        // let mut response: ConsensusSummarizeBlockResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_SUMMARIZE_BLOCK_REQUEST,
        //     Message_MessageType::CONSENSUS_SUMMARIZE_BLOCK_RESPONSE,
        // )?;
        let response: ConsensusSummarizeBlockResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusSummarizeBlockRequest,
            responseType: Message.MessageType.consensusSummarizeBlockResponse
        )
        //
        // match response.get_status() {
        switch response.status {
        //     ConsensusSummarizeBlockResponse_Status::INVALID_STATE => Err(Error::InvalidState(
        //         "Cannot summarize block in current state".into(),
        //     )),
        case .invalidState:
            throw ConsensusError.InvalidState("Cannot summarize block in current state")
        //     ConsensusSummarizeBlockResponse_Status::BLOCK_NOT_READY => Err(Error::BlockNotReady),
        case .blockNotReady:
            throw ConsensusError.BlockNotReady
        //     _ => check_ok!(response, ConsensusSummarizeBlockResponse_Status::OK),
        default:
            if response.status != .ok {
                throw ConsensusError.ReceiveError("Failed with status \(response.status)")
            }
        // }?;
        }
        //
        // Ok(response.take_summary())
        return [UInt8](response.summary)
    }
    // }
    //
    // fn finalize_block(&mut self, data: Vec<u8>) -> Result<BlockId, Error> {
    public func finalizeBlock(data: [UInt8]) throws -> BlockId {
        // let mut request = ConsensusFinalizeBlockRequest::new();
        var request = ConsensusFinalizeBlockRequest()
        // request.set_data(data);
        request.data = Data(data)
        //
        // let mut response: ConsensusFinalizeBlockRequest = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_FINALIZE_BLOCK_REQUEST,
        //     Message_MessageType::CONSENSUS_FINALIZE_BLOCK_RESPONSE,
        // )?;
        let response: ConsensusFinalizeBlockResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusFinalizeBlockRequest,
            responseType: Message.MessageType.consensusFinalizeBlockResponse
        )
        //
        // match response.get_status() {
        switch response.status {
        //     ConsensusFinalizeBlockResponse_Status::INVALID_STATE => Err(Error::InvalidState(
        //         "Cannot finalize block in current state".into(),
        //     )),
        case .invalidState:
            throw ConsensusError.InvalidState("Cannot finalize block in current state")
        //     ConsensusFinalizeBlockResponse_Status::BLOCK_NOT_READY => Err(Error::BlockNotReady),
        case .blockNotReady:
            throw ConsensusError.BlockNotReady
        //     _ => check_ok!(response, ConsensusFinalizeBlockResponse_Status::OK),
        default:
            if response.status != .ok {
                throw ConsensusError.ReceiveError("Failed with status \(response.status)")
            }
        }
        // }?;
        //
        // Ok(response.take_block_id())
        return [UInt8](response.blockID)
    }
    // }
    //
    // fn cancel_block(&mut self) -> Result<(), Error> {
    public func cancelBlock() throws {
        // let request = ConsensusCancelBlockRequest::new();
        let request = ConsensusCancelBlockRequest()
        //
        // let response: ConsensusCancelBlockResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_CANCEL_BLOCK_REQUEST,
        //     Message_MessageType::CONSENSUS_CANCEL_BLOCK_RESPONSE,
        // )?;
        let response: ConsensusCancelBlockResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusCancelBlockRequest,
            responseType: Message.MessageType.consensusCancelBlockResponse
        )
        //
        // if response.get_status() == ConsensusCancelBlockResponse_Status::INVALID_STATE {
        if response.status == .invalidState {
            // Err(Error::InvalidState(
            //     "Cannot cancel block in current state".into(),
            // ))
            throw ConsensusError.InvalidState("Cannot cancel block in current state")
        }
        // } else {
        //     check_ok!(response, ConsensusCancelBlockResponse_Status::OK)
        // }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
    }
    // }
    //
    // fn check_blocks(&mut self, priority: Vec<BlockId>) -> Result<(), Error> {
    public func checkBlocks(priority: [BlockId]) throws {
        // let mut request = ConsensusCheckBlocksRequest::new();
        var request = ConsensusCheckBlocksRequest()
        // request.set_block_ids(protobuf::RepeatedField::from_vec(
        //     priority.into_iter().map(Vec::from).collect(),
        // ));
        request.blockIds = priority.map({ (blockID) -> Data in
            Data(blockID)
        })
        //
        // let response: ConsensusCheckBlocksResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_CHECK_BLOCKS_REQUEST,
        //     Message_MessageType::CONSENSUS_CHECK_BLOCKS_RESPONSE,
        // )?;
        let response: ConsensusCheckBlocksResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusCheckBlocksRequest,
            responseType: Message.MessageType.consensusCheckBlocksResponse)
        //
        // if response.get_status() == ConsensusCheckBlocksResponse_Status::UNKNOWN_BLOCK {
        if response.status == .unknownBlock {
            // Err(Error::UnknownBlock("Block not found".into()))
            throw ConsensusError.UnknownBlock("Block not found")
        }
        // } else {
        //     check_ok!(response, ConsensusCheckBlocksResponse_Status::OK)
        // }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
    }
    // }
    //
    // fn commit_block(&mut self, block_id: BlockId) -> Result<(), Error> {
    public func commitBlock(blockID: BlockId) throws {
        // let mut request = ConsensusCommitBlockRequest::new();
        var request = ConsensusCommitBlockRequest()
        // request.set_block_id(block_id);
        request.blockID = Data(blockID)
        //
        // let response: ConsensusCommitBlockResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_COMMIT_BLOCK_REQUEST,
        //     Message_MessageType::CONSENSUS_COMMIT_BLOCK_RESPONSE,
        // )?;
        let response: ConsensusCommitBlockResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusCommitBlockRequest,
            responseType: Message.MessageType.consensusCommitBlockResponse
        )
        //
        // if response.get_status() == ConsensusCommitBlockResponse_Status::UNKNOWN_BLOCK {
        if response.status == .unknownBlock {
            // Err(Error::UnknownBlock("Block not found".into()))
            throw ConsensusError.UnknownBlock("Block not found")
        }
        // } else {
        //     check_ok!(response, ConsensusCommitBlockResponse_Status::OK)
        // }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
    }
    // }
    //
    // fn ignore_block(&mut self, block_id: BlockId) -> Result<(), Error> {
    public func ignoreBlock(blockID: BlockId) throws {
        // let mut request = ConsensusIgnoreBlockRequest::new();
        var request = ConsensusIgnoreBlockRequest()
        // request.set_block_id(block_id);
        request.blockID = Data(blockID)
        //
        // let response: ConsensusIgnoreBlockResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_IGNORE_BLOCK_REQUEST,
        //     Message_MessageType::CONSENSUS_IGNORE_BLOCK_RESPONSE,
        // )?;
        let response: ConsensusIgnoreBlockResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusIgnoreBlockRequest,
            responseType: Message.MessageType.consensusIgnoreBlockResponse
        )
        //
        // if response.get_status() == ConsensusIgnoreBlockResponse_Status::UNKNOWN_BLOCK {
        if response.status == .unknownBlock {
            // Err(Error::UnknownBlock("Block not found".into()))
            throw ConsensusError.UnknownBlock("Block not found")
        }
            // } else {
            //     check_ok!(response, ConsensusCommitBlockResponse_Status::OK)
            // }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
    }
    // }
    //
    // fn fail_block(&mut self, block_id: BlockId) -> Result<(), Error> {
    public func failBlock(blockID: BlockId) throws {
        // let mut request = ConsensusFailBlockRequest::new();
        var request = ConsensusFailBlockRequest()
        // request.set_block_id(block_id);
        request.blockID = Data(blockID)
        //
        // let response: ConsensusFailBlockResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_FAIL_BLOCK_REQUEST,
        //     Message_MessageType::CONSENSUS_FAIL_BLOCK_RESPONSE,
        // )?;
        let response: ConsensusFailBlockResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusFailBlockRequest,
            responseType: Message.MessageType.consensusFailBlockResponse
        )
        //
        // if response.get_status() == ConsensusFailBlockResponse_Status::UNKNOWN_BLOCK {
        //     Err(Error::UnknownBlock("Block not found".into()))
        // } else {
        //     check_ok!(response, ConsensusFailBlockResponse_Status::OK)
        // }
        if response.status == .unknownBlock {
            throw ConsensusError.UnknownBlock("Block not found")
        }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
    }
    // }
    //
    // fn get_blocks(&mut self, block_ids: Vec<BlockId>) -> Result<HashMap<BlockId, Block>, Error> {
    public func getBlocks(blockIDs: [BlockId]) throws -> Dictionary<BlockId, EngineBlock> {
        // let mut request = ConsensusBlocksGetRequest::new();
        var request = ConsensusBlocksGetRequest()
        // request.set_block_ids(protobuf::RepeatedField::from_vec(
        //     block_ids.into_iter().map(Vec::from).collect(),
        // ));
        request.blockIds = blockIDs.map({ (blockID) -> Data in
            Data(blockID)
        })
        //
        // let mut response: ConsensusBlocksGetResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_BLOCKS_GET_REQUEST,
        //     Message_MessageType::CONSENSUS_BLOCKS_GET_RESPONSE,
        // )?;
        let response: ConsensusBlocksGetResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusBlocksGetRequest,
            responseType: Message.MessageType.consensusBlocksGetResponse
        )
        //
        // if response.get_status() == ConsensusBlocksGetResponse_Status::UNKNOWN_BLOCK {
        //     Err(Error::UnknownBlock("Block not found".into()))
        // } else {
        //     check_ok!(response, ConsensusBlocksGetResponse_Status::OK)
        // }?;
        if response.status == .unknownBlock {
            throw ConsensusError.UnknownBlock("Block not found")
        }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
        //
        // Ok(response
        //     .take_blocks()
        //     .into_iter()
        //     .map(|block| (block.block_id.clone(), Block::from(block)))
        //     .collect())
        let pairs = response.blocks.map({ (consensusBlock) -> (BlockId, EngineBlock) in
            (BlockId(consensusBlock.blockID), EngineBlock.from(consensusBlock: consensusBlock))
        })
        return Dictionary<BlockId,EngineBlock>(uniqueKeysWithValues: pairs)
    }
    // }
    //
    // fn get_chain_head(&mut self) -> Result<Block, Error> {
    public func getChainHead() throws -> EngineBlock {
        // let request = ConsensusChainHeadGetRequest::new();
        let request = ConsensusChainHeadGetRequest()
        //
        // let mut response: ConsensusChainHeadGetResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_CHAIN_HEAD_GET_REQUEST,
        //     Message_MessageType::CONSENSUS_CHAIN_HEAD_GET_RESPONSE,
        // )?;
        let response: ConsensusChainHeadGetResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusChainHeadGetRequest,
            responseType: Message.MessageType.consensusChainHeadGetResponse
        )
        //
        // if response.get_status() == ConsensusChainHeadGetResponse_Status::NO_CHAIN_HEAD {
        //     Err(Error::NoChainHead)
        // } else {
        //     check_ok!(response, ConsensusChainHeadGetResponse_Status::OK)
        // }?;
        if response.status == .noChainHead {
            throw ConsensusError.NoChainHead
        }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
        //
        // Ok(Block::from(response.take_block()))
        return EngineBlock.from(consensusBlock: response.block)
    }
    // }
    //
    // fn get_settings(
    //     &mut self,
    //     block_id: BlockId,
    //     keys: Vec<String>,
    // ) -> Result<HashMap<String, String>, Error> {
    public func getSettings(blockID: BlockId, keys: [String]) throws -> Dictionary<String, String> {
        // let mut request = ConsensusSettingsGetRequest::new();
        var request = ConsensusSettingsGetRequest()
        // request.set_block_id(block_id);
        // request.set_keys(protobuf::RepeatedField::from_vec(keys));
        request.blockID = Data(blockID)
        request.keys = keys
        //
        // let mut response: ConsensusSettingsGetResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_SETTINGS_GET_REQUEST,
        //     Message_MessageType::CONSENSUS_SETTINGS_GET_RESPONSE,
        // )?;
        let response: ConsensusSettingsGetResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusSettingsGetRequest,
            responseType: Message.MessageType.consensusSettingsGetResponse
        )
        //
        // if response.get_status() == ConsensusSettingsGetResponse_Status::UNKNOWN_BLOCK {
        //     Err(Error::UnknownBlock("Block not found".into()))
        // } else {
        //     check_ok!(response, ConsensusSettingsGetResponse_Status::OK)
        // }?;
        if response.status == .unknownBlock {
            throw ConsensusError.UnknownBlock("Block not found")
        }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
        //
        // Ok(response
        //     .take_entries()
        //     .into_iter()
        //     .map(|mut entry| (entry.take_key(), entry.take_value()))
        //     .collect())
        let pairs = response.entries.map { (entry) -> (String, String) in
            (entry.key, entry.value)
        }
        return Dictionary(uniqueKeysWithValues: pairs)
    }
    // }
    //
    // fn get_state(
    //     &mut self,
    //     block_id: BlockId,
    //     addresses: Vec<String>,
    // ) -> Result<HashMap<String, Vec<u8>>, Error> {
    public func getState(blockID: BlockId, addresses: [String]) throws -> Dictionary<String, [UInt8]> {
        // let mut request = ConsensusStateGetRequest::new();
        var request = ConsensusStateGetRequest()
        // request.set_block_id(block_id);
        request.blockID = Data(blockID)
        // request.set_addresses(protobuf::RepeatedField::from_vec(addresses));
        request.addresses = addresses
        //
        // let mut response: ConsensusStateGetResponse = self.rpc(
        //     &request,
        //     Message_MessageType::CONSENSUS_STATE_GET_REQUEST,
        //     Message_MessageType::CONSENSUS_STATE_GET_RESPONSE,
        // )?;
        let response: ConsensusStateGetResponse = try self.rpc(
            request: request,
            requestType: Message.MessageType.consensusStateGetRequest,
            responseType: Message.MessageType.consensusStateGetResponse
        )
        //
        // if response.get_status() == ConsensusStateGetResponse_Status::UNKNOWN_BLOCK {
        //     Err(Error::UnknownBlock("Block not found".into()))
        // } else {
        //     check_ok!(response, ConsensusStateGetResponse_Status::OK)
        // }?;
        if response.status == .unknownBlock {
            throw ConsensusError.UnknownBlock("Block not found")
        }
        else if response.status != .ok {
            throw ConsensusError.ReceiveError("Failed with status \(response.status)")
        }
        //
        // Ok(response
        //     .take_entries()
        //     .into_iter()
        //     .map(|mut entry| (entry.take_address(), entry.take_data()))
        //     .collect())
        let pairs = response.entries.map { (entry) -> (String, [UInt8]) in
            (entry.address, [UInt8](entry.data))
        }
        return Dictionary(uniqueKeysWithValues: pairs)
    }
    // }
}
// }
//
// #[cfg(test)]
// mod tests {
//     use super::*;
//     use messages::validator::Message;
//     use messaging::stream::MessageConnection;
//     use messaging::zmq_stream::ZmqMessageConnection;
//     use protobuf::Message as ProtobufMessage;
//     use std::default::Default;
//     use std::thread;
//     use zmq;
//
//     fn recv_rep<I: protobuf::Message, O: protobuf::Message>(
//         socket: &zmq::Socket,
//         request_type: Message_MessageType,
//         response: I,
//         response_type: Message_MessageType,
//     ) -> (Vec<u8>, O) {
//         let mut parts = socket.recv_multipart(0).unwrap();
//         assert!(parts.len() == 2);
//
//         let mut msg: Message = protobuf::parse_from_bytes(&parts.pop().unwrap()).unwrap();
//         let connection_id = parts.pop().unwrap();
//         assert!(msg.get_message_type() == request_type);
//         let request: O = protobuf::parse_from_bytes(&msg.get_content()).unwrap();
//
//         let correlation_id = msg.take_correlation_id();
//         let mut msg = Message::new();
//         msg.set_message_type(response_type);
//         msg.set_correlation_id(correlation_id);
//         msg.set_content(response.write_to_bytes().unwrap());
//         socket
//             .send_multipart(&[&connection_id, &msg.write_to_bytes().unwrap()], 0)
//             .unwrap();
//
//         (connection_id, request)
//     }
//
//     macro_rules! service_test {
//         (
//             $socket:expr,
//             $rep:expr,
//             $status:expr,
//             $rep_msg_type:expr,
//             $req_type:ty,
//             $req_msg_type:expr
//         ) => {
//             let mut response = $rep;
//             response.set_status($status);
//             let (_, _): (_, $req_type) = recv_rep($socket, $req_msg_type, response, $rep_msg_type);
//         };
//     }
//
//     #[test]
//     fn test_zmq_service() {
//         let ctx = zmq::Context::new();
//         let socket = ctx.socket(zmq::ROUTER).expect("Failed to create context");
//         socket
//             .bind("tcp://127.0.0.1:*")
//             .expect("Failed to bind socket");
//         let addr = socket.get_last_endpoint().unwrap().unwrap();
//
//         let svc_thread = thread::spawn(move || {
//             let connection = ZmqMessageConnection::new(&addr);
//             let (sender, _) = connection.create();
//             let mut svc = ZmqService::new(sender, Duration::from_secs(10));
//
//             svc.send_to(&Default::default(), Default::default(), Default::default())
//                 .unwrap();
//             svc.broadcast(Default::default(), Default::default())
//                 .unwrap();
//
//             svc.initialize_block(Some(Default::default())).unwrap();
//             svc.summarize_block().unwrap();
//             svc.finalize_block(Default::default()).unwrap();
//             svc.cancel_block().unwrap();
//
//             svc.check_blocks(Default::default()).unwrap();
//             svc.commit_block(Default::default()).unwrap();
//             svc.ignore_block(Default::default()).unwrap();
//             svc.fail_block(Default::default()).unwrap();
//
//             svc.get_blocks(Default::default()).unwrap();
//             svc.get_settings(Default::default(), Default::default())
//                 .unwrap();
//             svc.get_state(Default::default(), Default::default())
//                 .unwrap();
//             svc.get_chain_head().unwrap();
//         });
//
//         service_test!(
//             &socket,
//             ConsensusSendToResponse::new(),
//             ConsensusSendToResponse_Status::OK,
//             Message_MessageType::CONSENSUS_SEND_TO_RESPONSE,
//             ConsensusSendToRequest,
//             Message_MessageType::CONSENSUS_SEND_TO_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusBroadcastResponse::new(),
//             ConsensusBroadcastResponse_Status::OK,
//             Message_MessageType::CONSENSUS_BROADCAST_RESPONSE,
//             ConsensusBroadcastRequest,
//             Message_MessageType::CONSENSUS_BROADCAST_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusInitializeBlockResponse::new(),
//             ConsensusInitializeBlockResponse_Status::OK,
//             Message_MessageType::CONSENSUS_INITIALIZE_BLOCK_RESPONSE,
//             ConsensusInitializeBlockRequest,
//             Message_MessageType::CONSENSUS_INITIALIZE_BLOCK_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusSummarizeBlockResponse::new(),
//             ConsensusSummarizeBlockResponse_Status::OK,
//             Message_MessageType::CONSENSUS_SUMMARIZE_BLOCK_RESPONSE,
//             ConsensusSummarizeBlockRequest,
//             Message_MessageType::CONSENSUS_SUMMARIZE_BLOCK_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusFinalizeBlockResponse::new(),
//             ConsensusFinalizeBlockResponse_Status::OK,
//             Message_MessageType::CONSENSUS_FINALIZE_BLOCK_RESPONSE,
//             ConsensusFinalizeBlockRequest,
//             Message_MessageType::CONSENSUS_FINALIZE_BLOCK_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusCancelBlockResponse::new(),
//             ConsensusCancelBlockResponse_Status::OK,
//             Message_MessageType::CONSENSUS_CANCEL_BLOCK_RESPONSE,
//             ConsensusCancelBlockRequest,
//             Message_MessageType::CONSENSUS_CANCEL_BLOCK_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusCheckBlocksResponse::new(),
//             ConsensusCheckBlocksResponse_Status::OK,
//             Message_MessageType::CONSENSUS_CHECK_BLOCKS_RESPONSE,
//             ConsensusCheckBlocksRequest,
//             Message_MessageType::CONSENSUS_CHECK_BLOCKS_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusCommitBlockResponse::new(),
//             ConsensusCommitBlockResponse_Status::OK,
//             Message_MessageType::CONSENSUS_COMMIT_BLOCK_RESPONSE,
//             ConsensusCommitBlockRequest,
//             Message_MessageType::CONSENSUS_COMMIT_BLOCK_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusIgnoreBlockResponse::new(),
//             ConsensusIgnoreBlockResponse_Status::OK,
//             Message_MessageType::CONSENSUS_IGNORE_BLOCK_RESPONSE,
//             ConsensusIgnoreBlockRequest,
//             Message_MessageType::CONSENSUS_IGNORE_BLOCK_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusFailBlockResponse::new(),
//             ConsensusFailBlockResponse_Status::OK,
//             Message_MessageType::CONSENSUS_FAIL_BLOCK_RESPONSE,
//             ConsensusFailBlockRequest,
//             Message_MessageType::CONSENSUS_FAIL_BLOCK_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusBlocksGetResponse::new(),
//             ConsensusBlocksGetResponse_Status::OK,
//             Message_MessageType::CONSENSUS_BLOCKS_GET_RESPONSE,
//             ConsensusBlocksGetRequest,
//             Message_MessageType::CONSENSUS_BLOCKS_GET_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusSettingsGetResponse::new(),
//             ConsensusSettingsGetResponse_Status::OK,
//             Message_MessageType::CONSENSUS_SETTINGS_GET_RESPONSE,
//             ConsensusSettingsGetRequest,
//             Message_MessageType::CONSENSUS_SETTINGS_GET_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusStateGetResponse::new(),
//             ConsensusStateGetResponse_Status::OK,
//             Message_MessageType::CONSENSUS_STATE_GET_RESPONSE,
//             ConsensusStateGetRequest,
//             Message_MessageType::CONSENSUS_STATE_GET_REQUEST
//         );
//
//         service_test!(
//             &socket,
//             ConsensusChainHeadGetResponse::new(),
//             ConsensusChainHeadGetResponse_Status::OK,
//             Message_MessageType::CONSENSUS_CHAIN_HEAD_GET_RESPONSE,
//             ConsensusChainHeadGetRequest,
//             Message_MessageType::CONSENSUS_CHAIN_HEAD_GET_REQUEST
//         );
//
//         svc_thread.join().unwrap();
//     }
// }
