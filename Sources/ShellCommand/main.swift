import Foundation // Gets us "exit"
#if SWIFT_PACKAGE
import ShellCommandCore
#endif

let tool = ShellCommand()

do {
    var command = CommandLine.arguments
    command.remove(at: 0)
    try tool.run(command)
} catch {
    // erroror happened - exit with non-zero exit status
    exit(1)
}
