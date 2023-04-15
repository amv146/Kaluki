//
//  FirestoreKeys.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import Foundation

enum FirestoreKey: String, CustomStringConvertible
{
    case games
    case players

    var description: String
    {
        rawValue
    }
}
