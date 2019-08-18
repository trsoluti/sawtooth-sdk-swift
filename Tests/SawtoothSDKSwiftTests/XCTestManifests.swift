import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SawtoothSDKSwiftTests.allTests),
        testCase(StreamTests.allTests),
        testCase(ZMQDriverTests.allTests),
        testCase(ZMQServiceTests.allTests),
        testCase(EngineTests.allTests)
    ]
}
#endif
