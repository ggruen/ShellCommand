// Generated using Sourcery 0.10.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest
@testable import ShellCommandTests

extension ShellCommandTests {
  static var allTests = [
    ("testRunsEcho", testRunsEcho),
    ("testOutputsToStderr", testOutputsToStderr),
    ("testCurrentDirectorySetsAsSpecified", testCurrentDirectorySetsAsSpecified),
    ("testThrowsNoArgumentError", testThrowsNoArgumentError),
    ("testRunsSingleStringCommand", testRunsSingleStringCommand),
    ("testRunStaticMethod", testRunStaticMethod),
    ("testRunStaticSendToIo", testRunStaticSendToIo),
    ("testNoShellInterpolation", testNoShellInterpolation),
    ("testPerformanceExample", testPerformanceExample),
  ]
}


XCTMain([
  testCase(ShellCommandTests.allTests),
])
