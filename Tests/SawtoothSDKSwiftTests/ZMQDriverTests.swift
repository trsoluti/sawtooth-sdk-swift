//
//  ZMQDriverTests.swift
//  sawtooth-sdk-swiftTests
//
//  Created by Teaching on 20/7/19.
//

import XCTest
@testable import sawtooth_sdk_swift
import struct sawtooth_sdk_swift.Message
import SwiftProtobuf
import SwiftZMQ

typealias ProtobufMessage = SwiftProtobuf.Message

class ZMQDriverTests: XCTestCase {

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
    // #[cfg(test)]
    // mod tests {
    // use super::*;
    // use consensus::engine::tests::MockEngine;
    // use std::sync::{Arc, Mutex};
    // use zmq;
    //
    // fn send_req_rep<I: protobuf::Message, O: protobuf::Message>(
    //     connection_id: &[u8],
    //     socket: &zmq::Socket,
    //     request: I,
    //     request_type: Message_MessageType,
    //     response_type: Message_MessageType,
    // ) -> O {
    func sendReqRep<I: SwiftProtobuf.Message, O: SwiftProtobuf.Message>(
        outputMessageType: O.Type,
        connectionID: Data,
        socket: Socket,
        request: I,
        requestType: Message.MessageType,
        responseType: Message.MessageType
        ) throws -> O {
        // let correlation_id = generate_correlation_id();
        let correlationID = generateCorrelationID()
        // let mut msg = Message::new();
        var msg = Message()
        // msg.set_message_type(request_type);
        msg.messageType = requestType
        // msg.set_correlation_id(correlation_id.clone());
        msg.correlationID = correlationID
        // msg.set_content(request.write_to_bytes().unwrap());
        msg.content = try request.serializedData()
        // socket
        //     .send_multipart(&[connection_id, &msg.write_to_bytes().unwrap()], 0)
        //     .unwrap();
        let msgData = try! msg.serializedData()
        try! socket.sendMultipart([connectionID, msgData])
        // let msg: Message =
        //     protobuf::parse_from_bytes(&socket.recv_multipart(0).unwrap()[1]).unwrap();
        //let receiptMessage = try! Message(serializedData: receiveMultipartMessage(socket: socket).last!)
        let receiptMessage = try! Message(serializedData: socket.receiveMultipart().last!)
        // assert!(msg.get_message_type() == response_type);
        XCTAssert(receiptMessage.messageType == responseType)
        // protobuf::parse_from_bytes(&msg.get_content()).unwrap()
        return try! O(serializedData: msg.content)
    }
    // }
    //
    // fn recv_rep<I: protobuf::Message, O: protobuf::Message>(
    //     socket: &zmq::Socket,
    //     request_type: Message_MessageType,
    //     response: I,
    //     response_type: Message_MessageType,
    // ) -> (Vec<u8>, O) {
    func recvRep<I: ProtobufMessage, O: ProtobufMessage>(
        outputMessageType: O.Type,
        socket: Socket,
        requestType: Message.MessageType,
        response: I,
        responseType: Message.MessageType
    ) -> (Data, O) {
        // let mut parts = socket.recv_multipart(0).unwrap();
        let parts = try! socket.receiveMultipart()
        // assert!(parts.len() == 2);
        XCTAssert(parts.count == 2)
        //
        // let mut msg: Message = protobuf::parse_from_bytes(&parts.pop().unwrap()).unwrap();
        let msg = try! Message(serializedData: parts[1])
        // let connection_id = parts.pop().unwrap();
        let connectionID = parts[0]
        // assert!(msg.get_message_type() == request_type);
        XCTAssert(msg.messageType == requestType)
        // let request: O = protobuf::parse_from_bytes(&msg.get_content()).unwrap();
        let request = try! O(serializedData: msg.content)
        //
        // let correlation_id = msg.take_correlation_id();
        let correlationID = msg.correlationID
        // let mut msg = Message::new();
        var responseMsg = Message()
        // msg.set_message_type(response_type);
        responseMsg.messageType = responseType
        // msg.set_correlation_id(correlation_id);
        responseMsg.correlationID = correlationID
        // msg.set_content(response.write_to_bytes().unwrap());
        responseMsg.content = try! response.serializedData()
        // socket
        //     .send_multipart(&[&connection_id, &msg.write_to_bytes().unwrap()], 0)
        //     .unwrap();
        //
        print("DBG_PRINT: recvRep responding to message")
        //try! sendMultipartMessage(socket: socket, parts: [[UInt8](connectionID), [UInt8](responseMsg.serializedData())])
        try! socket.sendMultipart([connectionID, responseMsg.serializedData()])
        // (connection_id, request)
        return (connectionID, request)
    }
    // }
    //
    // #[test]
    // fn test_zmq_driver() {
    func testZMQDriver() {
        // let ctx = zmq::Context::new();
        //let ctx = zmq_ctx_new()!
        let ctx = Context()
        // let socket = ctx.socket(zmq::ROUTER).expect("Failed to create context");
        //let socket = zmq_socket(ctx, ZMQ_ROUTER)!
        let socket = try! ctx.socket(type: .router)
        // socket
        //     .bind("tcp://127.0.0.1:*")
        //     .expect("Failed to bind socket");
        //zmq_bind(socket, "tcp://127.0.0.1:*")
        try! socket.bind(endpoint: "tcp://127.0.0.1:*")
        // let addr = socket.get_last_endpoint().unwrap().unwrap();
        //var addrBuffer = [UInt8](repeating: 0, count: 255)
        //var nbytes:Int = 254
        //addrBuffer.withUnsafeMutableBytes { (unsafeMutableRawBufferPointer) -> () in
        //    zmq_getsockopt(socket, ZMQ_LAST_ENDPOINT, unsafeMutableRawBufferPointer.baseAddress, &nbytes)
        //}
        //let addr = String(cString: addrBuffer)
        let addr = socket.lastEndPoint
        //
        // // Create the mock engine with this vec so we can refer to it later. Once we put the engine
        // // in a box, it is hard to get the vec back out.
        // let calls = Arc::new(Mutex::new(Vec::new()));
        let calls = [String]()
        //
        // // We are going to run two threads to simulate the validator and the driver
        // let mock_engine = MockEngine::with(calls.clone());
        var mockEngine = MockEngine.with(amv: calls)
        //
        // let (driver, stop) = ZmqDriver::new();
        let (driver, stop) = ZmqDriver.new()
        //
        // let driver_thread = thread::spawn(move || driver.start(&addr, mock_engine));
        var driverResult = Result<(), Error>.success(())
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            // let svc = Box::new(MockService {});
            driverResult = Result {
                try driver.start(endpoint: addr, engine: &mockEngine)
            }
            print("DBG_PRINT: testZMQDriver: Driver stopped. Result = \(driverResult)")
            group.leave()
        }
        //
        // let mut response = ConsensusRegisterResponse::new();
        var response = ConsensusRegisterResponse()
        // response.set_status(ConsensusRegisterResponse_Status::OK);
        response.status = .ok
        // let (connection_id, request): (_, ConsensusRegisterRequest) = recv_rep(
        //     &socket,
        //     Message_MessageType::CONSENSUS_REGISTER_REQUEST,
        //     response,
        //     Message_MessageType::CONSENSUS_REGISTER_RESPONSE,
        // );
        let (connectionID, request) = recvRep(
            outputMessageType: ConsensusRegisterRequest.self,
            socket: socket,
            requestType: .consensusRegisterRequest,
            response: response,
            responseType: .consensusRegisterResponse
        )
        // assert!("mock" == request.get_name());
        XCTAssertEqual("mock", request.name)
        // assert!("0" == request.get_version());
        XCTAssertEqual("0", request.version)
        // assert!(
        //     protocols_from_tuples(vec![("1".into(), "Mock".into())])
        //         == request.get_additional_protocols()
        // );
        XCTAssertEqual("Mock", request.additionalProtocols[0].name)
        XCTAssertEqual("1", request.additionalProtocols[0].version)
        print("DBG_PRINT: ZMQDriverTests: register request is ok.")
        //
        // let _: ConsensusNotifyAck = send_req_rep(
        //     &connection_id,
        //     &socket,
        //     ConsensusNotifyEngineActivated::new(),
        //     Message_MessageType::CONSENSUS_NOTIFY_ENGINE_ACTIVATED,
        //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
        // );
        let _ = try! sendReqRep(
            outputMessageType: ConsensusNotifyAck.self,
            connectionID: connectionID,
            socket: socket,
            request: ConsensusNotifyEngineActivated(),
            requestType: .consensusNotifyEngineActivated,
            responseType: .consensusNotifyAck
        )
        //
        // let _: ConsensusNotifyAck = send_req_rep(
        //     &connection_id,
        //     &socket,
        //     ConsensusNotifyPeerConnected::new(),
        //     Message_MessageType::CONSENSUS_NOTIFY_PEER_CONNECTED,
        //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
        // );
        let _ = try! sendReqRep(
            outputMessageType: ConsensusNotifyAck.self,
            connectionID: connectionID,
            socket: socket,
            request: ConsensusNotifyPeerConnected(),
            requestType: .consensusNotifyPeerConnected,
            responseType: .consensusNotifyAck
        )
        //
        // let _: ConsensusNotifyAck = send_req_rep(
        //     &connection_id,
        //     &socket,
        //     ConsensusNotifyPeerDisconnected::new(),
        //     Message_MessageType::CONSENSUS_NOTIFY_PEER_DISCONNECTED,
        //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
        // );
        let _ = try! sendReqRep(
            outputMessageType: ConsensusNotifyAck.self,
            connectionID: connectionID,
            socket: socket,
            request: ConsensusNotifyPeerDisconnected(),
            requestType: .consensusNotifyPeerDisconnected,
            responseType: .consensusNotifyAck
        )
        //
        // let _: ConsensusNotifyAck = send_req_rep(
        //     &connection_id,
        //     &socket,
        //     ConsensusNotifyPeerMessage::new(),
        //     Message_MessageType::CONSENSUS_NOTIFY_PEER_MESSAGE,
        //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
        // );
        let _ = try! sendReqRep(
            outputMessageType: ConsensusNotifyAck.self,
            connectionID: connectionID,
            socket: socket,
            request: ConsensusNotifyPeerMessage(),
            requestType: .consensusNotifyPeerMessage,
            responseType: .consensusNotifyAck
        )
        //
        // let _: ConsensusNotifyAck = send_req_rep(
        //     &connection_id,
        //     &socket,
        //     ConsensusNotifyBlockNew::new(),
        //     Message_MessageType::CONSENSUS_NOTIFY_BLOCK_NEW,
        //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
        // );
        let _ = try! sendReqRep(
            outputMessageType: ConsensusNotifyAck.self,
            connectionID: connectionID,
            socket: socket,
            request: ConsensusNotifyBlockNew(),
            requestType: .consensusNotifyBlockNew,
            responseType: .consensusNotifyAck
        )
        //
        // let _: ConsensusNotifyAck = send_req_rep(
        //     &connection_id,
        //     &socket,
        //     ConsensusNotifyBlockValid::new(),
        //     Message_MessageType::CONSENSUS_NOTIFY_BLOCK_VALID,
        //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
        // );
        let _ = try! sendReqRep(
            outputMessageType: ConsensusNotifyAck.self,
            connectionID: connectionID,
            socket: socket,
            request: ConsensusNotifyBlockValid(),
            requestType: .consensusNotifyBlockValid,
            responseType: .consensusNotifyAck
        )
        //
        // let _: ConsensusNotifyAck = send_req_rep(
        //     &connection_id,
        //     &socket,
        //     ConsensusNotifyBlockInvalid::new(),
        //     Message_MessageType::CONSENSUS_NOTIFY_BLOCK_INVALID,
        //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
        // );
        let _ = try! sendReqRep(
            outputMessageType: ConsensusNotifyAck.self,
            connectionID: connectionID,
            socket: socket,
            request: ConsensusNotifyBlockInvalid(),
            requestType: .consensusNotifyBlockInvalid,
            responseType: .consensusNotifyAck
        )
        //
        // let _: ConsensusNotifyAck = send_req_rep(
        //     &connection_id,
        //     &socket,
        //     ConsensusNotifyBlockCommit::new(),
        //     Message_MessageType::CONSENSUS_NOTIFY_BLOCK_COMMIT,
        //     Message_MessageType::CONSENSUS_NOTIFY_ACK,
        // );
        let _ = try! sendReqRep(
            outputMessageType: ConsensusNotifyAck.self,
            connectionID: connectionID,
            socket: socket,
            request: ConsensusNotifyBlockCommit(),
            requestType: .consensusNotifyBlockCommit,
            responseType: .consensusNotifyAck
        )
        //
        // // Shut it down
        // stop.stop();
        try! stop.stop()
        // driver_thread
        //     .join()
        //     .expect("Driver thread panicked")
        //     .expect("Driver thread returned an error");
        group.wait()
        if case .failure(let error) = driverResult {
            XCTFail("driver thread panicked with error \(error)")
        }
        //
        // // Assert we did what we expected
        // let final_calls = calls.lock().unwrap();
        // assert!(contains(&*final_calls, "start"));
        // assert!(contains(&*final_calls, "PeerConnected"));
        // assert!(contains(&*final_calls, "PeerDisconnected"));
        // assert!(contains(&*final_calls, "PeerMessage"));
        // assert!(contains(&*final_calls, "BlockNew"));
        // assert!(contains(&*final_calls, "BlockValid"));
        // assert!(contains(&*final_calls, "BlockInvalid"));
        // assert!(contains(&*final_calls, "BlockCommit"));
        XCTAssertTrue(mockEngine.currentCalls.contains("start"))
        XCTAssertTrue(mockEngine.currentCalls.contains("PeerConnected"))
        XCTAssertTrue(mockEngine.currentCalls.contains("PeerDisconnected"))
        XCTAssertTrue(mockEngine.currentCalls.contains("PeerMessage"))
        XCTAssertTrue(mockEngine.currentCalls.contains("BlockNew"))
        XCTAssertTrue(mockEngine.currentCalls.contains("BlockValid"))
        XCTAssertTrue(mockEngine.currentCalls.contains("BlockInvalid"))
        XCTAssertTrue(mockEngine.currentCalls.contains("BlockCommit"))
    }
    // }
    //
    // fn contains(calls: &Vec<String>, expected: &str) -> bool {
    //     for call in calls {
    //         if expected == call.as_str() {
    //             return true;
    //         }
    //     }
    //     false
    // }
    // }
    static var allTests = [
        ("testExample", testExample),
        ("testZMQDriver", testZMQDriver)
    ]
}
