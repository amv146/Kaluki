//
//  LandingPagePhotoPickerViewModel.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/1/23.
//

import MultipeerConnectivity
import PhotosUI
import SwiftUI

class LandingPhotoPickerViewModel: ViewModel {
    var profileImage: UIImage {
        get {
            gameState.currentPlayer.profileImage
        }
        set {
            gameState.currentPlayer.profileImage = newValue

            UserDefaults.profileImage.set(value: profileImage)
            FirebaseUtils.setProfileImage(
                profileImage: profileImage,
                for: appState.gameState.currentPlayer.id
            )
        }
    }
}
