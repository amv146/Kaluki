//
//  LandingPagePhotoPicker.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/1/23.
//

import PhotosUI
import SwiftUI

struct LandingPagePhotoPicker: View
{
    @State var showPhotoPicker = false
    @StateObject var viewModel = LandingPhotoPickerViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View
    {
        Button(action: {
            showPhotoPicker.toggle()
        })
        {
            Image(uiImage: viewModel.profileImage)
                .modifier(BorderedCircleImageModifier(borderWidth: 2, size: 150))
                .padding(.bottom, 40)
                .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.selectedItem)
                .grayShadow()
        }
    }
}

struct LandingPagePhotoPicker_Previews: PreviewProvider
{
    static var previews: some View
    {
        LandingPagePhotoPicker()
    }
}
