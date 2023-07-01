//
//  UIImage+Extensions.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import SwiftUI

extension UIImage
{
    func isDefaultProfileImage() -> Bool
    {
        return accessibilityIdentifier == "defaultProfileImage"
    }
}
