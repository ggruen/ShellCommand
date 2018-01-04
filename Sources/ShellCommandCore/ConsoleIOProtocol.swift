//
//  ConsoleIOProtocol.swift
//  SwiftStarter
//
//  Created by Grant Grueninger on 1/2/18.
//

import Foundation

public protocol ConsoleIOProtocol {
    func writeMessage(message: String, to: OutputType)
}
