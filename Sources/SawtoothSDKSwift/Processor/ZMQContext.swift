//
//  ZMQContext.swift
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
// use protobuf::Message as M;
// use protobuf::RepeatedField;
//
// use messages::events::Event;
// use messages::events::Event_Attribute;
// use messages::state_context::*;
// use messages::validator::Message_MessageType;
import SawtoothProtoSwift
// use messaging::stream::MessageSender;
// use messaging::zmq_stream::ZmqMessageSender;
// use processor::handler::{ContextError, TransactionContext};
//
// use super::generate_correlation_id;
//
// #[derive(Clone)]
// pub struct ZmqTransactionContext {
public class ZmqTransactionContext {
    // context_id: String,
    let contextID: String
    // sender: ZmqMessageSender,
    var sender: ZmqMessageSender
// }
//
// impl ZmqTransactionContext {
    // /// Context provides an interface for getting, setting, and deleting
    // /// validator state. All validator interactions by a handler should be
    // /// through a Context instance.
    // ///
    // /// # Arguments
    // ///
    // /// * `sender` - for client grpc communication
    // /// * `context_id` - the context_id passed in from the validator
    // pub fn new(context_id: &str, sender: ZmqMessageSender) -> Self {
    public init(contextID: String, sender: ZmqMessageSender) {
        // ZmqTransactionContext {
        //     context_id: String::from(context_id),
        //     sender,
        // }
        self.contextID = contextID
        self.sender = sender
    }
    // }
}
// }
//
// impl TransactionContext for ZmqTransactionContext {
extension ZmqTransactionContext: TransactionContext {
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
    // ) -> Result<Vec<(String, Vec<u8>)>, ContextError> {
    public func getStateEntries(addresses: [String]) throws -> [(String, Data)] {
        // let mut request = TpStateGetRequest::new();
        var request = TpStateGetRequest()
        // request.set_context_id(self.context_id.clone());
        request.contextID = self.contextID
        // request.set_addresses(RepeatedField::from_vec(addresses.to_vec()));
        request.addresses = addresses
        // let serialized = request.write_to_bytes()?;
        let serialized = try request.serializedData()
        // let x: &[u8] = &serialized;
        //
        // let mut future = self.sender.send(
        //     Message_MessageType::TP_STATE_GET_REQUEST,
        //     &generate_correlation_id(),
        //     x,
        // )?;
        let future = try self.sender.send(
            destination: .tpStateGetRequest,
            correlationID: generateCorrelationID(),
            contents: serialized)
        //
        // let response: TpStateGetResponse = protobuf::parse_from_bytes(future.get()?.get_content())?;
        let responseMessage = try future.get().get()
        let response = try TpStateGetResponse(serializedData: responseMessage.content)
        // match response.get_status() {
        switch response.status {
            // TpStateGetResponse_Status::OK => {
        case .ok:
            // let mut entries = Vec::new();
            var entries = [(String, Data)]()
            // for entry in response.get_entries() {
            for entry in response.entries {
                // match entry.get_data().len() {
                switch entry.data.count {
                    // 0 => continue,
                case 0: break
                    // _ => entries
                    //     .push((entry.get_address().to_string(), Vec::from(entry.get_data()))),
                default:
                    entries.append((entry.address, entry.data))
                }
                // }
            }
            // }
            // Ok(entries)
            return entries
            // }
            // TpStateGetResponse_Status::AUTHORIZATION_ERROR => {
        case .authorizationError:
            // Err(ContextError::AuthorizationError(format!(
            //     "Tried to get unauthorized addresses: {:?}",
            //     addresses
            // )))
            throw ContextError.authorizationError("Tried to get unauthorized addresses: \(addresses)")
            // }
            // TpStateGetResponse_Status::STATUS_UNSET => Err(ContextError::ResponseAttributeError(
            //     String::from("Status was not set for TpStateGetResponse"),
            // )),
        case .unset:
            throw ContextError.responseAttributeError("Status was not set for TpStateGetResponse")
        // TOD: added unexpected error
        case .UNRECOGNIZED(let errno):
            throw ContextError.unexpectedError("Unrecognized error \(errno) in response")
        }
        // }
    }
    // }
    //
    // /// set_state requests that each address in the provided map be
    // /// set in validator state to its corresponding value.
    // ///
    // /// # Arguments
    // ///
    // /// * `entries` - entries are a hashmap where the key is an address and value is the data
    // fn set_state_entries(&self, entries: Vec<(String, Vec<u8>)>) -> Result<(), ContextError> {
    public func setStateEntries(entries: [(String, Data)]) throws {
        // let state_entries: Vec<TpStateEntry> = entries
        //     .into_iter()
        //     .map(|(address, payload)| {
        //         let mut entry = TpStateEntry::new();
        //         entry.set_address(address);
        //         entry.set_data(payload);
        //         entry
        //     })
        //     .collect();
        let stateEntries = entries.map { (entry) -> TpStateEntry in
            let (address, payload) = entry
            var entry = TpStateEntry()
            entry.address = address
            entry.data = payload
            return entry
        }
        //
        // let mut request = TpStateSetRequest::new();
        // request.set_context_id(self.context_id.clone());
        // request.set_entries(RepeatedField::from_vec(state_entries.to_vec()));
        var request = TpStateSetRequest()
        request.contextID = self.contextID
        request.entries = stateEntries
        // let serialized = request.write_to_bytes()?;
        // let x: &[u8] = &serialized;
        let serialized = try request.serializedData()
        //
        // let mut future = self.sender.send(
        //     Message_MessageType::TP_STATE_SET_REQUEST,
        //     &generate_correlation_id(),
        //     x,
        // )?;
        let future = try self.sender.send(
            destination: .tpStateSetRequest,
            correlationID: generateCorrelationID(),
            contents: serialized)
        //
        // let response: TpStateSetResponse = protobuf::parse_from_bytes(future.get()?.get_content())?;
        let responseMessage = try future.get().get()
        let response = try TpStateSetResponse(serializedData: responseMessage.content)
        // match response.get_status() {
        switch response.status {
            // TpStateSetResponse_Status::OK => Ok(()),
        case .ok: return
            // TpStateSetResponse_Status::AUTHORIZATION_ERROR => {
        case .authorizationError:
            // Err(ContextError::AuthorizationError(format!(
            //     "Tried to set unauthorized addresses: {:?}",
            //     state_entries
            // )))
            throw ContextError.authorizationError("Tried to set unauthorized addresses: \(stateEntries)")
            // }
            // TpStateSetResponse_Status::STATUS_UNSET => Err(ContextError::ResponseAttributeError(
            //     String::from("Status was not set for TpStateSetResponse"),
            // )),
        case .unset:
            throw ContextError.responseAttributeError("Status was not set for TpStateSetResponse")
        case .UNRECOGNIZED(let errno):
            throw ContextError.unexpectedError("Unrecognized error \(errno) in response")
        }
        // }
    }
    // }
    //
    // /// delete_state_entries requests that each of the provided addresses be unset
    // /// in validator state. A list of successfully deleted addresses
    // /// is returned.
    // ///
    // /// # Arguments
    // ///
    // /// * `addresses` - the addresses to delete
    // fn delete_state_entries(&self, addresses: &[String]) -> Result<Vec<String>, ContextError> {
    public func deleteStateEntries(addresses: [String]) throws -> [String] {
        // let mut request = TpStateDeleteRequest::new();
        var request = TpStateDeleteRequest()
        // request.set_context_id(self.context_id.clone());
        request.contextID = self.contextID
        // request.set_addresses(RepeatedField::from_slice(addresses));
        request.addresses = addresses
        //
        // let serialized = request.write_to_bytes()?;
        // let x: &[u8] = &serialized;
        let serialized = try request.serializedData()
        //
        // let mut future = self.sender.send(
        //     Message_MessageType::TP_STATE_DELETE_REQUEST,
        //     &generate_correlation_id(),
        //     x,
        // )?;
        let future = try self.sender.send(
            destination: .tpStateDeleteRequest,
            correlationID: generateCorrelationID(),
            contents: serialized)
        //
        // let response: TpStateDeleteResponse =
        //     protobuf::parse_from_bytes(future.get()?.get_content())?;
        let responseMessage = try future.get().get()
        let response = try TpStateDeleteResponse(serializedData: responseMessage.content)
        // match response.get_status() {
        switch response.status {
        // TpStateDeleteResponse_Status::OK => Ok(Vec::from(response.get_addresses())),
        case .ok: return response.addresses
        // TpStateDeleteResponse_Status::AUTHORIZATION_ERROR => {
        case .authorizationError:
            // Err(ContextError::AuthorizationError(format!(
            //     "Tried to delete unauthorized addresses: {:?}",
            //     addresses
            // )))
            throw ContextError.authorizationError("Tried to set unauthorized addresses: \(addresses)")
        // }
        // TpStateDeleteResponse_Status::STATUS_UNSET => {
        //     Err(ContextError::ResponseAttributeError(String::from(
        //         "Status was not set for TpStateDeleteResponse",
        //     )))
        // }
        case .unset:
            throw ContextError.responseAttributeError("Status was not set for TpStateDeleteResponse")
        case .UNRECOGNIZED(let errno):
            throw ContextError.unexpectedError("Unrecognized error \(errno) in response")
        }
        // }
    }
    // }
    //
    // /// add_receipt_data adds a blob to the execution result for this transaction
    // ///
    // /// # Arguments
    // ///
    // /// * `data` - the data to add
    // fn add_receipt_data(&self, data: &[u8]) -> Result<(), ContextError> {
    public func addReceiptData(data: Data) throws {
        // let mut request = TpReceiptAddDataRequest::new();
        var request = TpReceiptAddDataRequest()
        // request.set_context_id(self.context_id.clone());
        request.contextID = self.contextID
        // request.set_data(Vec::from(data));
        request.data = data
        //
        // let serialized = request.write_to_bytes()?;
        // let x: &[u8] = &serialized;
        let serialized = try request.serializedData()
        //
        // let mut future = self.sender.send(
        //     Message_MessageType::TP_RECEIPT_ADD_DATA_REQUEST,
        //     &generate_correlation_id(),
        //     x,
        // )?;
        let future = try self.sender.send(
            destination: .tpReceiptAddDataRequest,
            correlationID: generateCorrelationID(),
            contents: serialized)
        //
        // let response: TpReceiptAddDataResponse =
        //     protobuf::parse_from_bytes(future.get()?.get_content())?;
        let responseMessage = try future.get().get()
        let response = try TpReceiptAddDataResponse(serializedData: responseMessage.content)
        // match response.get_status() {
        switch response.status {
            // TpReceiptAddDataResponse_Status::OK => Ok(()),
        case .ok: return
            // TpReceiptAddDataResponse_Status::ERROR => Err(ContextError::TransactionReceiptError(
            //     format!("Failed to add receipt data {:?}", data),
            // )),
        case .error:
            throw ContextError.transactionReceiptError("Failed to add receipt data \(data)")
            // TpReceiptAddDataResponse_Status::STATUS_UNSET => {
            //     Err(ContextError::ResponseAttributeError(String::from(
            //         "Status was not set for TpReceiptAddDataResponse",
            //     )))
            // }
        case .unset:
            throw ContextError.responseAttributeError("Status was not set for TpReceiptAddDataResponse")
        case .UNRECOGNIZED(let errno):
            throw ContextError.unexpectedError("Unrecognized error \(errno) in response")
        }
        // }
    }
    // }
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
    // ) -> Result<(), ContextError> {
    public func addEvent(eventType: String, attributes: [(String, String)], data: Data) throws {
        // let mut event = Event::new();
        var event = Event()
        // event.set_event_type(event_type);
        event.eventType = eventType
        //
        // let mut attributes_vec = Vec::new();
        // for (key, value) in attributes {
        //     let mut attribute = Event_Attribute::new();
        //     attribute.set_key(key);
        //     attribute.set_value(value);
        //     attributes_vec.push(attribute);
        // }
        let attributes = attributes.map { (attribute) -> Event.Attribute in
            let (key, value) = attribute
            var eventAttribute = Event.Attribute()
            eventAttribute.key = key
            eventAttribute.value = value
            return eventAttribute
        }
        // event.set_attributes(RepeatedField::from_vec(attributes_vec));
        event.attributes = attributes
        // event.set_data(Vec::from(data));
        event.data = data
        //
        // let mut request = TpEventAddRequest::new();
        var request = TpEventAddRequest()
        // request.set_context_id(self.context_id.clone());
        request.contextID = contextID
        // request.set_event(event.clone());
        request.event = event
        //
        // let serialized = request.write_to_bytes()?;
        // let x: &[u8] = &serialized;
        let serialized = try request.serializedData()
        //
        // let mut future = self.sender.send(
        //     Message_MessageType::TP_EVENT_ADD_REQUEST,
        //     &generate_correlation_id(),
        //     x,
        // )?;
        let future = try self.sender.send(
            destination: .tpEventAddRequest,
            correlationID: generateCorrelationID(),
            contents: serialized)
        
        //
        // let response: TpEventAddResponse = protobuf::parse_from_bytes(future.get()?.get_content())?;
        let responseMessage = try future.get().get()
        let response = try TpEventAddResponse(serializedData: responseMessage.content)
        // match response.get_status() {
        switch response.status {
            // TpEventAddResponse_Status::OK => Ok(()),
        case .ok: return
            // TpEventAddResponse_Status::ERROR => Err(ContextError::TransactionReceiptError(
            //     format!("Failed to add event {:?}", event),
            // )),
        case .error:
            throw ContextError.transactionReceiptError("Failed to add event \(event)")
            // TpEventAddResponse_Status::STATUS_UNSET => Err(ContextError::ResponseAttributeError(
            //     String::from("Status was not set for TpEventAddRespons"),
            // )),
        case .unset:
            throw ContextError.responseAttributeError("Status was not set for TpEventAddResponse")
        case .UNRECOGNIZED(let errno):
            throw ContextError.unexpectedError("Unrecognized error \(errno) in response")
        }
        // }
    }
    // }
}
// }
