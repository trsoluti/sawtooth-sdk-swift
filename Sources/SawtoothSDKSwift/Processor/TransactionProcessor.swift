//
//  TransactionProcessor.swift
//  SwiftProtobuf
//
//  Created by Teaching on 8/8/19.
//

import Foundation

// /*
//  * Copyright 2017 Bitwise IO, Inc.
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
// 
// #![allow(unknown_lints)]
// 
// extern crate ctrlc;
// extern crate protobuf;
// extern crate rand;
// extern crate zmq;
// 
// use std::error::Error;
// use std::sync::atomic::{AtomicBool, Ordering};
class AtomicBool {
    typealias BooleanLiteralType = Bool
    let dispatchQueueForSync = DispatchQueue(label: UUID().uuidString)
    var _variable: Bool = false
    required init(booleanLiteral value: AtomicBool.BooleanLiteralType) {
        self.value = value
    }
    var value: Bool {
        get {
            var returnedValue = false
            dispatchQueueForSync.sync {
                returnedValue = self._variable
            }
            return returnedValue
        }
        set {
            dispatchQueueForSync.sync {
                self._variable = newValue
            }
        }
    }
}
extension AtomicBool: ExpressibleByBooleanLiteral {
}
extension Bool {
    init(_ atomicBool: AtomicBool) {
        self = atomicBool.value
    }
}
// use std::sync::mpsc::RecvTimeoutError;
// use std::sync::Arc;
// use std::time::Duration;
// 
// use self::rand::Rng;
// 
// pub mod handler;
// mod zmq_context;
// 
// use messages::network::PingResponse;
// use messages::processor::TpProcessRequest;
// use messages::processor::TpProcessResponse;
// use messages::processor::TpProcessResponse_Status;
// use messages::processor::TpRegisterRequest;
// use messages::processor::TpUnregisterRequest;
// use messages::validator::Message_MessageType;
import SawtoothProtoSwift
// use messaging::stream::MessageConnection;
// use messaging::stream::MessageSender;
// use messaging::stream::ReceiveError;
// use messaging::stream::SendError;
// use messaging::zmq_stream::ZmqMessageConnection;
// use messaging::zmq_stream::ZmqMessageSender;
// use protobuf::Message as M;
// use protobuf::RepeatedField;
// 
// use self::handler::ApplyError;
// use self::handler::TransactionHandler;
// use self::zmq_context::ZmqTransactionContext;
// 
// /// Generates a random correlation id for use in Message
// fn generate_correlation_id() -> String {
//     const LENGTH: usize = 16;
//     rand::thread_rng().gen_ascii_chars().take(LENGTH).collect()
// }
// 
// pub struct TransactionProcessor<'a> {
public class TransactionProcessor {
    // endpoint: String,
    let endpoint: String
    // conn: ZmqMessageConnection,
    var conn: ZmqMessageConnection
    // handlers: Vec<&'a TransactionHandler>,
    var handlers: [TransactionHandler]
// }
// 
// impl<'a> TransactionProcessor<'a> {
    // /// TransactionProcessor is for communicating with a
    // /// validator and routing transaction processing requests to a registered
    // /// handler. It uses ZMQ and channels to handle requests concurrently.
    // pub fn new(endpoint: &str) -> TransactionProcessor {
    public init(endpoint: String) {
        // TransactionProcessor {
        //     endpoint: String::from(endpoint),
        //     conn: ZmqMessageConnection::new(endpoint),
        //     handlers: Vec::new(),
        // }
        self.endpoint = endpoint
        self.conn = ZmqMessageConnection(address: endpoint)
        self.handlers = []
    }
    // }
    //
    // /// Adds a transaction family handler
    // ///
    // /// # Arguments
    // ///
    // /// * handler - the handler to be added
    // pub fn add_handler(&mut self, handler: &'a TransactionHandler) {
    public func addHandler(handler: TransactionHandler) {
        // self.handlers.push(handler);
        self.handlers.append(handler)
    }
    // }
    //
    // fn register(&mut self, sender: &ZmqMessageSender, unregister: &Arc<AtomicBool>) -> bool {
    fileprivate func register( sender: ZmqMessageSender, unregister: AtomicBool) -> Bool {
        // for handler in &self.handlers {
        for handler in self.handlers {
            // for version in handler.family_versions() {
            for version in handler.familyVersions {
                // let mut request = TpRegisterRequest::new();
                var request = TpRegisterRequest()
                // request.set_family(handler.family_name().clone());
                request.family = handler.familyName
                // request.set_version(version.clone());
                request.version = version
                // request.set_namespaces(RepeatedField::from_vec(handler.namespaces().clone()));
                request.namespaces = handler.namespaces
                // info!(
                //     "sending TpRegisterRequest: {} {}",
                //     &handler.family_name(),
                //     &version
                // );
                print("info: sending TpRegisterRequest: \(handler.familyName) \(version)")
                // let serialized = match request.write_to_bytes() {
                //     Ok(serialized) => serialized,
                //     Err(err) => {
                //         error!("Serialization failed: {}", err.description());
                //         // try reconnect
                //         return false;
                //     }
                // };
                // let x: &[u8] = &serialized;
                let serialized: Data
                do {
                    serialized = try request.serializedData()
                } catch {
                    print("ERROR: Serialization failed: \(error)")
                    return false
                }
                //
                // let mut future = match sender.send(
                //     Message_MessageType::TP_REGISTER_REQUEST,
                //     &generate_correlation_id(),
                //     x,
                // ) {
                //     Ok(fut) => fut,
                //     Err(err) => {
                //         error!("Registration failed: {}", err.description());
                //         // try reconnect
                //         return false;
                //     }
                // };
                let future: MessageFuture
                do {
                    future = try sender.send(
                        destination: .tpRegisterRequest,
                        correlationID: generateCorrelationID(),
                        contents: serialized
                    )
                } catch {
                    print("ERROR: Registration failed: \(error)")
                    return false
                }
                //
                // // Absorb the TpRegisterResponse message
                // loop {
                repeat {
                    // match future.get_timeout(Duration::from_millis(10000)) {
                    let result = future.getTimeout(timeout: 10000)
                    //+print("DBG_PRINT: Got result of \(result)")
                    // Ok(_) => break,
                    if case .success(_) = result {
                        // break repeat loop
                        break
                    }
                    // Err(_) => {
                    //     if unregister.load(Ordering::SeqCst) {
                    //         return false;
                    //     }
                    // }
                    if case .failure(_) = result {
                        if Bool(unregister) {
                            return false
                        }
                    }
                    // };
                } while true
                // }
            }
            // }
        }
        // }
        // true
        return true
    }
    // }
    //
    // fn unregister(&mut self, sender: &ZmqMessageSender) {
    func unregister(sender: ZmqMessageSender) {
        // let request = TpUnregisterRequest::new();
        let request = TpUnregisterRequest()
        // info!("sending TpUnregisterRequest");
        print("sending TpUnregisterRequest")
        // let serialized = match request.write_to_bytes() {
        //     Ok(serialized) => serialized,
        //     Err(err) => {
        //         error!("Serialization failed: {}", err.description());
        //         return;
        //     }
        // };
        let serialized: Data
        do {
            serialized = try request.serializedData()
        } catch {
            print("ERROR: Serialization failed: \(error)")
            return
        }
        // let x: &[u8] = &serialized;
        //
        // let mut future = match sender.send(
        //     Message_MessageType::TP_UNREGISTER_REQUEST,
        //     &generate_correlation_id(),
        //     x,
        // ) {
        //     Ok(fut) => fut,
        //     Err(err) => {
        //         error!("Unregistration failed: {}", err.description());
        //         return;
        //     }
        // };
        let future: MessageFuture
        do {
            future = try sender.send(
                destination: .tpUnregisterRequest,
                correlationID: generateCorrelationID(),
                contents: serialized
            )
        } catch {
            print("Registration failed: \(error)")
            return
        }
        // // Absorb the TpUnregisterResponse message, wait one second for response then continue
        // match future.get_timeout(Duration::from_millis(1000)) {
        //     Ok(_) => (),
        //     Err(err) => {
        //         info!("Unregistration failed: {}", err.description());
        //     }
        // };
        switch future.getTimeout(timeout: 1000) {
        case .success(_): break
        case .failure(let err):
            print("Unregistration failed \(err)")
        }
    }
    // }
    //
    // /// Connects the transaction processor to a validator and starts
    // /// listening for requests and routing them to an appropriate
    // /// transaction handler.
    // #[allow(clippy::cyclomatic_complexity)]
    // pub fn start(&mut self) {
    public func start() {
        // let unregister = Arc::new(AtomicBool::new(false));
        let unregister = AtomicBool(false)
        // let r = unregister.clone();
        // ctrlc::set_handler(move || {
        //     r.store(true, Ordering::SeqCst);
        // })
        // .expect("Error setting Ctrl-C handler");
        let dispatchQueueForSignal = DispatchQueue(label: UUID().uuidString)
        let dispatchSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: dispatchQueueForSignal)
        dispatchSource.setEventHandler {
            print("Control-C Received.")
            unregister.value = true
        }
        dispatchSource.resume()
        //
        // let mut first_time = true;
        // let mut restart = true;
        var firstTime = true
        var restart = true
        //
        // while restart {
        while restart {
            // info!("connecting to endpoint: {}", self.endpoint);
            print("connecting to endpoint: \(self.endpoint)")
            // if first_time {
            //     first_time = false;
            // } else {
            //     self.conn = ZmqMessageConnection::new(&self.endpoint);
            // }
            if firstTime {
                firstTime = false
            } else {
                self.conn = ZmqMessageConnection(address: self.endpoint)
            }
            // let (mut sender, receiver) = self.conn.create();
            let (sender, receiver) = self.conn.create()
            //
            // if unregister.load(Ordering::SeqCst) {
            //     self.unregister(&sender);
            //     restart = false;
            //     continue;
            // }
            if Bool(unregister) {
                self.unregister(sender: sender)
                // leave the loop
                restart = false
                continue
            }
            //
            // // if registration is not succesful, retry
            // if !self.register(&sender, &unregister.clone()) {
            //     continue;
            // }
            if !self.register(sender: sender, unregister: unregister) {
                continue
            }
            print("Register attempt: OK")
            //
            // loop {
            repeat {
                // if unregister.load(Ordering::SeqCst) {
                //     self.unregister(&sender);
                //     restart = false;
                //     break;
                // }
                if Bool(unregister) {
                    print("unregister tripped. Attempting to deregister")
                    self.unregister(sender: sender)
                    // break out of outer loop
                    restart = false
                    break
                }
                // match receiver.recv_timeout(Duration::from_millis(1000)) {
                switch receiver.recvTimeout(timeout: 1000) {
                    // Ok(r) => {
                case .success(let r):
                    // // Check if we have a message
                    // let message = match r {
                        // Ok(message) => message,
                        // Err(ReceiveError::DisconnectedError) => {
                        //     info!("Trying to Reconnect");
                        //     break;
                        // }
                        // Err(err) => {
                        //     error!("Error: {}", err.description());
                        //     continue;
                        // }
                    // };
                    if case .failure(.DisconnectedError) = r {
                        print("Trying to Reconnect")
                        break; // leave inner loop, but not outer loop
                    } else if case .failure( let err) = r {
                        print("Error: \(err)")
                        continue
                    }
                    if case .success(let message) = r {
                        //
                        // info!("Message: {}", message.get_correlation_id());
                        print("Message: \(message.correlationID)")
                        //
                        // match message.get_message_type() {
                        switch message.messageType {
                            // Message_MessageType::TP_PROCESS_REQUEST => {
                        case .tpProcessRequest:
                            // let request: TpProcessRequest =
                            //     match protobuf::parse_from_bytes(&message.get_content()) {
                            //         Ok(request) => request,
                            //         Err(err) => {
                            //             error!(
                            //                 "Cannot parse TpProcessRequest: {}",
                            //                 err.description()
                            //             );
                            //             continue;
                            //         }
                            //     };
                            let request: TpProcessRequest
                            do {
                                request = try TpProcessRequest(serializedData: message.content)
                            } catch {
                                print("Error: cannot parse TpProcessRequest \(error)")
                                continue
                            }
                            //
                            // let mut context = ZmqTransactionContext::new(
                            //     request.get_context_id(),
                            //     sender.clone(),
                            // );
                            var context:TransactionContext = ZmqTransactionContext(contextID: request.contextID, sender: sender)
                            //
                            // let mut response = TpProcessResponse::new();
                            var response = TpProcessResponse()
                            // match self.handlers[0].apply(&request, &mut context) {
                            do {
                                try self.handlers[0].apply(request: request, context: &context)
                                // Ok(()) => {
                                // info!("TP_PROCESS_REQUEST sending TpProcessResponse: OK");
                                // response.set_status(TpProcessResponse_Status::OK);
                                // }
                                print("TP_PROCESS_REQUEST sending TpProcessResponse: OK")
                                response.status = .ok
                            }
                            // Err(ApplyError::InvalidTransaction(msg)) => {
                            catch ApplyError.invalidTransaction(let msg) {
                                // info!(
                                //     "TP_PROCESS_REQUEST sending TpProcessResponse: {}",
                                //     &msg
                                // );
                                // response.set_status(
                                //     TpProcessResponse_Status::INVALID_TRANSACTION,
                                // );
                                // response.set_message(msg);
                                // }
                                print("TP_PROCESS_REQUEST sending TpProcessResponse: \(msg)")
                                response.status = .invalidTransaction
                                response.message = msg
                            }
                            // Err(err) => {
                            catch {
                                // info!(
                                //     "TP_PROCESS_REQUEST sending TpProcessResponse: {}",
                                //     err.description()
                                // );
                                // response
                                //     .set_status(TpProcessResponse_Status::INTERNAL_ERROR);
                                // response.set_message(String::from(err.description()));
                                // }
                                print("TP_PROCESS_REQUEST sending TpProcessResponse: \(error)")
                                response.status = .internalError
                                response.message = error.localizedDescription
                            }
                            // };
                            //
                            // let serialized = match response.write_to_bytes() {
                            //     Ok(serialized) => serialized,
                            //     Err(err) => {
                            //         error!("Serialization failed: {}", err.description());
                            //         continue;
                            //     }
                            // };
                            let serialized: Data
                            do {
                                serialized = try response.serializedData()
                            } catch {
                                print("ERROR: Serialization failed \(error)")
                                continue
                            }
                            //
                            // match sender.reply(
                            //     Message_MessageType::TP_PROCESS_RESPONSE,
                            //     message.get_correlation_id(),
                            //     &serialized,
                            // ) {
                            do {
                                try sender.reply(
                                    destination: .tpProcessResponse,
                                    correlationID: message.correlationID,
                                    contents: serialized
                                )
                            } catch SendError.disconnectedError {
                                // Ok(_) => (),
                                // Err(SendError::DisconnectedError) => {
                                //     error!("DisconnectedError");
                                //     break;
                                // }
                                print("ERROR: DisconnectedError")
                                break
                            } catch SendError.timeoutError {
                                // Err(SendError::TimeoutError) => error!("TimeoutError"),
                                print("ERROR: TimeoutError")
                            } catch /*SendError.unknownError*/ {
                                // Err(SendError::UnknownError) => {
                                //     restart = false;
                                //     println!("UnknownError");
                                //     break;
                                // }
                                restart = false
                                print("ERROR: UnknownError")
                                break
                            }
                            // };
                            // }
                            // Message_MessageType::PING_REQUEST => {
                        case .pingRequest:
                            // info!("sending PingResponse");
                            print("sending PingResponse")
                            // let response = PingResponse::new();
                            let response = PingResponse()
                            // let serialized = match response.write_to_bytes() {
                            //     Ok(serialized) => serialized,
                            //     Err(err) => {
                            //         error!("Serialization failed: {}", err.description());
                            //         continue;
                            //     }
                            // };
                            let serialized: Data
                            do {
                                serialized = try response.serializedData()
                            } catch {
                                print("ERROR: Serialization failed: \(error)")
                                continue
                            }
                            // match sender.reply(
                            //     Message_MessageType::PING_RESPONSE,
                            //     message.get_correlation_id(),
                            //     &serialized,
                            // ) {
                            //     Ok(_) => (),
                            //     Err(SendError::DisconnectedError) => {
                            //         error!("DisconnectedError");
                            //         break;
                            //     }
                            //     Err(SendError::TimeoutError) => error!("TimeoutError"),
                            //     Err(SendError::UnknownError) => {
                            //         restart = false;
                            //         println!("UnknownError");
                            //         break;
                            //     }
                            // };
                            do {
                                try sender.reply(
                                    destination: .pingResponse,
                                    correlationID: message.correlationID,
                                    contents: serialized)
                            } catch SendError.disconnectedError {
                                print("ERROR: DisconnectedError")
                                break
                            } catch SendError.timeoutError {
                                print("ERROR: TimeoutError")
                            } catch /* SendError.unknownError */ {
                                print("UnknownError")
                            }
                            // }
                            // _ => {
                        default:
                            // info!(
                            //     "Transaction Processor recieved invalid message type: {:?}",
                            //     message.get_message_type()
                            // );
                            print("Transaction Processor received invalid message type: \(message.messageType)")
                            // }
                            // TOD: if we don't respond the other end will hang permanently!
                            var response = TpProcessResponse()
                            response.status = .invalidTransaction
                            response.message = "invalid message type: \(message.messageType)"
                            do {
                                try sender.reply(
                                    destination: .tpProcessResponse,
                                    correlationID: message.correlationID,
                                    contents: response.serializedData())
                            } catch SendError.disconnectedError {
                                print("ERROR: DisconnectedError")
                                break
                            } catch SendError.timeoutError {
                                print("ERROR: TimeoutError")
                            } catch /* SendError.unknownError */ {
                                print("UnknownError")
                            }
                        }
                        // }
                        // }
                    }
                    // Err(RecvTimeoutError::Timeout) => (),
                case .failure(.Timeout): break
                    // Err(err) => {
                    //     error!("Error: {}", err.description());
                    // }
                case .failure(let err):
                    print("Error: \(err)")
                }
                // }
            } while true
            // }
            // sender.close();
            sender.close()
        }
        // }
    }
    // }
}
// }
