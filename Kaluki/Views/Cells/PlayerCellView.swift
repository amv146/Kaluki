//
//  PlayerCellView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/23/23.
//

import SwiftUI

struct ScoreView: View {
    var score: Int
    var title: String

    var body: some View {
        VStack {
            Text("\(score)")
                .font(.system(size: 18, weight: .bold))
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
        }
        .padding(.trailing, 10)
    }
}

struct PlayerCellView: View {
    // MARK: Internal

    var playerInfo: PlayerInfo
    var standing: Int

    var profileImageView: some View {
        ZStack {
            Image(uiImage: playerInfo.profileImage!)
                .resizable()
                .overlay(Circle().stroke(Color.blue, lineWidth: 1.25))
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .overlay(Image(systemName: "crown")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 12, height: 12)
                    .padding(2)
                    .padding(.horizontal, 2)
                    .background(.blue)
                    .cornerRadius(20)
                    .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    .opacity(playerInfo.role == .host ? 1 : 0),
                    alignment: .topLeading)
                .padding(.leading, 10)
                .padding(.trailing, 5)

                .zIndex(1)
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    VStack {
                        Text("\(standing)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .padding(.leading, 10)
                    self.profileImageView

                    VStack(alignment: .leading) {
                        Text(playerInfo.displayName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ScoreView(score: playerInfo.scoresByRound[playerInfo.scoresByRound.count - 1] ?? 0, title: "Last")
                    ScoreView(score: playerInfo.scoresByRound.values.reduce(0, +), title: "Score")
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
                .padding(.horizontal, 15)
                if isExpanded {
                    ScoresByRoundCellView(scoresByRound: playerInfo.scoresByRound).zIndex(-1)
                }
            }
            .onTapGesture {
                if playerInfo.scoresByRound.count > 0 {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        }
    }

    // MARK: Private

    @State private var isExpanded = false
}

struct PlayerCellView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerCellView(playerInfo: PlayerInfo(displayName: "Iphone 14 prollllllla", role: .host, id: UUID(), scoresByRound: [1: 1, 2: 2], profileImage: UIImage(systemName: "person.crop.circle")!), standing: 1)
    }
}
