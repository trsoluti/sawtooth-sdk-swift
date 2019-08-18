//
//  ZMQServiceTests.swift
//  sawtooth-sdk-swiftTests
//
//  Created by Teaching on 24/7/19.
//

import XCTest
@testable import SawtoothSDKSwift
import struct SawtoothSDKSwift.Message
import SwiftProtobuf
import SwiftZMQ

class ZMQServiceTests: XCTestCase {

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
    // use messages::validator::Message;
    // use messaging::stream::MessageConnection;
    // use messaging::zmq_stream::ZmqMessageConnection;
    // use protobuf::Message as ProtobufMessage;
    // use std::default::Default;
    // use std::thread;
    // use zmq;
    //
    // fn recv_rep<I: protobuf::Message, O: protobuf::Message>(
    func recvRep<I: SwiftProtobuf.Message, O: SwiftProtobuf.Message>(
        outputMessageType: O.Type,
        // socket: &zmq::Socket,
        socket: Socket,
        // request_type: Message_MessageType,
        requestType: Message.MessageType,
        // response: I,
        response: I,
        // response_type: Message_MessageType,
        responseType: Message.MessageType,
        receiver: String
    ) -> (Data, O) {
    // ) -> (Vec<u8>, O) {
        // let mut parts = socket.recv_multipart(0).unwrap();
        //let parts = receiveMultipartMessage(socket: socket, receiver: receiver)
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
        //try! sendMultipartMessage(socket: socket, parts: [connectionID, responseMsg.serializedData()], sender: receiver)
        try! socket.sendMultipart([connectionID, responseMsg.serializedData()])
        //
        // (connection_id, request)
        return (connectionID, request)
    }
    // }
    //
    // macro_rules! service_test {
    //     (
    //         $socket:expr,
    //         $rep:expr,
    //         $status:expr,
    //         $rep_msg_type:expr,
    //         $req_type:ty,
    //         $req_msg_type:expr
    //     ) => {
    //         let mut response = $rep;
    //         response.set_status($status);
    //         let (_, _): (_, $req_type) = recv_rep($socket, $req_msg_type, response, $rep_msg_type);
    //     };
    // }
    //
    // #[test]
    // fn test_zmq_service() {
    func testZMQService() {
        // let ctx = zmq::Context::new();
        //let ctx = zmq_ctx_new()!
        let ctx = Context()
        // let socket = ctx.socket(zmq::ROUTER).expect("Failed to create context");
        //let socket = zmq_socket(ctx, ZMQ_ROUTER)!
        let socket = try! ctx.socket(type: .router)
        // socket
        //     .bind("tcp://127.0.0.1:*")
        //     .expect("Failed to bind socket");
        //let _ = zmq_bind(socket, "tcp://127.0.0.1:*")
        try! socket.bind(endpoint: "tcp://127.0.0.1:*")
        // let addr = socket.get_last_endpoint().unwrap().unwrap();
        //var addrData = Data(capacity: 255)
        //var size:Int = 254
        //let addr = addrData.withUnsafeMutableBytes { (buffer) -> String in
        //    zmq_getsockopt(
        //        socket,
        //        ZMQ_LAST_ENDPOINT,
        //        buffer.baseAddress!,
        //        &size)
        //    let data = Data(bytes: buffer.baseAddress!, count: size)
        //    return String(data: data, encoding: .utf8)!
        //}
        let addr = socket.lastEndPoint
        //
        // let svc_thread = thread::spawn(move || {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            // let connection = ZmqMessageConnection::new(&addr);
            let connection = ZmqMessageConnection(address: addr)
            // let (sender, _) = connection.create();
            let (sender, _) = connection.create()
            // let mut svc = ZmqService::new(sender, Duration::from_secs(10));
            let svc = ZmqService(sender: sender, timeout: Duration(10*1000))
            //
            // svc.send_to(&Default::default(), Default::default(), Default::default())
            //     .unwrap();
            try! svc.sendTo(peer: PeerId.defaultValue, messageType: "", payload: [])
            // svc.broadcast(Default::default(), Default::default())
            //     .unwrap();
            try! svc.broadcast(messageType: "", payload: [])
            //
            // svc.initialize_block(Some(Default::default())).unwrap();
            try! svc.initializeBlock(previousID: BlockId.defaultValue)
            // svc.summarize_block().unwrap();
            let _ = try! svc.summarizeBlock()
            // svc.finalize_block(Default::default()).unwrap();
            let _ = try! svc.finalizeBlock(data: [UInt8].defaultValue)
            // svc.cancel_block().unwrap();
            try! svc.cancelBlock()
            //
            // svc.check_blocks(Default::default()).unwrap();
            try! svc.checkBlocks(priority: [BlockId.defaultValue])
            // svc.commit_block(Default::default()).unwrap();
            try! svc.commitBlock(blockID: BlockId.defaultValue)
            // svc.ignore_block(Default::default()).unwrap();
            try! svc.ignoreBlock(blockID: BlockId.defaultValue)
            // svc.fail_block(Default::default()).unwrap();
            try! svc.failBlock(blockID: BlockId.defaultValue)
            //
            // svc.get_blocks(Default::default()).unwrap();
            let _ = try! svc.getBlocks(blockIDs: [BlockId.defaultValue])
            // svc.get_settings(Default::default(), Default::default())
            //     .unwrap();
            let _ = try! svc.getSettings(blockID: BlockId.defaultValue, keys: [])
            // svc.get_state(Default::default(), Default::default())
            //     .unwrap();
            let _ = try! svc.getState(blockID: BlockId.defaultValue, addresses: [])
            // svc.get_chain_head().unwrap();
            let _ = try! svc.getChainHead()
            //zmq_close(socket)
            //zmq_ctx_destroy(ctx)
            group.leave()
        }
        // });
        //
        // service_test!(
        //     &socket,
        //     ConsensusSendToResponse::new(),
        //     ConsensusSendToResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_SEND_TO_RESPONSE,
        //     ConsensusSendToRequest,
        //     Message_MessageType::CONSENSUS_SEND_TO_REQUEST
        // );
        // macro_rules! service_test {
        //     (
        //         $socket:expr, // &socket
        //         $rep:expr,    // ConsensusSendToResponse::new()
        //         $status:expr, // ConsensusSendToResponse_Status::OK
        //         $rep_msg_type:expr, // Message_MessageType::CONSENSUS_SEND_TO_RESPONSE
        //         $req_type:ty,       // ConsensusSendToRequest
        //         $req_msg_type:expr  // Message_MessageType::CONSENSUS_SEND_TO_REQUEST
        //     ) => {
        //         let mut response = $rep;
        //         response.set_status($status);
        //         let (_, _): (_, $req_type) = recv_rep($socket, $req_msg_type, response, $rep_msg_type);
        //     };
        // }
        do {
            var response = ConsensusSendToResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusSendToRequest.self,
                socket: socket,
                requestType: .consensusSendToRequest,
                response: response,
                responseType: .consensusSendToResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusBroadcastResponse::new(),
        //     ConsensusBroadcastResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_BROADCAST_RESPONSE,
        //     ConsensusBroadcastRequest,
        //     Message_MessageType::CONSENSUS_BROADCAST_REQUEST
        // );
        do {
        var response = ConsensusBroadcastResponse()
        response.status = .ok
        let (_, _) = recvRep(
            outputMessageType: ConsensusBroadcastRequest.self,
            socket: socket,
            requestType: .consensusBroadcastRequest,
            response: response,
            responseType: .consensusBroadcastResponse,
            receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusInitializeBlockResponse::new(),
        //     ConsensusInitializeBlockResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_INITIALIZE_BLOCK_RESPONSE,
        //     ConsensusInitializeBlockRequest,
        //     Message_MessageType::CONSENSUS_INITIALIZE_BLOCK_REQUEST
        // );
        do {
            var response = ConsensusInitializeBlockResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusInitializeBlockRequest.self,
                socket: socket,
                requestType: .consensusInitializeBlockRequest,
                response: response,
                responseType: .consensusInitializeBlockResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusSummarizeBlockResponse::new(),
        //     ConsensusSummarizeBlockResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_SUMMARIZE_BLOCK_RESPONSE,
        //     ConsensusSummarizeBlockRequest,
        //     Message_MessageType::CONSENSUS_SUMMARIZE_BLOCK_REQUEST
        // );
        do {
            var response = ConsensusSummarizeBlockResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusSummarizeBlockRequest.self,
                socket: socket,
                requestType: .consensusSummarizeBlockRequest,
                response: response,
                responseType: .consensusSummarizeBlockResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusFinalizeBlockResponse::new(),
        //     ConsensusFinalizeBlockResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_FINALIZE_BLOCK_RESPONSE,
        //     ConsensusFinalizeBlockRequest,
        //     Message_MessageType::CONSENSUS_FINALIZE_BLOCK_REQUEST
        // );
        do {
            var response = ConsensusFinalizeBlockResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusFinalizeBlockRequest.self,
                socket: socket,
                requestType: .consensusFinalizeBlockRequest,
                response: response,
                responseType: .consensusFinalizeBlockResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusCancelBlockResponse::new(),
        //     ConsensusCancelBlockResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_CANCEL_BLOCK_RESPONSE,
        //     ConsensusCancelBlockRequest,
        //     Message_MessageType::CONSENSUS_CANCEL_BLOCK_REQUEST
        // );
        do {
            var response = ConsensusCancelBlockResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusCancelBlockRequest.self,
                socket: socket,
                requestType: .consensusCancelBlockRequest,
                response: response,
                responseType: .consensusCancelBlockResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusCheckBlocksResponse::new(),
        //     ConsensusCheckBlocksResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_CHECK_BLOCKS_RESPONSE,
        //     ConsensusCheckBlocksRequest,
        //     Message_MessageType::CONSENSUS_CHECK_BLOCKS_REQUEST
        // );
        do {
            var response = ConsensusCheckBlocksResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusCheckBlocksRequest.self,
                socket: socket,
                requestType: .consensusCheckBlocksRequest,
                response: response,
                responseType: .consensusCheckBlocksResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusCommitBlockResponse::new(),
        //     ConsensusCommitBlockResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_COMMIT_BLOCK_RESPONSE,
        //     ConsensusCommitBlockRequest,
        //     Message_MessageType::CONSENSUS_COMMIT_BLOCK_REQUEST
        // );
        do {
            var response = ConsensusCommitBlockResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusCommitBlockRequest.self,
                socket: socket,
                requestType: .consensusCommitBlockRequest,
                response: response,
                responseType: .consensusCommitBlockResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusIgnoreBlockResponse::new(),
        //     ConsensusIgnoreBlockResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_IGNORE_BLOCK_RESPONSE,
        //     ConsensusIgnoreBlockRequest,
        //     Message_MessageType::CONSENSUS_IGNORE_BLOCK_REQUEST
        // );
        do {
            var response = ConsensusIgnoreBlockResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusIgnoreBlockRequest.self,
                socket: socket,
                requestType: .consensusIgnoreBlockRequest,
                response: response,
                responseType: .consensusIgnoreBlockResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusFailBlockResponse::new(),
        //     ConsensusFailBlockResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_FAIL_BLOCK_RESPONSE,
        //     ConsensusFailBlockRequest,
        //     Message_MessageType::CONSENSUS_FAIL_BLOCK_REQUEST
        // );
        do {
            var response = ConsensusFailBlockResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusFailBlockRequest.self,
                socket: socket,
                requestType: .consensusFailBlockRequest,
                response: response,
                responseType: .consensusFailBlockResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusBlocksGetResponse::new(),
        //     ConsensusBlocksGetResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_BLOCKS_GET_RESPONSE,
        //     ConsensusBlocksGetRequest,
        //     Message_MessageType::CONSENSUS_BLOCKS_GET_REQUEST
        // );
        do {
            var response = ConsensusBlocksGetResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusBlocksGetRequest.self,
                socket: socket,
                requestType: .consensusBlocksGetRequest,
                response: response,
                responseType: .consensusBlocksGetResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusSettingsGetResponse::new(),
        //     ConsensusSettingsGetResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_SETTINGS_GET_RESPONSE,
        //     ConsensusSettingsGetRequest,
        //     Message_MessageType::CONSENSUS_SETTINGS_GET_REQUEST
        // );
        do {
            var response = ConsensusSettingsGetResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusSettingsGetRequest.self,
                socket: socket,
                requestType: .consensusSettingsGetRequest,
                response: response,
                responseType: .consensusSettingsGetResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusStateGetResponse::new(),
        //     ConsensusStateGetResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_STATE_GET_RESPONSE,
        //     ConsensusStateGetRequest,
        //     Message_MessageType::CONSENSUS_STATE_GET_REQUEST
        // );
        do {
            var response = ConsensusStateGetResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusStateGetRequest.self,
                socket: socket,
                requestType: .consensusStateGetRequest,
                response: response,
                responseType: .consensusStateGetResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // service_test!(
        //     &socket,
        //     ConsensusChainHeadGetResponse::new(),
        //     ConsensusChainHeadGetResponse_Status::OK,
        //     Message_MessageType::CONSENSUS_CHAIN_HEAD_GET_RESPONSE,
        //     ConsensusChainHeadGetRequest,
        //     Message_MessageType::CONSENSUS_CHAIN_HEAD_GET_REQUEST
        // );
        do {
            var response = ConsensusChainHeadGetResponse()
            response.status = .ok
            let (_, _) = recvRep(
                outputMessageType: ConsensusChainHeadGetRequest.self,
                socket: socket,
                requestType: .consensusChainHeadGetRequest,
                response: response,
                responseType: .consensusChainHeadGetResponse,
                receiver: "ZMQServiceTest")
        }
        //
        // svc_thread.join().unwrap();
        group.wait()
        //zmq_close(socket)
        //zmq_ctx_destroy(ctx)
    }
    // }
    // }
    static var allTests = [
        ("testExample", testExample),
        ("testZMQService", testZMQService)
    ]
}
