
import PhotosUI
import SwiftUI

struct LandingPageView: View {
    // MARK: Internal

    // MARK: - View

    var body: some View {
        NavigationView {
            ZStack {
                Color(.gray)
                    .ignoresSafeArea()
                    .opacity(0.1)

                VStack {
                    Spacer()
                    Image(systemName: "suit.diamond.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                        .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    Text("Kaluki")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    Text("Scorekeeper")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                        .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        Image(uiImage: viewModel.profileImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .frame(width: 150, height: 150)
                            .padding(.bottom, 40)
                            .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .onChange(of: viewModel.selectedItem) { _ in
                        viewModel.updateProfileImage()
                    }

                    TextField("Enter your name", text: $viewModel.displayName)
                        .font(.title2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 25)
                        .padding(.bottom, 20)
                        .frame(width: 300)

                    Button(action: {
                        viewModel.startHostingGame()
                    }) {
                        Text("Host Game")
                            .fontWeight(.semibold)
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .overlay(
                        NavigationLink(
                            destination: scoreboardView,
                            isActive: $viewModel.isLinkActive,
                            label: { EmptyView() }
                        )
                    )
                    .padding(.bottom, 10)

                    NavigationLink(destination: BrowserView(browser: MultipeerNetwork.browser!, session: MultipeerNetwork.session!) { peerID in
                        viewModel.joinGame(host: peerID)
                    }) {
                        Text("Join Game")
                            .fontWeight(.semibold)
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 30)

                    Spacer()
                }
                .padding(.vertical, 30)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: Private

    @StateObject private var viewModel = LandingPageViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) private var scenePhase

    private var scoreboardView: NavigationLazyView<some View> {
        NavigationLazyView(ScoreboardView().navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            .navigationTitle("")
        )
    }

    private var backButton: some View { Button(action: {
        viewModel.didTapBack()
        dismiss()
    }) {
        Image(systemName: "chevron.left")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.white)
            .padding(10)
            .padding(.horizontal, 2)
            .background(Color.blue)
            .cornerRadius(30)
            .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
    }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}
