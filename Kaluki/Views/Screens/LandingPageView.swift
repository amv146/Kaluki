
import PhotosUI
import SwiftUI

// MARK: - LandingPageView

struct LandingPageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "suit.diamond.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.blue)
                            .grayShadow()
                        
                        VStack {
                            Group {
                                Text("Kaluki")
                                    .font(.largeTitle)
                                Text("Scorekeeper")
                                    .font(.title)
                            }
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .grayShadow()
                        }
                        
                        LandingPagePhotoPicker()
                        displayNameTextField
                        
                        Button(action: { viewModel.startHostingGame() }) {
                            gameOptionText(title: "Host Game")
                        }
                        
                        NavigationLink(
                            destination: BrowserView(
                                hosts: viewModel.hosts,
                                action: { host in viewModel.joinGame(host: host) }
                            )
                        ) {
                            gameOptionText(title: "Join Game")
                        }
                        
                        Spacer()
                    }
                    .onAppear {
//                        viewModel.hosts = []
//                        appState.multipeerState.browser?.stopBrowsingForPeers()
                        appState.multipeerState.browser?.startBrowsingForPeers()
//
//                        print("LandingPageView onAppear")
                        viewModel.pressed = false
                    }
                    
                }
                
                
                .navigationDestination(isPresented: $viewModel.isLinkActive) {
                    ScoreboardView()
                }
            }
        }
        .disabled(viewModel.pressed)
    }

    @ObservedObject private var viewModel = LandingViewModel()
}

private extension LandingPageView {
    var displayNameTextField: some View {
        TextField("Enter your name", text: $viewModel.displayName)
            .font(.largeTitle)
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
            .frame(width: 300)
    }

    var scoreboardView: NavigationLazyView<some View> {
        NavigationLazyView(
            ScoreboardView()
        )
    }

    func gameOptionText(title: String) -> some View {
        Text(title)
            .font(.system(.title, weight: .bold))
            .padding(.horizontal, 25)
            .padding(.vertical, 12)
            .modifier(BlueWhiteModifier(cornerRadius: 25))
    }
}

// MARK: - LandingPageView_Previews

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView()
    }
}
