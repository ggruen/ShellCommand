//
//  ShellCommand.swift
//  SwiftStarterCore
//
//  Created by Grant Grueninger on 1/2/18.
//

import Foundation

/**
 Represents a shell command and provides a means to run and redirect the output of a shell command.

     let command = ShellCommand()
     // Optional: defaults to current directory
     command.currentDirectoryPath = "/somewhere/else"
     // Optional, Implement your own class to catch what's sent to "writeMessage"
     command.io = MockConsoleIO()
     try command.run(["/bin/echo", "hello", "world"])
     try command.run(["/usr/bin/git", "add", "-A"])
     try command.run(["/usr/bin/git", "commit", "-m", "Broke everything"])

 Pass `run` a String and it'll run it with `bash`:

     // Send "hello world" to STDERR
     try command.run("echo \"hello world\" >&2")

 Quick-run convenience static methods:

     // Initialize and call run with a single string. Command is passed to
     // /bin/bash -c. Handy both for shorthand and for redirects.
     try ShellCommand.run("echo \"hello world!\" > /tmp/somefile")

     // This will send to STDERR.
     try ShellCommand.run("echo \"hello world!\" >&2")

     // Add a custom ConsoleIOProtocol object to capture output
     let output = CapturedIO()
     try ShellCommand.run("echo \"hello world!\" >&2", io: output)
     print( output.stderr ) // Prints "hello world!"

 */
open class ShellCommand {

    enum Error: Swift.Error {
        // Shell command exited with non-zero exit status
        case shellCommandFailed( _: String )
        // No, or empty, command passed to run()
        case noArgumentsPassed( _: String )
    }

    /// A ConsoleIOProtocol object, used to write output to STDOUT or STDERR by default.
    /// You can replace this with a different class that implements ConsoleIOProtocol to capture the output.
    /// The unit tests replace this with a MockConsoleIO object, for example.
    open var io: ConsoleIOProtocol

    /**
     The path in which the command should run. Setting this before calling runAndWait
     will cause the command to run in the directory you specify. The current directory of
     the parent process (i.e. your application) will not be affected.

     Example:

        // This will put "hello world" into /Users/joe/git/hi_there
        let command = ShellCommand()
        command.currentDirectoryPath = "/Users/joe/git"
        try command.runAndWait( [ "/usr/bin/bash", "-c", "echo", "hello", "world", ">", "hi_there" ] )
    */
    open var currentDirectoryPath: String

    public init() {
        self.io = ConsoleIO()
        self.currentDirectoryPath = FileManager.default.currentDirectoryPath
    }

    /**
     * Runs a shell command in projectDir and waits for the result.
     * Sends output through the `io` property.
     *
     * - parameter commandArgs: Array of strings making up the command. e.g. ["/usr/bin/swift", "package", "update" ]
     * - throws: `.shellCommandFailed(commandArgs)` if command returns non-zero exit status
     */
    open func run( _ commandArgs: [String] ) throws -> Void {
        guard commandArgs.count > 0, !commandArgs[0].isEmpty else {
            throw Error.noArgumentsPassed(commandArgs.joined(separator: " "))
        }

        let process = Process()

        // Specify the directory in which the command should run
        process.currentDirectoryPath = self.currentDirectoryPath

        // First get the command
        process.launchPath = commandArgs[0]
        if commandArgs.count > 1 {
            // Then any arguments
            process.arguments = commandArgs
            process.arguments?.remove(at: 0) // Remove the command
        }

        // Capture STDOUT so we can test it
        let stdOut = Pipe()
        let stdErr = Pipe()
        process.standardOutput = stdOut
        process.standardError = stdErr

        // Run the command and wait
        process.launch()
        process.waitUntilExit()

        // Send the output wherever it needs to go
        let errorOutput = stdErr.fileHandleForReading.availableData
        if let errorOutput = String(data: errorOutput, encoding: .utf8) {
            io.writeMessage(message: errorOutput, to: .error)
        }

        let scriptOutput = stdOut.fileHandleForReading.availableData
        if let stringOutput = String(data: scriptOutput, encoding: .utf8) {
            io.writeMessage(message: stringOutput, to: .standard)
        }

        // Throw an error on non-zero exit status
        if process.terminationStatus != 0 {
            throw Error.shellCommandFailed(commandArgs.joined(separator: " "))
        }

    }

    /// Convenience method that allows you to pass a single-string command to
    /// bash.
    ///
    /// Example:
    ///
    ///     // Say hello to STDERR
    ///     command.run("echo \"hello world\" >&2")
    ///
    /// - parameter command: A string containing a bash shell command string
    /// - throws: `Error.shellCommandFailed` if the underlying command returns a non-zero exit code
    /// - throws: `Error.noArgumentsPassed` if called with an empty string
    ///
    open func run( _ command: String ) throws -> Void {
        guard !command.isEmpty else {
            throw Error.noArgumentsPassed(command)
        }

        try self.run( [ "/bin/bash", "-c", command ])
    }

    /// Comvenience static run method. Instantiates a default ShellCommand object and runs the passed command
    /// using `/bin/bash -c`.
    ///
    /// Example:
    ///
    ///     ShellCommand.run("echo \"hello world\"")
    ///
    /// - parameter command: A string containing a bash shell command string
    /// - throws: `Error.shellCommandFailed` if the underlying command returns a non-zero exit code
    /// - throws: `Error.noArgumentsPassed` if called with an empty string
    ///
    open static func run( _ commandString: String ) throws -> Void {
        let command = ShellCommand()
        try command.run(commandString)
    }

    /// Convenience static run method with `io` argument. Instantiates a default ShellCommand object, sets the `io`
    /// property to the passed `io` value, and runs the command string with `/bin/bash -c`
    ///
    /// Example:
    ///
    ///     let io = CapturedIO()
    ///     ShellCommand.run( "echo \"hello world\" && echo \"hello error\" >&2", io: io )
    ///     print( io.stdout ) // prints "hello world"
    ///     print( io.stderr ) // prints "hello error"
    ///
    /// - parameter commandString: A string containing a bash shell command string
    /// - parameter io: A ConsoleIOProtocol object to which output will be sent
    /// - throws: `Error.shellCommandFailed` if the underlying command returns a non-zero exit code
    /// - throws: `Error.noArgumentsPassed` if called with an empty string
    ///
    open static func run( _ commandString: String, io: ConsoleIOProtocol ) throws -> Void {
        let command = ShellCommand()
        command.io = io

        try command.run(commandString)
    }

    /**
     Convenience method to write content (e.g. a here doc) to a file.

     - parameter content: A String of content in UTF8 encoding to write to the file
     - parameter filePath: A path into which to write the file. All intermediary directories must exist.

     - throws: Whatever `String.write` throws
     */
    open func writeToFile( content: String, filePath: String ) throws -> Void {
        try content.write(toFile: filePath, atomically: false, encoding: .utf8)
    }
}
