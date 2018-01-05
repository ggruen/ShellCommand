//
//  CapturedIO.swift
//  SwiftStarterCore
//
//  Created by Grant Grueninger on 1/3/18.
//

import Foundation

/// Provides an io plugin that captures the inputs sent to it instead of printing them.
///
/// Example:
///
///     let command = ShellCommand()
///     command.io = CapturedIO()
///     try command.run(["echo", "hello", "world!"])
///     print( command.io.stdout ) // Prints "hello world!"
///     // Handy for testing command output
///     if let out = command.io.stdout.range(of: "hello") {
///         print "command said hello!"
///     }
///     // Captures STDERR separately.
///     if let errors = command.io.stderr {
///         print( "Command sent some stuff to STDERR: \(errors) )
///     }
open class CapturedIO: ConsoleIOProtocol {
    var stdout = ""
    var stderr = ""

    public init() {}

    open func writeMessage(message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            stdout += message
        case .error:
            stderr += message
        }

    }
}

