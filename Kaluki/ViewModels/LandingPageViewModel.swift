import MultipeerConnectivity
import PhotosUI
import SwiftUI

class LandingPageViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        displayName = UserDefaults.displayName.fallbackToDefaults() as! String
        profileImage = UserDefaults.profileImage.fallbackToDefaults() as! UIImage
    }

    // MARK: Internal

    @Published var selectedItem: PhotosPickerItem?
    @Published var isLinkActive = false
    @Published var profileImage: UIImage

    @Published var displayName: String {
        didSet {
            UserDefaults.displayName.set(value: displayName)
        }
    }

    func didTapBack() {
        isLinkActive = false
        MultipeerNetwork.leaveLobby()
    }

    func updateProfileImage() {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    self.profileImageData = uiImage.jpegData(compressionQuality: 0.3)

                    DispatchQueue.global().async {
                        DispatchQueue.main.sync {
                            self.profileImage = uiImage
                        }
                    }

                    return
                }
            }
        }
    }

    func image(from data: Data?) -> UIImage {
        guard let data = data, let image = UIImage(data: data) else {
            return UIImage(systemName: "person.crop.circle")!
        }
        return image
    }

    func startHostingGame() {
        MultipeerNetwork.player.hostGame()
        isLinkActive = true
    }

    func joinGame(host: MCPeerID) {
        MultipeerNetwork.player.joinGame(host: host)
        isLinkActive = true
    }

    // MARK: Private

    private var profileImageData: Data? {
        didSet {
            UserDefaults.profileImage.set(value: profileImageData)
        }
    }
}
