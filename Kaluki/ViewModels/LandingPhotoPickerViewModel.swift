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
    @Published var selectedItem: PhotosPickerItem? {
        didSet {
            Task {
                guard let profileImage = await processSelectedItem() else { return }

                self.profileImage = profileImage
            }
        }
    }

    var profileImage: UIImage {
        get {
            gameState.currentPlayer.profileImage
        }
        set {
            gameState.currentPlayer.profileImage = newValue

            UserDefaults.profileImage.set(value: profileImage)
            FirebaseUtils.setProfileImage(
                profileImage: profileImage,
                for: appState.gameState.currentPlayer.id,
                completion: { _ in }
            )
        }
    }

    @Published private var profileImageData: Data? {
        didSet {
            if let profileImageData {
                UserDefaults.profileImage.set(value: profileImageData)
            }
        }
    }

    override init() {
        super.init()
    }

    func processSelectedItem() async -> UIImage? {
        do {
            if let data = try await selectedItem?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    return uiImage
                }
            }
        } catch {
            print(error)
        }

        return nil
    }

}
