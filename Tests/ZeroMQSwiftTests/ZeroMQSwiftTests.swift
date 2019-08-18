import XCTest
@testable import ZeroMQSwift

let POLL_TIMEOUT = 10

final class SwiftZMQTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftZMQ().text, "Hello, World!")
    }
    func server(context: Context) {
        //let responder = zmq_socket(context, /*ZMQ_REP*/ZMQ_ROUTER)!
        let responder = try! context.socket(type: .router)
        //let rc = zmq_bind(responder, "tcp://*:5555")
        try! responder.bind(endpoint: "tcp://*:5555")
        while true {
            //var poll_items = [
            //    zmq_pollitem_t(
            //        socket: responder,
            //        fd: 0,
            //        events: Int16(ZMQ_POLLIN),
            //        revents: 0
            //    )
            //]
            let poller = Poller()
            poller.add(socket: responder, events: .pollIn)
            // zmq::poll(&mut poll_items, POLL_TIMEOUT).unwrap();
            //let pollResult = poll_items.withUnsafeMutableBufferPointer { (unsafeMutableBufferPointer: inout UnsafeMutableBufferPointer<zmq_pollitem_t>) -> Int32 in
            //    zmq_poll(unsafeMutableBufferPointer.baseAddress, 1, Int(POLL_TIMEOUT))
            //}
            let pollResult = poller.waitAny(timeout: Int(POLL_TIMEOUT))
            print("DBG_PRINT: SendReceiveStream.run: Received poll items \(pollResult)")
            if pollResult.hasPollIn(for: responder) {
                let receiptData = try! responder.receiveMultipart()
                print("Received \(receiptData.count) data items.")
                let p = String(data: receiptData[0], encoding: .utf8) ?? "0x" + receiptData[0].map { (byte) -> String in
                    String(format:"%02x", byte)
                    }.joined(separator: "")
                print("Id is \(p)")
                let msg = String(data: receiptData[2], encoding: .utf8)!
                print("Msg is \(msg)")
                try! responder.sendMultipart([
                    receiptData[0],
                    Data(),
                    "World!".data(using: .utf8)!
                    ]
                )
            } else {
                sleep(1)
            }
        }
    }
    
    func client(context: Context) {
        //let requester = zmq_socket(context, /*ZMQ_REQ*/ZMQ_DEALER)!
        let requester = try! context.socket(type: .dealer)
        //setSocketID(socket: requester, id: UUID().uuidString)
        requester.identity = UUID().uuidString
        //zmq_connect(requester, "tcp://localhost:5555")
        try! requester.connect(endpoint: "tcp://localhost:5555")
        for requestNbr in 0..<10 {
            //var buffer = Data(count: 10)
            print("Client sending Hello \(requestNbr)...")
            //zmq_send(requester, "", 0, ZMQ_SNDMORE)
            try! requester.send("", sendmore: true)
            //zmq_send(requester, "Hello,", 6, 0)
            try! requester.send("Hello")
            //let _ = receiveMultipartMessage(socket: requester)
            let _ = try! requester.receiveMultipart()
            print("Client received World \(requestNbr)")
        }
        //zmq_close(requester)
        requester.disconnect(endpoint: "tcp://localhost:5555")
    }
    

    func testSendReceive() {
        //let context = zmq_ctx_new()!
        let context = Context()
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            self.server(context: context)
        }
        client(context: context)
    }
    
    func testPollPair() {
    }

    static var allTests = [
        ("testExample", testExample),
        ("testSendReceive", testSendReceive)
    ]
}
