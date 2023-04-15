//
//  ScoresByRoundCellView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/26/23.
//

import SwiftUI

// MARK: - RoundScore

struct RoundScore: Identifiable {
    var round: Int
    var score: Int?

    var id: Int {
        round
    }
}

// MARK: - ScoresByRoundCellView

struct ScoresByRoundCellView: View {
    let scoresByRound: [Int: Int]

    var roundScores: [RoundScore] {
        var sortedRoundScores = scoresByRound.sorted(by: { $0.key < $1.key }).map
            { round, score in
                RoundScore(round: round, score: score)
            }

        if sortedRoundScores.count == 7 {
            return sortedRoundScores
        }

        for round in sortedRoundScores.count + 1 ... 7 {
            sortedRoundScores.append(RoundScore(round: round))
        }

        return sortedRoundScores
    }

    var body: some View {
        Grid {
            GridRow(alignment: .bottom) {
                ForEach(roundScores, id: \.round) { roundScore in
                    Text("\(roundScore.round)")
                        .font(.system(size: 12))
                        .frame(height: 20)
                }
            }
            .padding(.top, 5)
            .padding(.horizontal, 10)
            Divider()
            GridRow(alignment: .top) {
                ForEach(roundScores, id: \.round) { roundScore in
                    Text(roundScore.score != nil ? "\(roundScore.score!)" : "   ")
                        .font(.system(size: 12, weight: .bold))
                        .frame(height: 20)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 5)
            .padding(.top, -3)
        }
        .background(.white)
        .addBorder(
            Color.gray,
            width: 1,
            cornerRadius: 10,
            corners: [.bottomLeft, .bottomRight]
        )
        .padding(.horizontal, 10)
        .transition(.move(edge: .top))
    }
}

// MARK: - ScoresByRoundCellView_Previews

struct ScoresByRoundCellView_Previews: PreviewProvider {
    static var previews: some View {
        ScoresByRoundCellView(scoresByRound: [1: 1, 2: 200])
    }
}
