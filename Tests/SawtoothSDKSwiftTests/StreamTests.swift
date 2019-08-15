//
//  StreamTests.swift
//  sawtooth-sdk-swiftTests
//
//  Created by Teaching on 24/7/19.
//

import XCTest
@testable import sawtooth_sdk_swift
import mpsc

class StreamTests: XCTestCase {

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
    // /// Queue for inbound messages, sent directly to this stream.
    //
    // #[cfg(test)]
    // mod tests {
    //
    // use std::sync::mpsc::channel;
    // use std::thread;
    //
    // use messages::validator::Message;
    // use messages::validator::Message_MessageType;
    //
    // use super::MessageFuture;
    //
    // fn make_ping(correlation_id: &str) -> Message {
    func makePing(correlationID: String) -> Message {
        // let mut message = Message::new();
        var message = Message()
        // message.set_message_type(Message_MessageType::PING_REQUEST);
        message.messageType = .pingRequest
        // message.set_correlation_id(String::from(correlation_id));
        message.correlationID = correlationID
        // message.set_content(String::from("PING").into_bytes());
        message.content = "PING".data(using: .utf8)!
        //
        // message
        return message
    }
    // }
    //
    // #[test]
    // fn future_get() {
    func testFutureGet() {
        // let (tx, rx) = channel();
        let (tx, rx) = channel(channelType: MessageResult.self)
        //
        // let mut fut = MessageFuture::new(rx);
        let fut = MessageFuture(inner: rx)
        //
        // let t = thread::spawn(move || {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            // tx.send(Ok(make_ping("my_test"))).unwrap();
            try! tx.send(t: .success(self.makePing(correlationID: "my_test")))
            group.leave()
        }
        // });
        //
        // let msg = fut.get().expect("Should have a message");
        let msg = try! fut.get().mapError { (receiveError) -> ConsensusError in
            .ReceiveError("Should have message")
        }.get()
        //
        // t.join().unwrap();
        group.wait()
        //
        // assert_eq!(msg, make_ping("my_test"));
        XCTAssertEqual(makePing(correlationID: "my_test"), msg)
    }
    // }
    // }
    static var allTests = [
        ("testExample", testExample),
        ("testFutureGet", testFutureGet)
    ]
}
