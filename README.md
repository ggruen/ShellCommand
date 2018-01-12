[![Build Status](https://travis-ci.org/ggruen/ShellCommand.svg?branch=master)](https://travis-ci.org/ggruen/ShellCommand)
![Platforms](https://img.shields.io/badge/platforms-MacOS%2010.10+%20%7C%20Linux-brightgreen.svg)
[![Swift Package Manager Compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
![Swift 4](https://img.shields.io/badge/Swift-4-brightgreen.svg)

# ShellCommand

Represents a shell command and provides a means to run and redirect the output
of a shell command.

    let command = ShellCommand()
    try command.run(["/bin/echo", "hello", "world"])
    // Run the next command in /somewhere/else
    command.currentDirectoryPath = "/somewhere/else"
    command.run("echo \"hi there\" > a_file")
    command.run([ "cat", "/somewhere/else/a_file" ])

	// Implement your own class, or use CapturedIO, to catch what's sent to
	// "writeMessage"
    command.io = CapturedIO()
    try command.run(["/usr/bin/git", "add", "-A"])
    try command.run(["/usr/bin/git", "commit", "-m", "Broke everything"])
	print( "git said: \(io.stuout)" )

Pass `run` a String and it'll run it with `bash`:

    // Send "hello world" to STDERR
    try command.run("echo \"hello world\" >&2")

Pass `run` a [String] and it'll run the command directly:

    // Send scary characters to STDOUT without shell interpolation
    try command.run(["/bin/echo", "hello", "; rm /* @%&()##$$ scary!"])
    // Outputs: hello ; rm /* @%&()##$$ scary!

Run one-offs with convenient static methods:

    // Initialize and call run with a single string. Command is passed to
    // /bin/bash -c. Handy both for shorthand and for redirects.
    try ShellCommand.run("echo \"hello world!\" > /tmp/somefile")

    // This will send to STDERR.
    try ShellCommand.run("echo \"hello world!\" >&2")

    // Add a custom ConsoleIOProtocol object to capture output
    let output = CapturedIO()
    try ShellCommand.run("echo \"hello world!\" >&2", io: output)
    print( output.stderr ) // Prints "hello world!"

Developed for and tested on MacOS and Linux.

# Installation

This is a Swift Package Manager (SPM) package. Include this is your SPM file:

	.package(url: "https://github.com/ggruen/ShellCommand.git", from: "1.0.0"),

Then `import ShellCommand` at the top of your file.

	import ShellCOmmand

	ShellCommand.run("echo \"Hello World!\"")

# Development

## Get the source

    git clone https://github.com/ggruen/ShellCommand.git
    swift package update
    swift package generate-xcodeproj

And install [sourcery](https://github.com/krzysztofzablocki/Sourcery) if you
don't already have it.

## Edit

    open -a Xcode.app ShellCommand.xcodeproj

## Test

    swift test

## Make tests for Linux and commit

    sourcery
    git commit

# See Also

[SwiftShell](https://github.com/kareman/SwiftShell).  SwiftCommand handles
things a little differently and is a bit lighter-weight.
