//
//  TransactionProcessorTests.swift
//  sawtooth-sdk-swiftTests
//
//  Created by Teaching on 14/8/19.
//

import XCTest
@testable import sawtooth_sdk_swift
import struct sawtooth_sdk_swift.Message
import SwiftProtobuf
import SwiftZMQ

class DummyValidator {
    func start(tests: [(String, (Socket, Data)->())]) {
        // create a listening message queue
        let ctx = Context()
        let socket = try! ctx.socket(type: .router)
        try! socket.bind(endpoint: "tcp://127.0.0.1:5554")
        // listen for messages, and respond appropriately
        let connectionID: Data
        do {
            let parts = try! socket.receiveMultipart()
            // This should be a TpRegisterRequest
            connectionID = parts[0]
            let message = try! Message(serializedData: parts[1])
            XCTAssertEqual(.tpRegisterRequest, message.messageType)
            var responseContent = TpRegisterResponse()
            responseContent.status = .ok
            var responseMessage = Message()
            responseMessage.correlationID = message.correlationID
            responseMessage.messageType = .tpRegisterResponse
            responseMessage.content = try! responseContent.serializedData()
            let response = try! responseMessage.serializedData()
            try! socket.sendMultipart([parts[0], response])
        }
        for (testName, test) in tests {
            test(socket, connectionID)
            print("\(testName) passed.")
        }
    }
}

class DummyTransactionHandler: TransactionHandler {
    var familyName: String { return "dummy" }
    
    var familyVersions: [String] { return ["1.0"] }
    
    var namespaces: [String] { return [""] }
    
    func apply(request: TpProcessRequest, context: inout TransactionContext) throws {
        let command = String(data: request.payload, encoding: .utf8)!
        if command == "succeed" {
            return
        } else if command == "fail" {
            throw ApplyError.invalidTransaction("failed")
        } else {
            throw ApplyError.internalError("threw")
        }
    }
}

class TransactionProcessorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTransactionProcessor() {
        // Start the validator in a background thread
        let validatorGroup = DispatchGroup()
        validatorGroup.enter()
        DispatchQueue.global(qos: .background).async {
            DummyValidator().start(tests: [
                ("Ping test", { (socket, connectionID) in
                    var message = Message()
                    message.messageType = .pingRequest
                    let messageContent = PingRequest()
                    message.content = try! messageContent.serializedData()
                    message.correlationID = generateCorrelationID()
                    try! socket.sendMultipart([connectionID, message.serializedData()])
                    let parts = try! socket.receiveMultipart()
                    XCTAssert(parts.count == 2)
                    let response = try! Message(serializedData: parts[1])
                    XCTAssert(response.messageType == .pingResponse)
                }),
                ("Invalid message test", { (socket, connectionID) in
                    var message = Message()
                    message.messageType = .clientPeersGetRequest
                    message.correlationID = generateCorrelationID()
                    message.content = try! ClientPeersGetRequest().serializedData()
                    try! socket.sendMultipart([connectionID, message.serializedData()])
                    // Note: the rust sdk doesn't respond to invalid messages, hanging the sender!:
                    let parts = try! socket.receiveMultipart()
                    XCTAssertEqual(2, parts.count)
                    let response = try! Message(serializedData: parts[1])
                    XCTAssertEqual(.tpProcessResponse, response.messageType)
                    let responseContent = try! TpProcessResponse(serializedData: response.content)
                    XCTAssertEqual(.invalidTransaction, responseContent.status)
                }),
                ("Handler succeeds", { (socket, connectionID) in
                    var message = Message()
                    message.messageType = .tpProcessRequest
                    message.correlationID = generateCorrelationID()
                    var messageContent = TpProcessRequest()
                    messageContent.contextID = "dummy"
                    messageContent.payload = "succeed".data(using: .utf8)!
                    message.content = try! messageContent.serializedData()
                    try! socket.sendMultipart([connectionID, message.serializedData()])
                    let parts = try! socket.receiveMultipart()
                    XCTAssertEqual(2, parts.count)
                    let response = try! Message(serializedData: parts[1])
                    XCTAssertEqual(.tpProcessResponse, response.messageType)
                    let responseContent = try! TpProcessResponse(serializedData: response.content)
                    XCTAssertEqual(.ok, responseContent.status)
                }),
                ("Handler fails", { (socket, connectionID) in
                    var message = Message()
                    message.messageType = .tpProcessRequest
                    message.correlationID = generateCorrelationID()
                    var messageContent = TpProcessRequest()
                    messageContent.contextID = "dummy"
                    messageContent.payload = "fail".data(using: .utf8)!
                    message.content = try! messageContent.serializedData()
                    try! socket.sendMultipart([connectionID, message.serializedData()])
                    let parts = try! socket.receiveMultipart()
                    XCTAssertEqual(2, parts.count)
                    let response = try! Message(serializedData: parts[1])
                    XCTAssertEqual(.tpProcessResponse, response.messageType)
                    let responseContent = try! TpProcessResponse(serializedData: response.content)
                    XCTAssertEqual(.invalidTransaction, responseContent.status)
                }),
                ("Handler throws", { (socket, connectionID) in
                    var message = Message()
                    message.messageType = .tpProcessRequest
                    message.correlationID = generateCorrelationID()
                    var messageContent = TpProcessRequest()
                    messageContent.contextID = "dummy"
                    messageContent.payload = "throw".data(using: .utf8)!
                    message.content = try! messageContent.serializedData()
                    try! socket.sendMultipart([connectionID, message.serializedData()])
                    let parts = try! socket.receiveMultipart()
                    XCTAssertEqual(2, parts.count)
                    let response = try! Message(serializedData: parts[1])
                    XCTAssertEqual(.tpProcessResponse, response.messageType)
                    let responseContent = try! TpProcessResponse(serializedData: response.content)
                    XCTAssertEqual(.internalError, responseContent.status)
                })
                ])
            validatorGroup.leave()
        }
        // Initialize the Transaction Processor
        let transactionProcessor = TransactionProcessor(endpoint: "tcp://127.0.0.1:5554")
        // Add a dummy Transaction Handler
        let transactionHandler = DummyTransactionHandler()
        transactionProcessor.addHandler(handler: transactionHandler)
        // start the transaction process in a background thread
        DispatchQueue.global(qos: .background).async {
            transactionProcessor.start()
        }
        // wait for the validator to run through its exercises
        validatorGroup.wait()
    }
}
