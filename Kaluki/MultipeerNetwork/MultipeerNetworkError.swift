//
//  MultipeerNetworkError.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/26/23.
//

import Foundation

/// The error type for the MultipeerNetwork class
/// - noPeers: No peers were found

public enum MultipeerNetworkError: Error {
    case playerAlreadyInLobby
}
