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
        let output = (command.io as! CapturedIO).stdout
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
        let output = (command.io as! CapturedIO).stderr
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

    /// Given: Single string command instead of array
    /// When: run() is called
    /// Then: Command is executed with /bin/bash -c
    func testRunsSingleStringCommand() throws {
        // Given
        let commandString = "echo \"hello error\" >&2"
        let command = ShellCommand()
        command.io = CapturedIO()

        // When
        try command.run(commandString)

        // Then
        let output = (command.io as! CapturedIO).stderr
            .trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(output, "hello error", "Command output \"hello error\"")
    }

    /// Given: Command string or array
    /// When: ShellCommand.run(string) is called
    /// Then: Command runs as if you'd called command.run(string)
    func testRunStaticMethod() throws {
        // Given
        let commandString = "echo \"hello file\" > /tmp/static_test_file"

        // When
        try ShellCommand.run(commandString)

        // Then
        let fileContents = try String(
            contentsOfFile: "/tmp/static_test_file")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        try FileManager.default.removeItem(atPath: "/tmp/static_test_file")
        XCTAssertEqual(fileContents, "hello file", "Static run created file in /tmp")
    }

    /// Given: command string and IO object
    /// When: ShellCommand.run( command: commandString, io: customIO )
    /// Then: Command runs
    ///       STDOUT appears in customIO
    ///       STDERR appears in customIO
    func testRunStaticSendToIo() throws {
        // Given
        let commandString = "echo \"hello stderr\" >&2 && echo \"hello stdout\""
        let io = CapturedIO()

        // When
        XCTAssertNoThrow( try ShellCommand.run(commandString, io: io), "Static run with IO didn't throw an error" )

        // Then
        let stdout = io.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(stdout, "hello stdout", "Command output \"hello stdout\" to STDOUT")
        let stderr = io.stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(stderr, "hello stderr", "Command output \"hello stderr\" to STDERR")
    }

    /// Given: Command String array with dangerous shell characters
    /// When: passed to command.run
    /// Then: characters are taken literally, not interpreted by a shell
    func testNoShellInterpolation() throws {
        // Given
        let commandArray = [ "/bin/echo", "*", ";", "echo \"ack\"" ]
        let command = ShellCommand()
        command.io = CapturedIO()

        // When
        XCTAssertNoThrow( try command.run(commandArray), "Command didn't throw an error" )

        // Then
        let output = (command.io as! CapturedIO).stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(output, "* ; echo \"ack\"", "String array wasn't interpolated by a shell")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
