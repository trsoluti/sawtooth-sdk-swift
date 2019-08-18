//
//  Service.swift
//  sawtooth-sdk-swift
//
//  Created by Teaching on 8/7/19.
//

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
// use consensus::engine::{Block, BlockId, Error, PeerId};
// use std::collections::HashMap;
//
// /// Provides methods that allow the consensus engine to issue commands and requests.
// pub trait Service {
public protocol Service {
    // // -- P2P --
    //
    // /// Send a consensus message to a specific, connected peer
    // #[allow(clippy::ptr_arg)]
    // fn send_to(&mut self, peer: &PeerId, message_type: &str, payload: Vec<u8>)
    //     -> Result<(), Error>;
    mutating func sendTo(peer: PeerId, messageType: String, payload: [UInt8]) throws
    //
    // /// Broadcast a message to all connected peers
    // fn broadcast(&mut self, message_type: &str, payload: Vec<u8>) -> Result<(), Error>;
    mutating func broadcast(messageType: String, payload: [UInt8]) throws
    //
    // // -- Block Creation --
    //
    // /// Initialize a new block built on the block with the given previous id and
    // /// begin adding batches to it. If no previous id is specified, the current
    // /// head will be used.
    // fn initialize_block(&mut self, previous_id: Option<BlockId>) -> Result<(), Error>;
    mutating func initializeBlock(previousID: BlockId?) throws
    //
    // /// Stop adding batches to the current block and return a summary of its
    // /// contents.
    // fn summarize_block(&mut self) -> Result<Vec<u8>, Error>;
    mutating func summarizeBlock() throws -> [UInt8]
    //
    // /// Insert the given consensus data into the block and sign it. If this call is successful, the
    // /// consensus engine will receive the block afterwards.
    // fn finalize_block(&mut self, data: Vec<u8>) -> Result<BlockId, Error>;
    mutating func finalizeBlock(data: [UInt8]) throws -> BlockId
    //
    // /// Stop adding batches to the current block and abandon it.
    // fn cancel_block(&mut self) -> Result<(), Error>;
    mutating func cancelBlock() throws
    //
    // // -- Block Directives --
    //
    // /// Update the prioritization of blocks to check
    // fn check_blocks(&mut self, priority: Vec<BlockId>) -> Result<(), Error>;
    mutating func checkBlocks(priority: [BlockId]) throws
    //
    // /// Update the block that should be committed
    // fn commit_block(&mut self, block_id: BlockId) -> Result<(), Error>;
    mutating func commitBlock(blockID: BlockId) throws
    //
    // /// Signal that this block is no longer being committed
    // fn ignore_block(&mut self, block_id: BlockId) -> Result<(), Error>;
    mutating func ignoreBlock(blockID: BlockId) throws
    //
    // /// Mark this block as invalid from the perspective of consensus
    // fn fail_block(&mut self, block_id: BlockId) -> Result<(), Error>;
    mutating func failBlock(blockID: BlockId) throws
    //
    // // -- Queries --
    //
    // /// Retrieve consensus-related information about blocks
    // fn get_blocks(&mut self, block_ids: Vec<BlockId>) -> Result<HashMap<BlockId, Block>, Error>;
    mutating func getBlocks(blockIDs: [BlockId]) throws -> Dictionary<BlockId, EngineBlock>
    //
    // /// Get the chain head block.
    // fn get_chain_head(&mut self) -> Result<Block, Error>;
    mutating func getChainHead() throws -> EngineBlock
    //
    // /// Read the value of settings as of the given block
    // fn get_settings(
    mutating func getSettings(
        // &mut self,
        // block_id: BlockId,
        blockID: BlockId,
        // keys: Vec<String>,
        keys: [String]
    )
    // ) -> Result<HashMap<String, String>, Error>;
    throws -> Dictionary<String, String>
    //
    // /// Read values in state as of the given block
    // fn get_state(
    mutating func getState(
        // &mut self,
        // block_id: BlockId,
        blockID: BlockId,
        // addresses: Vec<String>,
        addresses: [String]
    )
    // ) -> Result<HashMap<String, Vec<u8>>, Error>;
    throws -> Dictionary<String, [UInt8]>
}
// }
//
// #[cfg(test)]
// pub mod tests {
//     use super::*;
//     use std::default::Default;
//
//     pub struct MockService {}
//
//     impl Service for MockService {
//         fn send_to(
//             &mut self,
//             _peer: &PeerId,
//             _message_type: &str,
//             _payload: Vec<u8>,
//         ) -> Result<(), Error> {
//             Ok(())
//         }
//         fn broadcast(&mut self, _message_type: &str, _payload: Vec<u8>) -> Result<(), Error> {
//             Ok(())
//         }
//         fn initialize_block(&mut self, _previous_id: Option<BlockId>) -> Result<(), Error> {
//             Ok(())
//         }
//         fn summarize_block(&mut self) -> Result<Vec<u8>, Error> {
//             Ok(Default::default())
//         }
//         fn finalize_block(&mut self, _data: Vec<u8>) -> Result<BlockId, Error> {
//             Ok(Default::default())
//         }
//         fn cancel_block(&mut self) -> Result<(), Error> {
//             Ok(())
//         }
//         fn check_blocks(&mut self, _priority: Vec<BlockId>) -> Result<(), Error> {
//             Ok(())
//         }
//         fn commit_block(&mut self, _block_id: BlockId) -> Result<(), Error> {
//             Ok(())
//         }
//         fn ignore_block(&mut self, _block_id: BlockId) -> Result<(), Error> {
//             Ok(())
//         }
//         fn fail_block(&mut self, _block_id: BlockId) -> Result<(), Error> {
//             Ok(())
//         }
//         fn get_blocks(
//             &mut self,
//             _block_ids: Vec<BlockId>,
//         ) -> Result<HashMap<BlockId, Block>, Error> {
//             Ok(Default::default())
//         }
//         fn get_chain_head(&mut self) -> Result<Block, Error> {
//             Ok(Default::default())
//         }
//         fn get_settings(
//             &mut self,
//             _block_id: BlockId,
//             _settings: Vec<String>,
//         ) -> Result<HashMap<String, String>, Error> {
//             Ok(Default::default())
//         }
//         fn get_state(
//             &mut self,
//             _block_id: BlockId,
//             _addresses: Vec<String>,
//         ) -> Result<HashMap<String, Vec<u8>>, Error> {
//             Ok(Default::default())
//         }
//     }
// }
