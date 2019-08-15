//
//  Stream.swift
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
// use messages::validator::Message;
// use messages::validator::Message_MessageType;
import SawtoothProtoSwift
// use std;
// use std::error::Error;
// use std::sync::mpsc::Receiver;
// use std::sync::mpsc::RecvError;
import MPSCSwift
// use std::time::Duration;
//
// /// A Message Sender
// ///
// /// A message
// pub trait MessageSender {
public protocol MessageSender {
    // fn send(
    func send(
        // &self,
        // destination: Message_MessageType,
        destination: Message.MessageType,
        // correlation_id: &str,
        correlationID: String,
        // contents: &[u8],
        contents: Data
    )
    // ) -> Result<MessageFuture, SendError>;
    throws -> MessageFuture
    //
    // fn reply(
    func reply(
        // &self,
        // destination: Message_MessageType,
        destination: Message.MessageType,
        // correlation_id: &str,
        correlationID: String,
        // contents: &[u8],
        contents: Data
    )
    // ) -> Result<(), SendError>;
    throws
    //
    // fn close(&mut self);
    mutating func close()
}
// }
//
// /// Result for a message received.
// pub type MessageResult = Result<Message, ReceiveError>;
public typealias MessageResult = Result<Message, ReceiveError>
//
// /// A message Receiver
// pub type MessageReceiver = Receiver<MessageResult>;
public typealias MessageReceiver = Receiver<MessageResult>
//
// /// A Message Connection
// ///
// /// This denotes a connection which can create a MessageSender/Receiver pair.
// pub trait MessageConnection<MS: MessageSender> {
public protocol MessageConnection {
    associatedtype MS = MessageSender
    // fn create(&self) -> (MS, MessageReceiver);
    func create() -> (MS, MessageReceiver)
}
// }
//
// /// Errors that occur on sending a message.
// #[derive(Debug)]
// pub enum SendError {
public enum SendError: Error {
    // DisconnectedError,
    // TimeoutError,
    // UnknownError,
    case disconnectedError
    case timeoutError
    case unknownError
}
// }
//
// impl std::error::Error for SendError {
//     fn description(&self) -> &str {
//         match *self {
//             SendError::DisconnectedError => "DisconnectedError",
//             SendError::TimeoutError => "TimeoutError",
//             SendError::UnknownError => "UnknownError",
//         }
//     }
//
//     fn cause(&self) -> Option<&std::error::Error> {
//         match *self {
//             SendError::DisconnectedError => None,
//             SendError::TimeoutError => None,
//             SendError::UnknownError => None,
//         }
//     }
// }
//
// impl std::fmt::Display for SendError {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         match *self {
//             SendError::DisconnectedError => write!(f, "DisconnectedError"),
//             SendError::TimeoutError => write!(f, "TimeoutError"),
//             SendError::UnknownError => write!(f, "UnknownError"),
//         }
//     }
// }
//
// /// Errors that occur on receiving a message.
// #[derive(Debug, Clone)]
// pub enum ReceiveError {
public enum ReceiveError: Error {
    // TimeoutError,
    case TimeoutError
    // ChannelError(RecvError),
    case ChannelError(RecvError)
    // DisconnectedError,
    case DisconnectedError
}
// }
//
// impl std::error::Error for ReceiveError {
//     fn description(&self) -> &str {
//         match *self {
//             ReceiveError::TimeoutError => "TimeoutError",
//             ReceiveError::ChannelError(ref err) => err.description(),
//             ReceiveError::DisconnectedError => "DisconnectedError",
//         }
//     }
//
//     fn cause(&self) -> Option<&std::error::Error> {
//         match *self {
//             ReceiveError::TimeoutError => None,
//             ReceiveError::ChannelError(ref err) => Some(err),
//             ReceiveError::DisconnectedError => None,
//         }
//     }
// }
//
// impl std::fmt::Display for ReceiveError {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         match *self {
//             ReceiveError::TimeoutError => write!(f, "TimeoutError"),
//             ReceiveError::ChannelError(ref err) => write!(f, "ChannelError: {}", err.description()),
//             ReceiveError::DisconnectedError => write!(f, "DisconnectedError"),
//         }
//     }
// }
// /// MessageFuture is a promise for the reply to a sent message on connection.
// pub struct MessageFuture {
public class MessageFuture {
    // inner: Receiver<MessageResult>,
    let inner: Receiver<MessageResult>
    // result: Option<MessageResult>,
    var result: MessageResult?
    //
    // pub fn new(inner: Receiver<MessageResult>) -> Self {
    public init(inner: Receiver<MessageResult>) {
        // MessageFuture {
        //     inner,
        //     result: None,
        // }
        self.inner = inner
        self.result = nil
    }
    // }
}
// }
//
// impl MessageFuture {
extension MessageFuture {
    // pub fn get(&mut self) -> MessageResult {
    public func get() -> MessageResult {
        // if let Some(ref result) = self.result {
        if let result = self.result {
            // return result.clone();
            return result
        }
        // }
        //
        // match self.inner.recv() {
        switch self.inner.recv() {
            // Ok(result) => {
        case .success(let result):
            //     self.result = Some(result.clone());
            self.result = result
            //     result
            return result
            // }
            // Err(err) => Err(ReceiveError::ChannelError(err)),
        case .failure(let err):
            return MessageResult.failure(ReceiveError.ChannelError(err))
        }
        // }
    }
    // }
    //
    // pub fn get_timeout(&mut self, timeout: Duration) -> MessageResult {
    public func getTimeout(timeout: Duration) -> MessageResult {
        // if let Some(ref result) = self.result {
        if let result = self.result {
            // return result.clone();
            return result
        }
        // }
        //
        // match self.inner.recv_timeout(timeout) {
        switch self.inner.recvTimeout(timeout: timeout) {
        // Ok(result) => {
        case .success(let result):
            // self.result = Some(result.clone());
            self.result = result
            // result
            return result
        // }
        // Err(_) => Err(ReceiveError::TimeoutError),
        case .failure(_):
            return .failure(ReceiveError.TimeoutError)
        }
        // }
    }
    // }
}
// }
//
// /// Queue for inbound messages, sent directly to this stream.
//
// #[cfg(test)]
// mod tests {
//
//     use std::sync::mpsc::channel;
//     use std::thread;
//
//     use messages::validator::Message;
//     use messages::validator::Message_MessageType;
//
//     use super::MessageFuture;
//
//     fn make_ping(correlation_id: &str) -> Message {
//         let mut message = Message::new();
//         message.set_message_type(Message_MessageType::PING_REQUEST);
//         message.set_correlation_id(String::from(correlation_id));
//         message.set_content(String::from("PING").into_bytes());
//
//         message
//     }
//
//     #[test]
//     fn future_get() {
//         let (tx, rx) = channel();
//
//         let mut fut = MessageFuture::new(rx);
//
//         let t = thread::spawn(move || {
//             tx.send(Ok(make_ping("my_test"))).unwrap();
//         });
//
//         let msg = fut.get().expect("Should have a message");
//
//         t.join().unwrap();
//
//         assert_eq!(msg, make_ping("my_test"));
//     }
// }
