//
//  ZMQDriver.swift
//  sawtooth-sdk-swift
//
//  Created by Teaching on 8/7/19.
//

import Foundation
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
// use protobuf::{Message as ProtobufMessage, ProtobufError, RepeatedField};
// use rand;
// use rand::Rng;
//
// use consensus::engine::*;
// use consensus::zmq_service::ZmqService;
//
// use messaging::stream::MessageConnection;
// use messaging::stream::MessageSender;
// use messaging::stream::ReceiveError;
// use messaging::stream::SendError;
// use messaging::zmq_stream::{ZmqMessageConnection, ZmqMessageSender};
//
// use messages::consensus::*;
// use messages::validator::{Message, Message_MessageType};
import SawtoothProtoSwift
//
// use std::sync::mpsc::{self, channel, Receiver, RecvTimeoutError, Sender};
import MPSCSwift
// use std::thread;
// use std::time::Duration;
public typealias Duration = UInt32
typealias EmptyTuple = ()
//
// const REGISTER_TIMEOUT: u64 = 300;
let REGISTER_TIMEOUT: Duration = 300
// const SERVICE_TIMEOUT: u64 = 300;
let SERVICE_TIMEOUT: Duration = 300
// const INITAL_RETRY_DELAY: Duration = Duration::from_millis(100);
let INITIAL_RETRY_DELAY: Duration = 100
// const MAX_RETRY_DELAY: Duration = Duration::from_secs(3);
let MAX_RETRY_DELAY: Duration = 3 * 1000
//
// /// Generates a random correlation id for use in Message
// fn generate_correlation_id() -> String {
func generateCorrelationID() -> String {
    // const LENGTH: usize = 16;
    let LENGTH = 16
    // rand::thread_rng().gen_ascii_chars().take(LENGTH).collect()
    var p = Array<UInt8>(repeating: 0, count: LENGTH)
    for i in 0..<LENGTH {
        p[i] = UInt8((32..<128).randomElement()!)
    }
    return String(bytes: p, encoding: .utf8)!
}
// }
//
// pub struct ZmqDriver {
public class ZmqDriver {
    // stop_receiver: Receiver<()>,
    var stopReceiver: Receiver<()>
// }
//
// impl ZmqDriver {
    // /// Create a new ZMQ-based Consensus Engine driver and a handle for stopping it
    // pub fn new() -> (Self, Stop) {
    init (stopReceiver: Receiver<()>) {
        self.stopReceiver = stopReceiver
    }
    public static func new() -> (ZmqDriver, Stop) {
        // let (stop_sender, stop_receiver) = channel();
        let (stopSender, stopReceiver) = channel(channelType: EmptyTuple.self)
        // let stop = Stop {
        //     sender: stop_sender,
        // };
        let stop = Stop(sender: stopSender)
        // let driver = ZmqDriver { stop_receiver };
        let driver = ZmqDriver(stopReceiver: stopReceiver)
        // (driver, stop)
        return (driver, stop)
    }
    // }
    //
    // /// Start the driver with the given engine, consuming both
    // ///
    // /// The engine's start method will be run from the current thread and this method should block
    // /// until the engine shutsdown.
    // pub fn start<T: AsRef<str>, E: Engine>(self, endpoint: T, mut engine: E) -> Result<(), Error> {
    public func start<T: StringProtocol, E: Engine>(endpoint: T, engine: inout E) throws {
        // let validator_connection = ZmqMessageConnection::new(endpoint.as_ref());
        let validatorConnection = ZmqMessageConnection(address: endpoint as! String)
        // let (mut validator_sender, validator_receiver) = validator_connection.create();
        let (validatorSender, validatorReceiver) = validatorConnection.create()
        //
        // let validator_sender_clone = validator_sender.clone();
        // let (update_sender, update_receiver) = channel();
        let (updateSender, updateReceiver) = channel(channelType: Update.self)
        //+print("DBG_PRINT: updateSender queueID = \(updateSender.queueID)")
        //+print("DBG_PRINT: updateReceiver queueID = \(updateReceiver.queueID)")
        //
        // // Validators version 1.1 send startup info with the registration response; newer versions
        // // will send an activation message with the startup info
        
        // let startup_state = match register(
        
        let startupState = try register(
            // &mut validator_sender,
            sender: validatorSender,
            // Duration::from_secs(REGISTER_TIMEOUT),
            timeout: Duration(REGISTER_TIMEOUT),
            // engine.name(),
            name: engine.name,
            // engine.version(),
            version: engine.version,
            // engine.additional_protocols(),
            additionalProtocols: engine.additionalProtocols
            ) ?? waitUntilActive(validatorSender: validatorSender, validatorReceiver: validatorReceiver)
        // )? {
        //     Some(state) => state,
        //     None => wait_until_active(&validator_sender, &validator_receiver)?,
        // };
        //
        // let driver_thread = thread::spawn(move || {
        let group = DispatchGroup()
        group.enter()
        var driverLoopReturn: Result<EmptyTuple, Error> = .success(())
        DispatchQueue.global(qos: .background).async {
            // driver_loop(
            driverLoopReturn = Result {
                try driverLoop(
                    // update_sender,
                    updateSender: updateSender,
                    // &self.stop_receiver,
                    stopReceiver: self.stopReceiver,
                    // validator_sender,
                    validatorSender: validatorSender,
                    // &validator_receiver,
                    validatorReceiver: validatorReceiver
                )
            }
            // )
            group.leave()
        }
        // });
        //
        // engine.start(
        try engine.start(
            // update_receiver,
            updates: updateReceiver,
            // Box::new(ZmqService::new(
            //     validator_sender_clone,
            //     Duration::from_secs(SERVICE_TIMEOUT),
            // )),
            service: ZmqService(sender: validatorSender, timeout: Duration(SERVICE_TIMEOUT)),
            // startup_state,
            startupState: startupState)
        // )?;
        //
        // driver_thread.join().expect("Driver panicked")
        group.wait()
        if case .failure(let driverLoopError) = driverLoopReturn {
            if driverLoopError.localizedDescription == "Driver panicked" {
                return
            }
        }
    }
    // }
}
// }
//
// /// Utility class for signaling that the driver should be shutdown
// #[derive(Clone)]
// pub struct Stop {
public class Stop {
    // sender: Sender<()>,
    let sender: Sender<()>
    
    internal init(sender: Sender<()>) {
        self.sender = sender
    }
}
// }
//
// impl Stop {
extension Stop {
    // pub fn stop(&self) {
    public func stop() throws {
        // self.sender
        //     .send(())
        //     .unwrap_or_else(|err| error!("Failed to send stop signal: {:?}", err));
        try Result { try sender.send(t: ()) }.mapError { (error) -> Error in
            ConsensusError.SendError("Failed to send stop signal: \(error)")
        }.get()
    }
    // }
}
// }
//
// fn driver_loop(
func driverLoop(
    // mut update_sender: Sender<Update>,
    updateSender: Sender<Update>,
    // stop_receiver: &Receiver<()>,
    stopReceiver: Receiver<()>,
    // mut validator_sender: ZmqMessageSender,
    validatorSender: ZmqMessageSender,
    // validator_receiver: &Receiver<Result<Message, ReceiveError>>,
    validatorReceiver: Receiver<Result<Message, ReceiveError>>
)
// ) -> Result<(), Error> {
throws {
    // loop {
    repeat {
        // match validator_receiver.recv_timeout(Duration::from_millis(100)) {
        switch (validatorReceiver.recvTimeout(timeout: Duration(100))) {
        case .failure(let failureType):
            // Err(RecvTimeoutError::Timeout) => {
            switch failureType {
            case .Timeout:
                // if stop_receiver.try_recv().is_ok() {
                if (try? stopReceiver.tryRecv()) != nil {
                    // update_sender.send(Update::Shutdown)?;
                    try updateSender.send(t: Update.Shutdown)
                    return
                }
                // }
                // }
            // Err(RecvTimeoutError::Disconnected) => {
            case .Disconnected:
                // break Err(Error::ReceiveError("Sender disconnected".into()));
                throw ConsensusError.ReceiveError("Sender disconnected")
            // }
            }
            // Ok(Err(err)) => {
        case .success(let result):
            switch result {
            case .failure(let error):
                // break Err(Error::ReceiveError(format!(
                //     "Unexpected error while receiving: {}",
                //     err
                //     )));
                throw ConsensusError.ReceiveError("Unexpected error while receiving: \(error).")
                // }
            // Ok(Ok(msg)) => {
            case .success(let msg):
                // if let Err(err) = handle_update(&msg, &mut validator_sender, &mut update_sender) {
                try handleUpdate(msg: msg, validatorSender: validatorSender, updateSender: updateSender)
                // }
                // if stop_receiver.try_recv().is_ok() {
                if (try? stopReceiver.tryRecv()) != nil {
                    //     update_sender.send(Update::Shutdown)?;
                    try updateSender.send(t: Update.Shutdown)
                    return
                }
                // }
            }
            // }
        }
        // }
    } while true
    // }
}
// }
//
// pub fn register(
public func register(
    // sender: &mut MessageSender,
    sender: MessageSender,
    // timeout: Duration,
    timeout: Duration,
    // name: String,
    name: String,
    // version: String,
    version: String,
    // additional_protocols: Vec<(String, String)>,
    additionalProtocols: [(String, String)]
// ) -> Result<Option<StartupState>, Error> {
) throws -> StartupState? {
    //+print("DBG_PRINT In ZmqDriver register.")
    // let mut request = ConsensusRegisterRequest::new();
    var request = ConsensusRegisterRequest()
    // request.set_name(name);
    request.name = name
    // request.set_version(version);
    request.version = version
    // request.set_additional_protocols(RepeatedField::from(protocols_from_tuples(
    //     additional_protocols,
    // )));
    request.additionalProtocols = protocolsFromTuples(protocols: additionalProtocols)
    // let request = request.write_to_bytes()?;
    let requestData = try request.serializedData()
    //
    // let mut msg = sender
    //     .send(
    //         Message_MessageType::CONSENSUS_REGISTER_REQUEST,
    //         &generate_correlation_id(),
    //         &request,
    //     )?
    //     .get_timeout(timeout)?;
    var senderResponse = try sender.send(
        destination: .consensusRegisterRequest,
        correlationID: generateCorrelationID(),
        contents: requestData)
    var msg = try (senderResponse.getTimeout(timeout: timeout).get())
    //
    // let ret: Result<Option<StartupState>, Error>;
    //
    // // Keep trying to register until the response is something other
    // // than NOT_READY.
    //
    // let mut retry_delay = INITAL_RETRY_DELAY;
    var retryDelay = INITIAL_RETRY_DELAY
    // loop {
    repeat {
        // match msg.get_message_type() {
        switch msg.messageType {
            // Message_MessageType::CONSENSUS_REGISTER_RESPONSE => {
        case .consensusRegisterResponse:
            // let mut response: ConsensusRegisterResponse =
            //     protobuf::parse_from_bytes(msg.get_content())?;
            var response = try ConsensusRegisterResponse(serializedData: msg.content)
            //
            // match response.get_status() {
            switch response.status {
            // ConsensusRegisterResponse_Status::OK => {
            case .ok:
                // ret = if response.chain_head.is_some() && response.local_peer_info.is_some()
                // {
                if response.hasChainHead && response.hasLocalPeerInfo {
                    //     Ok(Some(StartupState {
                    return StartupState(
                        // chain_head: response.take_chain_head().into(),
                        chainHead: EngineBlock.from(consensusBlock: response.chainHead),
                        // peers: response
                        //     .take_peers()
                        //     .into_iter()
                        //     .map(|info| info.into())
                        //     .collect(),
                        peers: response.peers.map({ (consensusPeerInfo) -> PeerInfo in
                            PeerInfo(peerID: PeerId(consensusPeerInfo.peerID))
                        }),
                        // local_peer_info: response.take_local_peer_info().into(),
                        localPeerInfo: PeerInfo(peerID: PeerId(response.localPeerInfo.peerID))
                    )
                }
                //     }))
                // } else {
                else {
                    // Ok(None)
                    return nil
                }
            // };
            //
            // break;
            // }
            // ConsensusRegisterResponse_Status::NOT_READY => {
            case .notReady:
                // TODO: Handle not ready
                // thread::sleep(retry_delay);
                sleep(retryDelay)
                // if retry_delay < MAX_RETRY_DELAY {
                if retryDelay < MAX_RETRY_DELAY {
                    // retry_delay *= 2;
                    retryDelay *= 2
                    // if retry_delay > MAX_RETRY_DELAY {
                    if retryDelay > MAX_RETRY_DELAY {
                        // retry_delay = MAX_RETRY_DELAY;
                        retryDelay = MAX_RETRY_DELAY
                    }
                    // }
                }
                // }
                // msg = sender
                //     .send(
                senderResponse = try sender.send(
                    // Message_MessageType::CONSENSUS_REGISTER_REQUEST,
                    destination: .consensusRegisterRequest,
                    // &generate_correlation_id(),
                    correlationID: generateCorrelationID(),
                    // &request,
                    contents: requestData
                )
                //     )?
                //     .get_timeout(timeout)?;
                msg = try senderResponse.getTimeout(timeout: timeout).get()
                //
                // continue;
                continue
                // }
            // status => {
            default:
                // ret = Err(Error::ReceiveError(format!(
                //     "Registration failed with status {:?}",
                //     status
                // )));
                throw ConsensusError.ReceiveError("Registration failed with status \(response.status)")
                //
                // break;
                // }
            }
            // };
        // }
        // unexpected => {
        default:
            //     ret = Err(Error::ReceiveError(format!(
            //         "Received unexpected message type: {:?}",
            //         unexpected
            //     )));
            throw ConsensusError.ReceiveError("Received unexpected message type \(msg.messageType)")
            //
            //     break;
            // }
        }
        // }
    } while true
    // }
    //
    // ret
}
// }
//
// fn wait_until_active(
func waitUntilActive(
    // validator_sender: &ZmqMessageSender,
    validatorSender: ZmqMessageSender,
    // validator_receiver: &Receiver<Result<Message, ReceiveError>>,
    validatorReceiver: Receiver<Result<Message, ReceiveError>>
)
// ) -> Result<StartupState, Error> {
throws -> StartupState {
    // use self::Message_MessageType::*;
    //
    // let ret: Result<StartupState, Error>;
    //
    // loop {
    repeat {
        print("DGB_PRINT Cycling in waitUntilActive")
        // match validator_receiver.recv_timeout(Duration::from_millis(100)) {
        switch validatorReceiver.recvTimeout(timeout: 1000) {
        // Err(RecvTimeoutError::Timeout) => {}
        case .failure(RecvTimeoutError.Timeout):
            //+print("DBG_PRINT: waitUntilActive received timeout error.")
            continue
        // Err(RecvTimeoutError::Disconnected) => {
        case .failure(RecvTimeoutError.Disconnected):
            // ret = Err(Error::ReceiveError("Sender disconnected".into()));
            throw ConsensusError.ReceiveError("Sender disconnected")
            // break;
            // }
            // Ok(Err(err)) => {
        case .success(.failure(let err)):
            // ret = Err(Error::ReceiveError(format!(
            //     "Unexpected error while receiving: {}",
            //     err
            // )));
            throw ConsensusError.ReceiveError("Unexpected error while receiving: \(err)")
            // break;
            // }
            // Ok(Ok(msg)) => {
        case .success(.success(let msg)):
            //+print("DBG_PRINT: waitUntilActive received message successfully.")
            // if let CONSENSUS_NOTIFY_ENGINE_ACTIVATED = msg.get_message_type() {
            if case .consensusNotifyEngineActivated = msg.messageType {
                // let mut content: ConsensusNotifyEngineActivated =
                //     protobuf::parse_from_bytes(msg.get_content())?;
                var content = try ConsensusNotifyEngineActivated(serializedData: msg.content)
                //
                // ret = Ok(StartupState {
                //     chain_head: content.take_chain_head().into(),
                //     peers: content
                //         .take_peers()
                //         .into_iter()
                //         .map(|info| info.into())
                //         .collect(),
                //     local_peer_info: content.take_local_peer_info().into(),
                // });
                let startupState = StartupState(
                    chainHead: EngineBlock.from(consensusBlock: content.chainHead),
                    peers: content.peers.map({ (peer) -> PeerInfo in
                        PeerInfo(peerID: PeerId(peer.peerID))
                    }),
                    localPeerInfo: PeerInfo(peerID: PeerId(content.localPeerInfo.peerID))
                )
                //
                // validator_sender.reply(
                //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
                //     msg.get_correlation_id(),
                //     &[],
                // )?;
                try validatorSender.reply(
                    destination: .consensusNotifyAck,
                    correlationID: msg.correlationID,
                    contents: Data()
                )
                return startupState
                //
                // break;
            }
            // }
            // }
        }
        // }
    } while true
    // }
    //
    // ret
}
// }
//
// fn handle_update(
func handleUpdate(
    // msg: &Message,
    msg: Message,
    // validator_sender: &mut MessageSender,
    validatorSender: MessageSender,
    // update_sender: &mut Sender<Update>,
    updateSender: Sender<Update>
)
// ) -> Result<(), Error> {
throws {
    // use self::Message_MessageType::*;
    //
    // let update = match msg.get_message_type() {
    let update:Update
    switch (msg.messageType) {
        // CONSENSUS_NOTIFY_PEER_CONNECTED => {
    case .consensusNotifyPeerConnected:
        // let mut request: ConsensusNotifyPeerConnected =
        //     protobuf::parse_from_bytes(msg.get_content())?;
        let request = try ConsensusNotifyPeerConnected(serializedData: msg.content)
        // Update::PeerConnected(request.take_peer_info().into())
        update = Update.PeerConnected(PeerInfo(peerID: PeerId(request.peerInfo.peerID)))
        // }
        // CONSENSUS_NOTIFY_PEER_DISCONNECTED => {
    case .consensusNotifyPeerDisconnected:
        // let mut request: ConsensusNotifyPeerDisconnected =
        //     protobuf::parse_from_bytes(msg.get_content())?;
        let request = try ConsensusNotifyPeerDisconnected(serializedData: msg.content)
        // Update::PeerDisconnected(request.take_peer_id())
        update = Update.PeerDisconnected(PeerId(request.peerID))
        // }
        // CONSENSUS_NOTIFY_PEER_MESSAGE => {
    case .consensusNotifyPeerMessage:
        // let mut request: ConsensusNotifyPeerMessage =
        //     protobuf::parse_from_bytes(msg.get_content())?;
        let request = try ConsensusNotifyPeerMessage(serializedData: msg.content)
        // let mut header: ConsensusPeerMessageHeader =
        //     protobuf::parse_from_bytes(request.get_message().get_header())?;
        let header = try ConsensusPeerMessageHeader(serializedData: request.message.header)
        // let mut message = request.take_message();
        let message = request.message
        // Update::PeerMessage(
        //     from_consensus_peer_message(message, header),
        //     request.take_sender_id(),
        // )
        update = .PeerMessage(PeerMessage.from(
            consensusPeerMessage: message, consensusPeerMessageHeader: header), PeerId(request.senderID))
        // }
        // CONSENSUS_NOTIFY_BLOCK_NEW => {
    case .consensusNotifyBlockNew:
        // let mut request: ConsensusNotifyBlockNew =
        //     protobuf::parse_from_bytes(msg.get_content())?;
        let request = try ConsensusNotifyBlockNew(serializedData: msg.content)
        // Update::BlockNew(request.take_block().into())
        update = .BlockNew(EngineBlock.from(consensusBlock: request.block))
        // }
        // CONSENSUS_NOTIFY_BLOCK_VALID => {
    case .consensusNotifyBlockValid:
        // let mut request: ConsensusNotifyBlockValid =
        //     protobuf::parse_from_bytes(msg.get_content())?;
        let request = try ConsensusNotifyBlockValid(serializedData: msg.content)
        // Update::BlockValid(request.take_block_id())
        update = .BlockValid(BlockId(request.blockID))
        // }
        // CONSENSUS_NOTIFY_BLOCK_INVALID => {
    case .consensusNotifyBlockInvalid:
        // let mut request: ConsensusNotifyBlockInvalid =
        //     protobuf::parse_from_bytes(msg.get_content())?;
        let request = try ConsensusNotifyBlockInvalid(serializedData: msg.content)
        // Update::BlockInvalid(request.take_block_id())
        update = .BlockInvalid(BlockId(request.blockID))
        // }
        // CONSENSUS_NOTIFY_BLOCK_COMMIT => {
    case .consensusNotifyBlockCommit:
        // let mut request: ConsensusNotifyBlockCommit =
        //     protobuf::parse_from_bytes(msg.get_content())?;
        let request = try ConsensusNotifyBlockCommit(serializedData: msg.content)
        // Update::BlockCommit(request.take_block_id())
        update = .BlockCommit(BlockId(request.blockID))
        // }
        // CONSENSUS_NOTIFY_ENGINE_DEACTIVATED => Update::Shutdown,
    case .consensusNotifyEngineDeactivated:
        update = .Shutdown
        // unexpected => {
    default:
        // warn!(
        //     "Received unexpected message type: {:?}; ignoring",
        //     unexpected
        // );
        print("Received unexpected message type \(msg.messageType); ignoring")
        return
        // return Ok(());
        // }
    }
    // };
    //
    // update_sender.send(update)?;
    try updateSender.send(t: update)
    // validator_sender.reply(
    //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
    //     msg.get_correlation_id(),
    //     &[],
    // )?;
    try validatorSender.reply(
        destination: .consensusNotifyAck,
        correlationID: msg.correlationID,
        contents: Data())
    // Ok(())
}
// }
//
// fn protocols_from_tuples(
//     protocols: Vec<(String, String)>,
// ) -> Vec<ConsensusRegisterRequest_Protocol> {
func protocolsFromTuples(
    protocols: [(String, String)]
    ) -> [ConsensusRegisterRequest.ProtocolMessage] {
    // protocols
    //     .iter()
    //     .map(|(p_name, p_version)| {
    //         let mut protocol = ConsensusRegisterRequest_Protocol::new();
    //         protocol.set_name(p_name.to_string());
    //         protocol.set_version(p_version.to_string());
    //         protocol
    //     })
    //     .collect::<Vec<_>>()
    return protocols
        .map({ (protocolPair) -> ConsensusRegisterRequest.ProtocolMessage in
            let (name, version) = protocolPair
            var protocolMessage = ConsensusRegisterRequest.ProtocolMessage()
            protocolMessage.name = name
            protocolMessage.version = version
            return protocolMessage
        })
}
// }
//
// impl From<ConsensusBlock> for Block {
extension EngineBlock {
    // fn from(mut c_block: ConsensusBlock) -> Block {
    static func from(consensusBlock: ConsensusBlock) -> EngineBlock {
    // Block {
        return EngineBlock(
            // block_id: c_block.take_block_id(),
            blockID: BlockId(consensusBlock.blockID),
            // previous_id: c_block.take_previous_id(),
            previousBlockID: BlockId(consensusBlock.previousID),
            // signer_id: c_block.take_signer_id(),
            signerID: PeerId(consensusBlock.signerID),
            // block_num: c_block.get_block_num(),
            blockNum: consensusBlock.blockNum,
            // payload: c_block.take_payload(),
            payload: [UInt8](consensusBlock.payload),
            // summary: c_block.take_summary(),
            summary: [UInt8](consensusBlock.summary)
        )
    // }
    }
    // }
}
// }
//
// impl From<ConsensusPeerInfo> for PeerInfo {
//     fn from(mut c_peer_info: ConsensusPeerInfo) -> PeerInfo {
//         PeerInfo {
//             peer_id: c_peer_info.take_peer_id(),
//         }
//     }
// }
//
extension PeerMessage {
    // fn from_consensus_peer_message(
    // ) -> PeerMessage {
    static func from(
        // mut c_msg: ConsensusPeerMessage,
        consensusPeerMessage: ConsensusPeerMessage,
        // mut c_msg_header: ConsensusPeerMessageHeader,
        consensusPeerMessageHeader: ConsensusPeerMessageHeader
        ) -> PeerMessage {
        // PeerMessage {
        return PeerMessage(
            // header: PeerMessageHeader {
            header: PeerMessageHeader(
                // signer_id: c_msg_header.take_signer_id(),
                signerID: [UInt8](consensusPeerMessageHeader.signerID),
                // content_sha512: c_msg_header.take_content_sha512(),
                contentSHA512: [UInt8](consensusPeerMessageHeader.contentSha512),
                // message_type: c_msg_header.take_message_type(),
                messageType: consensusPeerMessageHeader.messageType,
                // name: c_msg_header.take_name(),
                name: consensusPeerMessageHeader.name,
                // version: c_msg_header.take_version(),
                version: consensusPeerMessageHeader.version
            ),
            // },
            // header_bytes: c_msg.take_header(),
            headerBytes: [UInt8](consensusPeerMessage.header),
            // header_signature: c_msg.take_header_signature(),
            headerSignature: [UInt8](consensusPeerMessage.headerSignature),
            // content: c_msg.take_content(),
            content: [UInt8](consensusPeerMessage.content)
        )
        // }
    }
    // }
}
//
// impl From<ProtobufError> for Error {
//     fn from(error: ProtobufError) -> Error {
//         use self::ProtobufError::*;
//         match error {
//             IoError(err) => Error::EncodingError(format!("{}", err)),
//             WireError(err) => Error::EncodingError(format!("{:?}", err)),
//             Utf8(err) => Error::EncodingError(format!("{}", err)),
//             MessageNotInitialized { message: err } => Error::EncodingError(err.to_string()),
//         }
//     }
// }
//
// impl From<SendError> for Error {
//     fn from(error: SendError) -> Error {
//         Error::SendError(format!("{}", error))
//     }
// }
//
// impl From<mpsc::SendError<Update>> for Error {
//     fn from(error: mpsc::SendError<Update>) -> Error {
//         Error::SendError(format!("{}", error))
//     }
// }
//
// impl From<ReceiveError> for Error {
//     fn from(error: ReceiveError) -> Error {
//         Error::ReceiveError(format!("{}", error))
//     }
// }
//
// #[cfg(test)]
// mod tests {
//     use super::*;
//     use consensus::engine::tests::MockEngine;
//     use std::sync::{Arc, Mutex};
//     use zmq;
//
//     fn send_req_rep<I: protobuf::Message, O: protobuf::Message>(
//         connection_id: &[u8],
//         socket: &zmq::Socket,
//         request: I,
//         request_type: Message_MessageType,
//         response_type: Message_MessageType,
//     ) -> O {
//         let correlation_id = generate_correlation_id();
//         let mut msg = Message::new();
//         msg.set_message_type(request_type);
//         msg.set_correlation_id(correlation_id.clone());
//         msg.set_content(request.write_to_bytes().unwrap());
//         socket
//             .send_multipart(&[connection_id, &msg.write_to_bytes().unwrap()], 0)
//             .unwrap();
//         let msg: Message =
//             protobuf::parse_from_bytes(&socket.recv_multipart(0).unwrap()[1]).unwrap();
//         assert!(msg.get_message_type() == response_type);
//         protobuf::parse_from_bytes(&msg.get_content()).unwrap()
//     }
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
//     #[test]
//     fn test_zmq_driver() {
//         let ctx = zmq::Context::new();
//         let socket = ctx.socket(zmq::ROUTER).expect("Failed to create context");
//         socket
//             .bind("tcp://127.0.0.1:*")
//             .expect("Failed to bind socket");
//         let addr = socket.get_last_endpoint().unwrap().unwrap();
//
//         // Create the mock engine with this vec so we can refer to it later. Once we put the engine
//         // in a box, it is hard to get the vec back out.
//         let calls = Arc::new(Mutex::new(Vec::new()));
//
//         // We are going to run two threads to simulate the validator and the driver
//         let mock_engine = MockEngine::with(calls.clone());
//
//         let (driver, stop) = ZmqDriver::new();
//
//         let driver_thread = thread::spawn(move || driver.start(&addr, mock_engine));
//
//         let mut response = ConsensusRegisterResponse::new();
//         response.set_status(ConsensusRegisterResponse_Status::OK);
//         let (connection_id, request): (_, ConsensusRegisterRequest) = recv_rep(
//             &socket,
//             Message_MessageType::CONSENSUS_REGISTER_REQUEST,
//             response,
//             Message_MessageType::CONSENSUS_REGISTER_RESPONSE,
//         );
//         assert!("mock" == request.get_name());
//         assert!("0" == request.get_version());
//         assert!(
//             protocols_from_tuples(vec![("1".into(), "Mock".into())])
//                 == request.get_additional_protocols()
//         );
//
//         let _: ConsensusNotifyAck = send_req_rep(
//             &connection_id,
//             &socket,
//             ConsensusNotifyEngineActivated::new(),
//             Message_MessageType::CONSENSUS_NOTIFY_ENGINE_ACTIVATED,
//             Message_MessageType::CONSENSUS_NOTIFY_ACK,
//         );
//
//         let _: ConsensusNotifyAck = send_req_rep(
//             &connection_id,
//             &socket,
//             ConsensusNotifyPeerConnected::new(),
//             Message_MessageType::CONSENSUS_NOTIFY_PEER_CONNECTED,
//             Message_MessageType::CONSENSUS_NOTIFY_ACK,
//         );
//
//         let _: ConsensusNotifyAck = send_req_rep(
//             &connection_id,
//             &socket,
//             ConsensusNotifyPeerDisconnected::new(),
//             Message_MessageType::CONSENSUS_NOTIFY_PEER_DISCONNECTED,
//             Message_MessageType::CONSENSUS_NOTIFY_ACK,
//         );
//
//         let _: ConsensusNotifyAck = send_req_rep(
//             &connection_id,
//             &socket,
//             ConsensusNotifyPeerMessage::new(),
//             Message_MessageType::CONSENSUS_NOTIFY_PEER_MESSAGE,
//             Message_MessageType::CONSENSUS_NOTIFY_ACK,
//         );
//
//         let _: ConsensusNotifyAck = send_req_rep(
//             &connection_id,
//             &socket,
//             ConsensusNotifyBlockNew::new(),
//             Message_MessageType::CONSENSUS_NOTIFY_BLOCK_NEW,
//             Message_MessageType::CONSENSUS_NOTIFY_ACK,
//         );
//
//         let _: ConsensusNotifyAck = send_req_rep(
//             &connection_id,
//             &socket,
//             ConsensusNotifyBlockValid::new(),
//             Message_MessageType::CONSENSUS_NOTIFY_BLOCK_VALID,
//             Message_MessageType::CONSENSUS_NOTIFY_ACK,
//         );
//
//         let _: ConsensusNotifyAck = send_req_rep(
//             &connection_id,
//             &socket,
//             ConsensusNotifyBlockInvalid::new(),
//             Message_MessageType::CONSENSUS_NOTIFY_BLOCK_INVALID,
//             Message_MessageType::CONSENSUS_NOTIFY_ACK,
//         );
//
//         let _: ConsensusNotifyAck = send_req_rep(
//             &connection_id,
//             &socket,
//             ConsensusNotifyBlockCommit::new(),
//             Message_MessageType::CONSENSUS_NOTIFY_BLOCK_COMMIT,
//             Message_MessageType::CONSENSUS_NOTIFY_ACK,
//         );
//
//         // Shut it down
//         stop.stop();
//         driver_thread
//             .join()
//             .expect("Driver thread panicked")
//             .expect("Driver thread returned an error");
//
//         // Assert we did what we expected
//         let final_calls = calls.lock().unwrap();
//         assert!(contains(&*final_calls, "start"));
//         assert!(contains(&*final_calls, "PeerConnected"));
//         assert!(contains(&*final_calls, "PeerDisconnected"));
//         assert!(contains(&*final_calls, "PeerMessage"));
//         assert!(contains(&*final_calls, "BlockNew"));
//         assert!(contains(&*final_calls, "BlockValid"));
//         assert!(contains(&*final_calls, "BlockInvalid"));
//         assert!(contains(&*final_calls, "BlockCommit"));
//     }
//
//     fn contains(calls: &Vec<String>, expected: &str) -> bool {
//         for call in calls {
//             if expected == call.as_str() {
//                 return true;
//             }
//         }
//         false
//     }
// }
