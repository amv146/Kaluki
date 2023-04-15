//
//  ImageModifier.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import SwiftUI

protocol ImageModifier
{
    /// `Body` is derived from `View`
    associatedtype Body: View

    /// Modify an image by applying any modifications into `some View`
    func body(image: Image) -> Self.Body
}
