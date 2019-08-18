//
//  EngineTests.swift
//  sawtooth-sdk-swiftTests
//
//  Created by Teaching on 18/7/19.
//

import XCTest
@testable import sawtooth_sdk_swift
import mpsc

// #[cfg(test)]
// pub mod tests {
// use super::*;
//
// use std::default::Default;
// use std::sync::mpsc::{channel, RecvTimeoutError};
// use std::sync::{Arc, Mutex};
// use std::thread;
// use std::time::Duration;
//
// use consensus::service::tests::MockService;
//
// pub struct MockEngine {
class MockEngine {
    // calls: Arc<Mutex<Vec<String>>>,
    var calls: [String]
    let dispatchQueue: DispatchQueue
    // }
    //
    // impl MockEngine {
    // pub fn new() -> Self {
    public init() {
        // MockEngine {
        //     calls: Arc::new(Mutex::new(Vec::new())),
        // }
        self.calls = []
        self.dispatchQueue = DispatchQueue(label: "MockEngine")
    }
    // }
    private init(calls: [String], dispatchQueue: DispatchQueue) {
        self.calls = calls
        self.dispatchQueue = dispatchQueue
    }
    //
    // pub fn with(amv: Arc<Mutex<Vec<String>>>) -> Self {
    public static func with(amv: [String]) -> MockEngine {
        // MockEngine { calls: amv }
        return MockEngine(
            calls: amv,
            dispatchQueue: DispatchQueue(label: "MockEngine")
        )
    }
    // }
    //
    // pub fn calls(&self) -> Vec<String> {
    public var currentCalls: [String]  { get {
        var currentCalls = [String]()
        // let calls = self.calls.lock().unwrap();
        self.dispatchQueue.sync {
            currentCalls.append(contentsOf: self.calls)
        }
        return currentCalls
        }}
    // }
}
// }
//
// impl Engine for MockEngine {
extension MockEngine: Engine {
    // fn start(
    //     &mut self,
    //     updates: Receiver<Update>,
    //     _service: Box<Service>,
    //     _startup_state: StartupState,
    // ) -> Result<(), Error> {
    func start(updates: Receiver<Update>, service: Service, startupState: StartupState) throws {
        // (*self.calls.lock().unwrap()).push("start".into());
        self.dispatchQueue.sync {
            self.calls.append("start")
        }
        // loop {
        var isLoopOver = false
        repeat {
            // match updates.recv_timeout(Duration::from_millis(100)) {
            switch updates.recvTimeout(timeout: 100) {
                // Ok(update) => {
            case .success( let update):
                // // We don't check for exit() here because we want to drain all the updates
                // // before we exit. In a real implementation, exit() should also be checked
                // // here since there is no guarantee the queue will ever be empty.
                // match update {
                switch update {
                // Update::PeerConnected(_) => {
                //     (*self.calls.lock().unwrap()).push("PeerConnected".into())
                // }
                case .PeerConnected(_):
                    self.dispatchQueue.sync { self.calls.append("PeerConnected") }
                // Update::PeerDisconnected(_) => {
                //     (*self.calls.lock().unwrap()).push("PeerDisconnected".into())
                // }
                case .PeerDisconnected(_):
                    self.dispatchQueue.sync { self.calls.append("PeerDisconnected") }
                // Update::PeerMessage(_, _) => {
                //     (*self.calls.lock().unwrap()).push("PeerMessage".into())
                // }
                case .PeerMessage(_, _):
                    self.dispatchQueue.sync { self.calls.append("PeerMessage") }
                // Update::BlockNew(_) => {
                //     (*self.calls.lock().unwrap()).push("BlockNew".into())
                // }
                case .BlockNew(_):
                    self.dispatchQueue.sync { self.calls.append("BlockNew") }
                // Update::BlockValid(_) => {
                //     (*self.calls.lock().unwrap()).push("BlockValid".into())
                // }
                case .BlockValid(_):
                    self.dispatchQueue.sync { self.calls.append("BlockValid") }
                // Update::BlockInvalid(_) => {
                //     (*self.calls.lock().unwrap()).push("BlockInvalid".into())
                // }
                case .BlockInvalid(_):
                    self.dispatchQueue.sync { self.calls.append("BlockInvalid") }
                // Update::BlockCommit(_) => {
                //     (*self.calls.lock().unwrap()).push("BlockCommit".into())
                // }
                case .BlockCommit(_):
                    self.dispatchQueue.sync { self.calls.append("BlockCommit") }
                // Update::Shutdown => {
                //     println!("shutdown");
                //     break;
                // }
                case .Shutdown:
                    print("shutdown")
                    isLoopOver = true
                }
                // };
                // }
                // Err(RecvTimeoutError::Disconnected) => {
                //     println!("disconnected");
                //     break;
                // }
            case .failure(.Disconnected):
                print("disconnected")
                isLoopOver = true
                // Err(RecvTimeoutError::Timeout) => {
                //     println!("timeout");
                // }
            case .failure(.Timeout):
                print("timeout")
            }
            // }
        } while !isLoopOver
        // }
        //
        // Ok(())
    }
    // }
    // fn version(&self) -> String {
    var version: String {
        // "0".into()
        return "0"
    }
    // }
    // fn name(&self) -> String {
    var name: String {
        // "mock".into()
        return "mock"
    }
    // }
    // fn additional_protocols(&self) -> Vec<(String, String)> {
    var additionalProtocols: [(String, String)] {
        // vec![("1".into(), "Mock".into())]
        // TOD: the original rust code seems to be backwards.
        // since they only check the value of the items, not the meaning,
        // this never gets caught
        return [("Mock", "1")]
    }
    // }
}
// }


class EngineTests: XCTestCase {

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
    //
    // #[test]
    // fn test_engine() {
    func testEngine() {
        // // Create the mock engine with this vec so we can refer to it later. Once we put the engine
        // // in a box, it is hard to get the vec back out.
        // let calls = Arc::new(Mutex::new(Vec::new()));
        let calls = [String]()
        //
        // // We are going to run two threads to simulate the validator and the driver
        // let mut mock_engine = MockEngine::with(calls.clone());
        let mockEngine = MockEngine.with(amv: calls)
        //
        // let (sender, receiver) = channel();
        let (sender, receiver) = channel(channelType: Update.self)
        // sender
        //     .send(Update::PeerConnected(Default::default()))
        //     .unwrap();
        try! sender.send(t: .PeerConnected(PeerInfo.defaultValue))
        // sender
        //     .send(Update::PeerDisconnected(Default::default()))
        //     .unwrap();
        try! sender.send(t: .PeerDisconnected(PeerId.defaultValue))
        // sender
        //     .send(Update::PeerMessage(Default::default(), Default::default()))
        //     .unwrap();
        try! sender.send(t: .PeerMessage(PeerMessage.defaultValue, PeerId.defaultValue))
        // sender.send(Update::BlockNew(Default::default())).unwrap();
        try! sender.send(t: .BlockNew(EngineBlock.defaultValue))
        // sender.send(Update::BlockValid(Default::default())).unwrap();
        try! sender.send(t: .BlockValid(BlockId.defaultValue))
        // sender
        //     .send(Update::BlockInvalid(Default::default()))
        //     .unwrap();
        try! sender.send(t: .BlockInvalid(BlockId.defaultValue))
        // sender
        //     .send(Update::BlockCommit(Default::default()))
        //     .unwrap();
        try! sender.send(t: .BlockCommit(BlockId.defaultValue))
        // let handle = thread::spawn(move || {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            // let svc = Box::new(MockService {});
            let svc = MockService()
            // mock_engine
            //     .start(receiver, svc, Default::default())
            //     .unwrap();
            try! mockEngine.start(
                updates: receiver,
                service: svc,
                startupState: StartupState.defaultValue)
            group.leave()
        }
        // });
        // sender.send(Update::Shutdown).unwrap();
        try! sender.send(t: .Shutdown)
        // handle.join().unwrap();
        group.wait()
        // assert!(contains(&calls, "start"));
       XCTAssertTrue(mockEngine.currentCalls.contains("start"))
        // assert!(contains(&calls, "PeerConnected"));
        XCTAssertTrue(mockEngine.currentCalls.contains("PeerConnected"))
        // assert!(contains(&calls, "PeerDisconnected"));
        XCTAssertTrue(mockEngine.currentCalls.contains("PeerDisconnected"))
        // assert!(contains(&calls, "PeerMessage"));
        XCTAssertTrue(mockEngine.currentCalls.contains("PeerMessage"))
        // assert!(contains(&calls, "BlockNew"));
        XCTAssertTrue(mockEngine.currentCalls.contains("BlockNew"))
        // assert!(contains(&calls, "BlockValid"));
        XCTAssertTrue(mockEngine.currentCalls.contains("BlockValid"))
        // assert!(contains(&calls, "BlockInvalid"));
        XCTAssertTrue(mockEngine.currentCalls.contains("BlockInvalid"))
        // assert!(contains(&calls, "BlockCommit"));
        XCTAssertTrue(mockEngine.currentCalls.contains("BlockCommit"))
    }
    // }
    //
    // fn contains(calls: &Arc<Mutex<Vec<String>>>, expected: &str) -> bool {
    //     for call in &*(calls.lock().unwrap()) {
    //         if expected == call {
    //             return true;
    //         }
    //     }
    //     false
    // }
    static var allTests = [
        ("testExample", testExample),
        ("testEngine", testEngine)
    ]
// }
}
