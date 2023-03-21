//
//  ScoresByRoundCellView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/26/23.
//

import SwiftUI

struct RoundScore: Identifiable {
    var round: Int
    var score: Int?

    var id: Int {
        round
    }
}

struct ScoresByRoundCellView: View {
    // MARK: Internal

    let scoresByRound: [Int: Int]

    var roundScores: [RoundScore] {
        var sortedRoundScores = scoresByRound.sorted(by: { $0.key < $1.key }).map { round, score in
            RoundScore(round: round + 1, score: score)
        }

        for round in sortedRoundScores.count + 1 ... 7 {
            sortedRoundScores.append(RoundScore(round: round))
        }

        return sortedRoundScores
    }

    var body: some View {
        Grid {
            GridRow(alignment: .bottom) {
                Text("Round")
                    .font(.system(size: 12))
                    .frame(height: 20)
                ForEach(roundScores, id: \.round) { roundScore in
                    Text("\(roundScore.round)")
                        .font(.system(size: 12))
                        .frame(height: 20)
                }
            }
            .padding(.top, 5)
            Divider()
            GridRow(alignment: .top) {
                Text("Score")
                    .font(.system(size: 12, weight: .bold))
                    .frame(height: 20)
                ForEach(roundScores, id: \.round) { roundScore in
                    if let score = roundScore.score {
                        Text("\(score)")
                            .font(.system(size: 12, weight: .bold))
                            .frame(height: 20)
                    } else {
                        Text(" ")
                            .font(.system(size: 12, weight: .bold))
                            .frame(height: 20)
                    }
                }
            }
            .padding(.bottom, 5)
            .padding(.top, -3)
        }
        // Animate by revealing from top to bottom
        .transition(.move(edge: .top))
        .background(.white)
        .addBorder(Color.gray, width: 1,
                   cornerRadius: 10, corners: [.bottomLeft, .bottomRight])
        .padding(.horizontal, 30)
    }

    // MARK: Private

    @State private var sortOrder = [KeyPathComparator(\Int.self)]
}

struct ScoresByRoundCellView_Previews: PreviewProvider {
    static var previews: some View {
        ScoresByRoundCellView(scoresByRound: [1: 1, 2: 200])
    }
}
