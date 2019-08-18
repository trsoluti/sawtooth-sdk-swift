//
//  ZMQStream.swift
//  sawtooth-sdk-swift
//
//  Created by Teaching on 8/7/19.
//

import Foundation

// /*
//  * Copyright 2017 Intel Corporation
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
//  * -----------------------------------------------------------------------------
//  */
// use uuid;
// use zmq;
import ZeroMQSwift
//
// use std::collections::HashMap;
// use std::error::Error;
// use std::sync::mpsc::{channel, sync_channel, Receiver, RecvTimeoutError, Sender, SyncSender};
import MPSCSwift
// use std::sync::{Arc, Mutex};
// use std::thread;
import Dispatch
// use std::time::Duration;
//
// use messages::validator::Message;
// use messages::validator::Message_MessageType;
import SawtoothProtoSwift
// use protobuf;
//
// use messaging::stream::*;
//
// const CHANNEL_BUFFER_SIZE: usize = 128;
let CHANNEL_BUFFER_SIZE = 128
//
// /// A MessageConnection over ZMQ sockets
// pub struct ZmqMessageConnection {
public class ZmqMessageConnection {
    // address: String,
    let address: String
    // context: zmq::Context,
    let context: Context
// }
//
// impl ZmqMessageConnection {
    // /// Create a new ZmqMessageConnection
    // pub fn new(address: &str) -> Self {
    public init(address: String) {
        // ZmqMessageConnection {
        //     address: String::from(address),
        //     context: zmq::Context::new(),
        // }
        self.address = address
        self.context = Context()
        //+print("DBG_PRINT ZmqMessageConnection to '\(address)' initialized.")
    }
    // }
}
// }
//
// impl MessageConnection<ZmqMessageSender> for ZmqMessageConnection {
extension ZmqMessageConnection: MessageConnection {
    public typealias MS = ZmqMessageSender
    // fn create(&self) -> (ZmqMessageSender, MessageReceiver) {
    public func create() -> (MS, MessageReceiver) {
        // // Create the channel for request messages (i.e. non-reply messages)
        // let (request_tx, request_rx) = sync_channel(CHANNEL_BUFFER_SIZE);
        let (requestTX, requestRX) = syncChannel(channelType: MessageResult.self, bound: CHANNEL_BUFFER_SIZE)
        //+print("DBG_PRINT: ZmqMessageSender.requestTX queueID = \(requestTX.queueID)")
        //+print("DBG_PRINT: ZmqMessageSender.requestRX queueID = \(requestRX.queueID)")
        // let router = InboundRouter::new(request_tx);
        let router = InboundRouter(inboundTX: requestTX)
        // let mut sender = ZmqMessageSender::new(self.context.clone(), self.address.clone(), router);
        let sender = ZmqMessageSender(context: self.context, address: self.address, router: router)
        //
        // sender.start();
        sender.start()
        //+print("DBG_PRINT ZmqMessageConnection created.")
        //
        // (sender, request_rx)
        return (sender, requestRX)
    }
    // }
}
// }
//
// #[derive(Debug)]
// enum SocketCommand {
enum SocketCommand {
    // Send(Message),
    case Send(Message)
    // Shutdown,
    case Shutdown
}
// }
//
// #[derive(Clone)]
// pub struct ZmqMessageSender {
public class ZmqMessageSender {
    // context: zmq::Context,
    let context: Context
    // address: String,
    let address: String
    // inbound_router: InboundRouter,
    var inboundRouter: InboundRouter
    // outbound_sender: Option<SyncSender<SocketCommand>>,
    var outboundSender: SyncSender<SocketCommand>?
// }
//
// impl ZmqMessageSender {
    // fn new(ctx: zmq::Context, address: String, router: InboundRouter) -> Self {
    init(context: Context, address: String, router: InboundRouter) {
        //     ZmqMessageSender {
        //         context: ctx,
        //         address,
        //         inbound_router: router,
        //         outbound_sender: None,
        //     }
        self.context = context
        self.address = address
        self.inboundRouter = router
        self.outboundSender = nil
        //+print("DBG_PRINT ZmqMessageSender to '\(address)' initialized.")
    }
    // }
    //
    // /// Start the message stream instance
    // fn start(&mut self) {
    func start() {
        // let (outbound_send, outbound_recv) = sync_channel(CHANNEL_BUFFER_SIZE);
        let (outboundSend, outboundRecv) = syncChannel(channelType: SocketCommand.self, bound: CHANNEL_BUFFER_SIZE)
        //+print("DBG_PRINT: ZmqMessageSender outboundSend queueID = \(outboundSend.queueID)")
        //+print("DBG_PRINT: ZmqMessageSender outboundRecv queueID = \(outboundRecv.queueID)")
        // self.outbound_sender = Some(outbound_send);
        self.outboundSender = outboundSend
        //
        // let ctx = self.context.clone();
        // let address = self.address.clone();
        // let inbound_router = self.inbound_router.clone();
        // TODO: need to clone these or will have thread problems
        let ctx = self.context
        let address = String(self.address)
        let newInboundRouter = self.inboundRouter
        // thread::spawn(move || {
        DispatchQueue.global(qos: .background).async {
            // let mut inner_stream =
            //     SendReceiveStream::new(&ctx, &address, outbound_recv, inbound_router);
            let innerStream = SendReceiveStream(
                context: ctx,
                address: address,
                outboundRecv: outboundRecv,
                inboundRouter: newInboundRouter)
            // inner_stream.run();
            innerStream.run()
        }
        //+print("DBG_PRINT ZmqMessageSender started")
        // });
    }
    // }
}
// }
//
// impl MessageSender for ZmqMessageSender {
extension ZmqMessageSender: MessageSender {
    // fn send(
    public func send(
        // &self,
        // destination: Message_MessageType,
        destination: Message.MessageType,
        // correlation_id: &str,
        correlationID: String,
        // contents: &[u8],
        contents: Data
    )
    // ) -> Result<MessageFuture, SendError> {
    throws -> MessageFuture {
        //+print("DBG_PRINT: In ZmqMessageSender.send.")
        // if let Some(ref sender) = self.outbound_sender {
        if let sender = self.outboundSender {
            // let mut msg = Message::new();
            var msg = Message()
            //
            // msg.set_message_type(destination);
            msg.messageType = destination
            // msg.set_correlation_id(String::from(correlation_id));
            msg.correlationID = correlationID
            // msg.set_content(Vec::from(contents));
            msg.content = contents
            //
            // let future = MessageFuture::new(
            //     self.inbound_router
            //         .expect_reply(String::from(correlation_id)),
            // );
            let future = MessageFuture(
                inner: self.inboundRouter.expectReply(correlationID: correlationID)
            )
            //
            // match sender.send(SocketCommand::Send(msg)) {
            //     Ok(_) => Ok(future),
            //     Err(_) => Err(SendError::UnknownError),
            // }
            try sender.send(t: SocketCommand.Send(msg))
            return future
        }
        // } else {
        //     Err(SendError::DisconnectedError)
        // }
        else {
            throw SendError.disconnectedError
        }
    }
    // }
    //
    // fn reply(
    public func reply(
        // &self,
        // destination: Message_MessageType,
        destination: Message.MessageType,
        // correlation_id: &str,
        correlationID: String,
        // contents: &[u8],
        contents: Data
    )
    // ) -> Result<(), SendError> {
    throws {
        // if let Some(ref sender) = self.outbound_sender {
        if let sender = self.outboundSender {
            // let mut msg = Message::new();
            var msg = Message()
            // msg.set_message_type(destination);
            msg.messageType = destination
            // msg.set_correlation_id(String::from(correlation_id));
            msg.correlationID = correlationID
            // msg.set_content(Vec::from(contents));
            msg.content = contents
            //
            // match sender.send(SocketCommand::Send(msg)) {
            //     Ok(_) => Ok(()),
            //     Err(_) => Err(SendError::UnknownError),
            // }
            try sender.send(t: SocketCommand.Send(msg))
        }
        // } else {
        //     Err(SendError::DisconnectedError)
        // }
        else {
            throw SendError.disconnectedError
        }
    }
    // }
    //
    // fn close(&mut self) {
    public func close() {
        // if let Some(ref sender) = self.outbound_sender.take() {
        if let sender = self.outboundSender {
            // match sender.send(SocketCommand::Shutdown) {
            //     Ok(_) => (),
            //     Err(_) => info!("Sender has already closed."),
            // }
            let result = Result { try sender.send(t: SocketCommand.Shutdown) }
            if case .failure(_) = result {
                print("Sender has already closed.")
            }
        }
        // }
    }
    // }
}
// }
//
// #[derive(Clone)]
// struct InboundRouter {
class InboundRouter {
    // inbound_tx: SyncSender<MessageResult>,
    let inboundTX: SyncSender<MessageResult>
    // expected_replies: Arc<Mutex<HashMap<String, Sender<MessageResult>>>>,
    var expectedReplies: Dictionary<String, Sender<MessageResult>>
    let dispatchQueueForSync: DispatchQueue
// }
//
// impl InboundRouter {
    // fn new(inbound_tx: SyncSender<MessageResult>) -> Self {
    init(inboundTX: SyncSender<MessageResult>) {
        // InboundRouter {
        //     inbound_tx,
        //     expected_replies: Arc::new(Mutex::new(HashMap::new())),
        // }
        self.inboundTX = inboundTX
        self.expectedReplies = Dictionary<String, Sender<MessageResult>>()
        self.dispatchQueueForSync = DispatchQueue(label: "InboundRouter")
    }
    // }
    // fn route(&mut self, message_result: MessageResult) {
    func route(messageResult: MessageResult) throws {
        // match message_result {
        switch messageResult {
            // Ok(message) => {
        case .success(let message):
            // let mut expected_replies = self.expected_replies.lock().unwrap();
            var sender: Sender<MessageResult>?
            self.dispatchQueueForSync.sync {
                sender = self.expectedReplies.removeValue(forKey: message.correlationID)
            }
            // match expected_replies.remove(message.get_correlation_id()) {
            if let sender = sender {
                // Some(sender) => sender.send(Ok(message)).expect("Unable to route reply"),
                try Result { try sender.send(t: .success(message)) }.mapError { (_) -> Error in
                    ConsensusError.SendError("Unable to route reply")
                }.get()
            } else {
            //     None => self
            //         .inbound_tx
            //         .send(Ok(message))
            //         .expect("Unable to route new message"),
                try Result { try self.inboundTX.send(t: .success(message)) }.mapError { (_) -> Error in
                    ConsensusError.SendError("Unable to route new message")
                    }.get()
            }
            // }
            // }
            // Err(ReceiveError::DisconnectedError) => {
        case .failure(.DisconnectedError):
            // let mut expected_replies = self.expected_replies.lock().unwrap();
            var senders = [Sender<MessageResult>]()
            self.dispatchQueueForSync.sync {
                expectedReplies.forEach({ (kvPair) in
                    let (_, value) = kvPair
                    senders.append(value)
                })
            }
            // for (_, sender) in expected_replies.iter_mut() {
            for sender in senders {
                // sender
                //     .send(Err(ReceiveError::DisconnectedError))
                //     .unwrap_or_else(|err| error!("Failed to send disconnect reply: {}", err));
                try Result { try sender.send(t: .failure(ReceiveError.DisconnectedError)) }
                    .mapError { (err) -> Error in
                        ConsensusError.SendError("Failed to send disconnect reply: \(err)")
                    }
                    .get()
            }
            // }
            // self.inbound_tx
            //     .send(Err(ReceiveError::DisconnectedError))
            //     .unwrap_or_else(|err| error!("Failed to send disconnect: {}", err));
            // }
            try Result { try self.inboundTX.send(t: .failure(ReceiveError.DisconnectedError)) }
                .mapError { (err) -> Error in
                    ConsensusError.SendError("Failed to send disconnect: \(err)")
                }
                .get()
        case .failure(let err):
            // Err(err) => error!("Error: {}", err.description()),
            throw ConsensusError.SendError("Error: \(err.localizedDescription)")
        }
        // }
    }
    // }
    //
    // fn expect_reply(&self, correlation_id: String) -> Receiver<MessageResult> {
    func expectReply(correlationID: String) -> Receiver<MessageResult> {
        // let (expect_tx, expect_rx) = channel();
        let (expectTX, expectRX) = channel(channelType: MessageResult.self)
        // let mut expected_replies = self.expected_replies.lock().unwrap();
        // expected_replies.insert(correlation_id, expect_tx);
        self.dispatchQueueForSync.sync {
            expectedReplies[correlationID] = expectTX
        }
        //
        // expect_rx
        return expectRX
    }
    // }
}
// }
//
// const POLL_TIMEOUT: i64 = 10;
let POLL_TIMEOUT = 10
//
// /// Internal stream, guarding a zmq socket.
// struct SendReceiveStream {
class SendReceiveStream {
    // address: String,
    let address: String
    // socket: zmq::Socket,
    let socket: Socket
    // outbound_recv: Receiver<SocketCommand>,
    let outboundRecv: Receiver<SocketCommand>
    // inbound_router: InboundRouter,
    var inboundRouter: InboundRouter
    // monitor_socket: zmq::Socket,
    let monitorSocket: Socket
// }
//
// impl SendReceiveStream {
    // fn new(
    init(
        // context: &zmq::Context,
        context: Context,
        // address: &str,
        address: String,
        // outbound_recv: Receiver<SocketCommand>,
        outboundRecv: Receiver<SocketCommand>,
        // inbound_router: InboundRouter,
        inboundRouter: InboundRouter
    // ) -> Self {
        ) {
        // let socket = context.socket(zmq::DEALER).unwrap();
        let socket = try! context.socket(type: .dealer)
        // socket
        //     .monitor(
        //         "inproc://monitor-socket",
        //         zmq::SocketEvent::DISCONNECTED as i32,
        //     )
        //     .is_ok();
        // zmq_socket_monitor(socket, "inproc://monitor-socket", ZMQ_EVENT_DISCONNECTED)
        socket.monitor(endpoint: "inproc://monitor-socket", eventTypes: .disconnected)
        // let monitor_socket = context.socket(zmq::PAIR).unwrap();
        //let monitorSocket = zmq_socket(context, ZMQ_PAIR)!
        let monitorSocket = try! context.socket(type: .pair)
        //
        // let identity = uuid::Uuid::new(uuid::UuidVersion::Random).unwrap();
        let identity = UUID().uuidString
        // socket.set_identity(identity.as_bytes()).unwrap();
        //let identityData = identity.data(using: .utf8)!
        //identityData.withUnsafeBytes({ (bufferPtr) -> () in
        //    zmq_setsockopt(socket, ZMQ_IDENTITY, bufferPtr.baseAddress!, identityData.count)
        //})
        socket.identity = identity
        //
        // SendReceiveStream {
        //     address: String::from(address),
        //     socket,
        //     outbound_recv,
        //     inbound_router,
        //     monitor_socket,
        // }
        self.address = address
        self.socket = socket
        self.outboundRecv = outboundRecv
        self.inboundRouter = inboundRouter
        self.monitorSocket = monitorSocket
        //+print("DBG_PRINT: SendReceiveStream initialized. outboundRecv queueID = \(outboundRecv.queueID)")
    }
    // }
    //
    // fn run(&mut self) {
    func run() {
        // self.socket.connect(&self.address).unwrap();
        //+print("DBG_PRINT: SendReceiveStream connecting to \(String(cString: self.address.cString(using: .utf8)!))")
        //let p = zmq_connect(socket, self.address.cString(using: .utf8)!)
        try! self.socket.connect(endpoint: self.address)
        //+print("DBG_PRINT: Connecting to socket returns value \(p)")
        // self.monitor_socket
        //     .connect("inproc://monitor-socket")
        //     .unwrap();
        //zmq_connect(self.monitorSocket, "inproc://monitor-socket".cString(using: .utf8))
        try! self.monitorSocket.connect(endpoint: "inproc://monitor-socket")
        // loop {
        var isOver = false
        repeat {
            // let mut poll_items = [
            //     self.socket.as_poll_item(zmq::POLLIN),
            //     self.monitor_socket.as_poll_item(zmq::POLLIN),
            // ];
            let poller = Poller();
            poller.add(socket: self.socket, events: .pollIn)
            poller.add(socket: self.monitorSocket, events: .pollIn)
            // zmq::poll(&mut poll_items, POLL_TIMEOUT).unwrap();
            //let pollResult = poll_items.withUnsafeMutableBufferPointer { (unsafeMutableBufferPointer: inout UnsafeMutableBufferPointer<zmq_pollitem_t>) -> Int32 in
            //     zmq_poll(unsafeMutableBufferPointer.baseAddress, 2, Int(POLL_TIMEOUT))
            //}
            let any = poller.waitAny(timeout: POLL_TIMEOUT)
            //+print("DBG_PRINT: SendReceiveStream.run: Received \(any) poll items")
            
            // if poll_items[0].is_readable() {
            if any.hasPollIn(for: self.socket) {
                // trace!("Readable!");
                //+print("DBG_PRINT: Readable!")
                // let mut received_parts = self.socket.recv_multipart(0).unwrap();
                let receivedParts = try! socket.receiveMultipart()
                //+print("DBG_PRINT: Received \(receivedParts)")
                //
                // // Grab the last part, which should contain our message
                // if let Some(received_bytes) = received_parts.pop() {
                if let receivedPart = receivedParts.last {
                    // trace!("Received {} bytes", received_bytes.len());
                    // if !received_bytes.is_empty() {
                    if receivedPart.count > 0 {
                        // let message = protobuf::parse_from_bytes(&received_bytes).unwrap();
                        let message = (try? Message(serializedData: receivedPart))!
                        // self.inbound_router.route(Ok(message));
                        _ = (try? self.inboundRouter.route(messageResult: .success(message)))!
                    }
                    // }
                }
                // } else {
                else {
                //     debug!("Empty frame received.");
                    print("debug: Empty frame received.")
                }
                // }
            }
            // }
            // if poll_items[1].is_readable() {
            if any.hasPollIn(for: self.monitorSocket) {
                // self.monitor_socket.recv_multipart(0).unwrap();
                let _ = try! socket.receiveMultipart()
                // let message_result = Err(ReceiveError::DisconnectedError);
                let messageResult = Result<Message, ReceiveError>.failure(.DisconnectedError)
                // info!("Received Disconnect");
                // self.inbound_router.route(message_result);
                _ = (try? self.inboundRouter.route(messageResult: messageResult))!
                // break;
                isOver = true
            }
            // }
            //
            // match self
            //     .outbound_recv
            //     .recv_timeout(Duration::from_millis(POLL_TIMEOUT as u64))
            // {
            switch self.outboundRecv.recvTimeout(timeout: Duration(POLL_TIMEOUT)) {
                // Ok(SocketCommand::Send(msg)) => {
            case .success(.Send(let msg)):
                // let message_bytes = protobuf::Message::write_to_bytes(&msg).unwrap();
                let messageBytes = (try? msg.serializedData())!
                // trace!("Sending {} bytes", message_bytes.len());
                //+print("DBG_PRINT: SendReceiveStream sending \(messageBytes.count) bytes")
                // self.socket.send(&message_bytes, 0).unwrap();
                //let _ = messageBytes.withUnsafeBytes({ (body) -> Int32 in
                //    return zmq_send(socket, body.baseAddress, messageBytes.count, 0)
                //})
                try! self.socket.send(messageBytes)
                // }
                // Ok(SocketCommand::Shutdown) => {
            case .success(.Shutdown):
                // trace!("Shutdown Signal Received");
                // self.inbound_router
                //     .route(Err(ReceiveError::DisconnectedError));
                _ = (try? self.inboundRouter.route(messageResult: .failure(.DisconnectedError)))!
                // break;
                isOver = true
                // }
                // Err(RecvTimeoutError::Disconnected) => {
            case .failure(.Disconnected):
                // debug!("Disconnected outbound channel");
                // self.inbound_router
                //     .route(Err(ReceiveError::DisconnectedError));
                _ = (try? self.inboundRouter.route(messageResult: .failure(.DisconnectedError)))!
                // break;
                isOver = true
                // }
                // _ => continue,
            default:
                break // will continue outer loop
            }
            // }
        } while !isOver
        // }
        //
        // debug!("Exited stream");
        print("debug: Exited stream")
        // self.socket.disconnect(&self.address).unwrap();
        //zmq_disconnect(self.socket, self.address)
        self.socket.disconnect(endpoint: self.address)
        // self.monitor_socket
        //     .disconnect("inproc://monitor-socket")
        //     .unwrap();
        //zmq_disconnect(self.monitorSocket, "inproc://monitor-socket")
        self.monitorSocket.disconnect(endpoint: "inproc://monitor-socket")
    }
    // }
    /// Receive a multipart zmq message and store in in a list of parts
}
// }
