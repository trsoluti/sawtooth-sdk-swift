//
//  Handler.swift
//  sawtooth-sdk-swift
//
//  Created by Teaching on 8/7/19.
//

import Foundation

// /*
//  * Copyright 2017 Bitwise IO, Inc.
//  * Copyright 2019 Cargill Incorporated
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
// extern crate protobuf;
// extern crate rand;
// extern crate zmq;
//
// use std;
// use std::borrow::Borrow;
// use std::collections::HashMap;
// use std::error::Error as StdError;
//
// use messages::processor::TpProcessRequest;
import SawtoothProtoSwift
// use messaging::stream::ReceiveError;
// use messaging::stream::SendError;
//
// #[derive(Debug)]
// pub enum ApplyError {
public enum ApplyError: Error {
    // /// Returned for an Invalid Transaction.
    // InvalidTransaction(String),
    case invalidTransaction(String)
    // /// Returned when an internal error occurs during transaction processing.
    // InternalError(String),
    case internalError(String)
}
// }
//
// impl std::error::Error for ApplyError {
//     fn description(&self) -> &str {
//         match *self {
//             ApplyError::InvalidTransaction(ref msg) => msg,
//             ApplyError::InternalError(ref msg) => msg,
//         }
//     }
//
//     fn cause(&self) -> Option<&std::error::Error> {
//         match *self {
//             ApplyError::InvalidTransaction(_) => None,
//             ApplyError::InternalError(_) => None,
//         }
//     }
// }
//
// impl std::fmt::Display for ApplyError {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         match *self {
//             ApplyError::InvalidTransaction(ref s) => write!(f, "InvalidTransaction: {}", s),
//             ApplyError::InternalError(ref s) => write!(f, "InternalError: {}", s),
//         }
//     }
// }
//
// #[derive(Debug)]
// pub enum ContextError {
public enum ContextError: Error {
    // /// Returned for an authorization error
    // AuthorizationError(String),
    case authorizationError(String)
    // /// Returned when a error occurs due to missing info in a response
    // ResponseAttributeError(String),
    case responseAttributeError(String)
    // /// Returned when there is an issues setting receipt data or events.
    // TransactionReceiptError(String),
    case transactionReceiptError(String)
    // /// Returned when a ProtobufError is returned during serializing
    // SerializationError(Box<StdError>),
    case serializationError(Error)
    // /// Returned when an error is returned when sending a message
    // SendError(Box<StdError>),
    case sendError(Error)
    // /// Returned when an error is returned when sending a message
    // ReceiveError(Box<StdError>),
    case receiveError(Error)
    // TOD Added unexpected error
    /// Returned when some unexpected status is returned when sending a message
    case unexpectedError(String)
}
// }
//
// impl std::error::Error for ContextError {
//     fn description(&self) -> &str {
//         match *self {
//             ContextError::AuthorizationError(ref msg) => msg,
//             ContextError::ResponseAttributeError(ref msg) => msg,
//             ContextError::TransactionReceiptError(ref msg) => msg,
//             ContextError::SerializationError(ref err) => err.description(),
//             ContextError::SendError(ref err) => err.description(),
//             ContextError::ReceiveError(ref err) => err.description(),
//         }
//     }
//
//     fn cause(&self) -> Option<&std::error::Error> {
//         match *self {
//             ContextError::AuthorizationError(_) => None,
//             ContextError::ResponseAttributeError(_) => None,
//             ContextError::TransactionReceiptError(_) => None,
//             ContextError::SerializationError(ref err) => Some(err.borrow()),
//             ContextError::SendError(ref err) => Some(err.borrow()),
//             ContextError::ReceiveError(ref err) => Some(err.borrow()),
//         }
//     }
// }
//
// impl std::fmt::Display for ContextError {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         match *self {
//             ContextError::AuthorizationError(ref s) => write!(f, "AuthorizationError: {}", s),
//             ContextError::ResponseAttributeError(ref s) => {
//                 write!(f, "ResponseAttributeError: {}", s)
//             }
//             ContextError::TransactionReceiptError(ref s) => {
//                 write!(f, "TransactionReceiptError: {}", s)
//             }
//             ContextError::SerializationError(ref err) => {
//                 write!(f, "SerializationError: {}", err.description())
//             }
//             ContextError::SendError(ref err) => write!(f, "SendError: {}", err.description()),
//             ContextError::ReceiveError(ref err) => write!(f, "ReceiveError: {}", err.description()),
//         }
//     }
// }
//
// impl From<ContextError> for ApplyError {
//     fn from(context_error: ContextError) -> Self {
//         match context_error {
//             ContextError::TransactionReceiptError(..) => {
//                 ApplyError::InternalError(format!("{}", context_error))
//             }
//             _ => ApplyError::InvalidTransaction(format!("{}", context_error)),
//         }
//     }
// }
//
// impl From<protobuf::ProtobufError> for ContextError {
//     fn from(e: protobuf::ProtobufError) -> Self {
//         ContextError::SerializationError(Box::new(e))
//     }
// }
//
// impl From<SendError> for ContextError {
//     fn from(e: SendError) -> Self {
//         ContextError::SendError(Box::new(e))
//     }
// }
//
// impl From<ReceiveError> for ContextError {
//     fn from(e: ReceiveError) -> Self {
//         ContextError::ReceiveError(Box::new(e))
//     }
// }
//
// pub trait TransactionContext {
public protocol TransactionContext {
    // #[deprecated(
    //     since = "0.3.0",
    //     note = "please use `get_state_entry` or `get_state_entries` instead"
    // )]
    // /// get_state queries the validator state for data at each of the
    // /// addresses in the given list. The addresses that have been set
    // /// are returned. get_state is deprecated, please use get_state_entry or get_state_entries
    // /// instead
    // ///
    // /// # Arguments
    // ///
    // /// * `addresses` - the addresses to fetch
    // fn get_state(&self, addresses: &[String]) -> Result<Vec<(String, Vec<u8>)>, ContextError> {
    //     self.get_state_entries(addresses)
    // }
    //
    // /// get_state_entry queries the validator state for data at the
    // /// address given. If the  address is set, the data is returned.
    // ///
    // /// # Arguments
    // ///
    // /// * `address` - the address to fetch
    // fn get_state_entry(&self, address: &str) -> Result<Option<Vec<u8>>, ContextError> {
    mutating func getStateEntry(address: String) throws -> Data?
    //     Ok(self
    //         .get_state_entries(&[address.to_string()])?
    //         .into_iter()
    //         .map(|(_, val)| val)
    //         .next())
    // }
    //
    // /// get_state_entries queries the validator state for data at each of the
    // /// addresses in the given list. The addresses that have been set
    // /// are returned.
    // ///
    // /// # Arguments
    // ///
    // /// * `addresses` - the addresses to fetch
    // fn get_state_entries(
    //     &self,
    //     addresses: &[String],
    // ) -> Result<Vec<(String, Vec<u8>)>, ContextError>;
    mutating func getStateEntries(addresses: [String]) throws -> [(String, Data)]
    //
    // #[deprecated(
    //     since = "0.3.0",
    //     note = "please use `set_state_entry` or `set_state_entries` instead"
    // )]
    // /// set_state requests that each address in the provided map be
    // /// set in validator state to its corresponding value. set_state is deprecated, please use
    // /// set_state_entry to set_state_entries instead
    // ///
    // /// # Arguments
    // ///
    // /// * `entries` - entries are a hashmap where the key is an address and value is the data
    // fn set_state(&self, entries: HashMap<String, Vec<u8>>) -> Result<(), ContextError> {
    //     let state_entries: Vec<(String, Vec<u8>)> = entries.into_iter().collect();
    //     self.set_state_entries(state_entries)
    // }
    //
    // /// set_state_entry requests that the provided address is set in the validator state to its
    // /// corresponding value.
    // ///
    // /// # Arguments
    // ///
    // /// * `address` - address of where to store the data
    // /// * `data` - payload is the data to store at the address
    // fn set_state_entry(&self, address: String, data: Vec<u8>) -> Result<(), ContextError> {
    //     self.set_state_entries(vec![(address, data)])
    // }
    mutating func setStateEntry(address: String, data: Data) throws
    //
    // /// set_state_entries requests that each address in the provided map be
    // /// set in validator state to its corresponding value.
    // ///
    // /// # Arguments
    // ///
    // /// * `entries` - entries are a hashmap where the key is an address and value is the data
    // fn set_state_entries(&self, entries: Vec<(String, Vec<u8>)>) -> Result<(), ContextError>;
    mutating func setStateEntries(entries: [(String, Data)]) throws
    //
    // /// delete_state requests that each of the provided addresses be unset
    // /// in validator state. A list of successfully deleted addresses is returned.
    // /// delete_state is deprecated, please use delete_state_entry to delete_state_entries instead
    // ///
    // /// # Arguments
    // ///
    // /// * `addresses` - the addresses to delete
    // #[deprecated(
    //     since = "0.3.0",
    //     note = "please use `delete_state_entry` or `delete_state_entries` instead"
    // )]
    // fn delete_state(&self, addresses: &[String]) -> Result<Vec<String>, ContextError> {
    //     self.delete_state_entries(addresses)
    // }
    //
    // /// delete_state_entry requests that the provided address be unset
    // /// in validator state. A list of successfully deleted addresses
    // /// is returned.
    // ///
    // /// # Arguments
    // ///
    // /// * `address` - the address to delete
    // fn delete_state_entry(&self, address: &str) -> Result<Option<String>, ContextError> {
    //     Ok(self
    //         .delete_state_entries(&[address.to_string()])?
    //         .into_iter()
    //         .next())
    // }
    mutating func deleteStateEntry(address: String) throws -> String?
    //
    // /// delete_state_entries requests that each of the provided addresses be unset
    // /// in validator state. A list of successfully deleted addresses
    // /// is returned.
    // ///
    // /// # Arguments
    // ///
    // /// * `addresses` - the addresses to delete
    // fn delete_state_entries(&self, addresses: &[String]) -> Result<Vec<String>, ContextError>;
    mutating func deleteStateEntries(addresses: [String]) throws -> [String]
    //
    // /// add_receipt_data adds a blob to the execution result for this transaction
    // ///
    // /// # Arguments
    // ///
    // /// * `data` - the data to add
    // fn add_receipt_data(&self, data: &[u8]) -> Result<(), ContextError>;
    mutating func addReceiptData(data: Data) throws
    //
    // /// add_event adds a new event to the execution result for this transaction.
    // ///
    // /// # Arguments
    // ///
    // /// * `event_type` -  This is used to subscribe to events. It should be globally unique and
    // ///         describe what, in general, has occured.
    // /// * `attributes` - Additional information about the event that is transparent to the
    // ///          validator. Attributes can be used by subscribers to filter the type of events
    // ///          they receive.
    // /// * `data` - Additional information about the event that is opaque to the validator.
    // fn add_event(
    //     &self,
    //     event_type: String,
    //     attributes: Vec<(String, String)>,
    //     data: &[u8],
    // ) -> Result<(), ContextError>;
    mutating func addEvent(eventType: String, attributes: [(String, String)], data: Data) throws
}
// }
//
// pub trait TransactionHandler {
public protocol TransactionHandler {
    // /// TransactionHandler that defines the business logic for a new transaction family.
    // /// The family_name, family_versions, and namespaces functions are
    // /// used by the processor to route processing requests to the handler.
    //
    // /// family_name should return the name of the transaction family that this
    // /// handler can process, e.g. "intkey"
    // fn family_name(&self) -> String;
    var familyName: String { get }
    //
    // /// family_versions should return a list of versions this transaction
    // /// family handler can process, e.g. ["1.0"]
    // fn family_versions(&self) -> Vec<String>;
    var familyVersions:[String] { get }
    //
    // /// namespaces should return a list containing all the handler's
    // /// namespaces, e.g. ["abcdef"]
    // fn namespaces(&self) -> Vec<String>;
    var namespaces: [String] { get }
    //
    // /// Apply is the single method where all the business logic for a
    // /// transaction family is defined. The method will be called by the
    // /// transaction processor upon receiving a TpProcessRequest that the
    // /// handler understands and will pass in the TpProcessRequest and an
    // /// initialized instance of the Context type.
    // fn apply(
    //     &self,
    //     request: &TpProcessRequest,
    //     context: &mut dyn TransactionContext,
    // ) -> Result<(), ApplyError>;
    func apply(request: TpProcessRequest, context: inout TransactionContext) throws
}
// }

public extension TransactionContext {
    //
    // /// get_state_entry queries the validator state for data at the
    // /// address given. If the  address is set, the data is returned.
    // ///
    // /// # Arguments
    // ///
    // /// * `address` - the address to fetch
    // fn get_state_entry(&self, address: &str) -> Result<Option<Vec<u8>>, ContextError> {
    mutating func getStateEntry(address: String) throws -> Data? {
        // Ok(self
        //     .get_state_entries(&[address.to_string()])?
        //     .into_iter()
        //     .map(|(_, val)| val)
        //     .next())
        let p = try self.getStateEntries(addresses: [address])
        return p.map { (element) -> Data in
            let (_, val) = element
            return val
        }.first
    }
    // }
    //
    // /// set_state_entry requests that the provided address is set in the validator state to its
    // /// corresponding value.
    // ///
    // /// # Arguments
    // ///
    // /// * `address` - address of where to store the data
    // /// * `data` - payload is the data to store at the address
    // fn set_state_entry(&self, address: String, data: Vec<u8>) -> Result<(), ContextError> {
    mutating func setStateEntry(address: String, data: Data) throws {
        // self.set_state_entries(vec![(address, data)])
        try self.setStateEntries(entries: [(address, data)])
    }
    // }
    //
    // /// delete_state_entry requests that the provided address be unset
    // /// in validator state. A list of successfully deleted addresses
    // /// is returned.
    // ///
    // /// # Arguments
    // ///
    // /// * `address` - the address to delete
    // fn delete_state_entry(&self, address: &str) -> Result<Option<String>, ContextError> {
    mutating func deleteStateEntry(address: String) throws -> String? {
        //  Ok(self
        //      .delete_state_entries(&[address.to_string()])?
        //      .into_iter()
        //      .next())
        return try self.deleteStateEntries(addresses: [address]).first
    }
    // }
}
