//
//  ShellCommandTests.swift
//  ShellCommand
//

import Foundation
import XCTest
#if SWIFT_PACKAGE
@testable import ShellCommandCore
#endif

class ShellCommandTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of
        // each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation
        // of each test method in the class.
        super.tearDown()
    }

    /**
     * TDD Tests - e.g.:
     * - given:
         - let commandString = ["echo", "hello", "world"]
         - command.io = CapturedIO()
         - let command = ShellCommand()
     - when: command.run(commandString)
     - then:
         - "hello world" is sent to STDOUT
     */
    func testRunsEcho() throws {
        // Given
        let commandString = ["/bin/echo", "hello", "world"]
        let command = ShellCommand()
        command.io = CapturedIO()

        // When
        try command.run(commandString)

        // Then
        let output = (command.io as! CapturedIO).queuedStdout
            .trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(output, "hello world", "Command output \"hello world\"")
    }

    /*
     - given: Command that outputs "hello error" to STDERR

     - when: command.run(commandThatOutputsToStderr)

     - then:
     - STDERR contains "hello error"
    */
    func testOutputsToStderr() {
        // Given
        let commandString = ["/bin/bash", "-c", "echo \"hello error\" >&2"]
        let command = ShellCommand()
        command.io = CapturedIO()

        // When
        XCTAssertNoThrow(try command.run(commandString),
                         "Command didn't throw an error")

        // Then
        let output = (command.io as! CapturedIO).queuedStderr
            .trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(output, "hello error", "Command output \"hello error\"")
    }

    /// Given: currentDirectoryPath set to /tmp
    /// When: Command outputs a file to current directory
    /// Then: The file appears in /tmp
    func testCurrentDirectorySetsAsSpecified() throws {
        // Given
        let commandString = ["/bin/bash", "-c", "echo \"hello file\" > thisisatestfileblah"]
        let command = ShellCommand()
        command.currentDirectoryPath = "/tmp"

        // When
        XCTAssertNoThrow(try command.run(commandString),
                         "Command didn't throw an error")

        // Then
        let fileContents = try String(
            contentsOfFile: "/tmp/thisisatestfileblah")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        try FileManager.default.removeItem(atPath: "/tmp/thisisatestfileblah")
        XCTAssertEqual(fileContents, "hello file", "Command created file in /tmp")
    }

    /// Given: No command or arguments passed
    /// When: run is called
    /// Then: a .noArgumentsPassed error is thrown
    func testThrowsNoArgumentError() {
        // Given
        let command = ShellCommand()

        // When
        do {
            try command.run([""])
            XCTFail("Command throws an exception when no arguments passed")
        } catch ShellCommand.Error.noArgumentsPassed {
            XCTAssertTrue(true, "Command throws an exception when no arguments passed")
        } catch let e {
            XCTFail("Command threw incorrect error \(e)")
        }

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
