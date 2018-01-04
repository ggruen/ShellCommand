//
//  ConsoleIO.swift
//  SwiftStarter
//
//  Created by Grant Grueninger on 1/2/18.
//

import Foundation

public enum OutputType {
    case error
    case standard
}

open class ConsoleIO: ConsoleIOProtocol {
    public init() {}
    
    open func writeMessage(message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print("\(message)")
        case .error:
            fputs("\(message)", stderr)
        }
    }
}

