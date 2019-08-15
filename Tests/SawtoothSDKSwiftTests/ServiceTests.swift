//
//  ServiceTests.swift
//  sawtooth-sdk-swiftTests
//
//  Created by Teaching on 20/7/19.
//

import XCTest
@testable import sawtooth_sdk_swift

//
// #[cfg(test)]
// pub mod tests {
// use super::*;
// use std::default::Default;
//
// pub struct MockService {}
public struct MockService {}
//
// impl Service for MockService {
extension MockService: Service {
    // fn send_to(
    //     &mut self,
    //     _peer: &PeerId,
    //     _message_type: &str,
    //     _payload: Vec<u8>,
    // ) -> Result<(), Error> {
    public mutating func sendTo(peer: PeerId, messageType: String, payload: [UInt8]) throws {
        // Ok(())
    }
    // }
    // fn broadcast(&mut self, _message_type: &str, _payload: Vec<u8>) -> Result<(), Error> {
    public mutating func broadcast(messageType: String, payload: [UInt8]) throws {
        // Ok(())
    }
    // }
    // fn initialize_block(&mut self, _previous_id: Option<BlockId>) -> Result<(), Error> {
    public mutating func initializeBlock(previousID: BlockId?) throws {
        // Ok(())
    }
    // }
    // fn summarize_block(&mut self) -> Result<Vec<u8>, Error> {
    public mutating func summarizeBlock() throws -> [UInt8] {
        // Ok(Default::default())
        return []
    }
    // }
    // fn finalize_block(&mut self, _data: Vec<u8>) -> Result<BlockId, Error> {
    public mutating func finalizeBlock(data: [UInt8]) throws -> BlockId {
        //     Ok(Default::default())
        return BlockId.defaultValue
    }
    // }
    // fn cancel_block(&mut self) -> Result<(), Error> {
    public mutating func cancelBlock() throws {
        // Ok(())
    }
    // }
    // fn check_blocks(&mut self, _priority: Vec<BlockId>) -> Result<(), Error> {
    public mutating func checkBlocks(priority: [BlockId]) throws {
        // Ok(())
    }
    // }
    // fn commit_block(&mut self, _block_id: BlockId) -> Result<(), Error> {
    public mutating func commitBlock(blockID: BlockId) throws {
        // Ok(())
    }
    // }
    // fn ignore_block(&mut self, _block_id: BlockId) -> Result<(), Error> {
    public mutating func ignoreBlock(blockID: BlockId) throws {
        // Ok(())
    }
    // }
    // fn fail_block(&mut self, _block_id: BlockId) -> Result<(), Error> {
    public mutating func failBlock(blockID: BlockId) throws {
        // Ok(())
    }
    // }
    // fn get_blocks(
    //     &mut self,
    //     _block_ids: Vec<BlockId>,
    // ) -> Result<HashMap<BlockId, Block>, Error> {
    public mutating func getBlocks(blockIDs: [BlockId]) throws -> Dictionary<BlockId, EngineBlock> {
        // Ok(Default::default())
        return [:]
    }
    // }
    // fn get_chain_head(&mut self) -> Result<Block, Error> {
    public mutating func getChainHead() throws -> EngineBlock {
        // Ok(Default::default())
        return EngineBlock.defaultValue
    }
    // }
    // fn get_settings(
    //     &mut self,
    //     _block_id: BlockId,
    //     _settings: Vec<String>,
    // ) -> Result<HashMap<String, String>, Error> {
    public mutating func getSettings(blockID: BlockId, keys: [String]) throws -> Dictionary<String, String> {
        // Ok(Default::default())
        return [:]
    }
    // }
    // fn get_state(
    //     &mut self,
    //     _block_id: BlockId,
    //     _addresses: Vec<String>,
    // ) -> Result<HashMap<String, Vec<u8>>, Error> {
    public mutating func getState(blockID: BlockId, addresses: [String]) throws -> Dictionary<String, [UInt8]> {
        // Ok(Default::default())
        return [:]
    }
    // }
}
// }
// }


class ServiceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
