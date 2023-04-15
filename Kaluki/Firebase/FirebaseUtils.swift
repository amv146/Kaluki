//
//  FirebaseUtils.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/26/23.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

enum FirebaseUtils
{
    static let firestore = Firestore.firestore()
    static let storage = Storage.storage().reference()
}
