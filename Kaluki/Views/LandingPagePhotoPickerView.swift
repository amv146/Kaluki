//
//  LandingPagePhotoPicker.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/1/23.
//

import PhotosUI
import SwiftUI

// MARK: - LandingPagePhotoPicker

struct LandingPagePhotoPicker: View {
    @State var showPhotoPicker = false
    @StateObject var viewModel = LandingPhotoPickerViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: {
            showPhotoPicker.toggle()
        }) {
            Image(uiImage: viewModel.profileImage)
                .modifier(BorderedCircleImageModifier(borderWidth: 4, size: 150))
                .padding(.bottom, 40)
                .imagePicker(
                    isPresented: $showPhotoPicker,
                    sourceType: .photoLibrary
                ) { image in
                    viewModel.profileImage = image
                }
                .grayShadow()
        }
    }
}

// MARK: - LandingPagePhotoPicker_Previews

struct LandingPagePhotoPicker_Previews: PreviewProvider {
    static var previews: some View {
        LandingPagePhotoPicker()
    }
}
