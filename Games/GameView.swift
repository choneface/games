//
//  GameView.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

struct GameView: View {
    // MARK: – Mock data --------------------------------------------------------
    //
    // Column 0 has 1 card (last one face-up), column 1 has 2 cards, … column 6 has 7 cards.
    // Suit / rank values are arbitrary placeholders so you can see different labels.
    //
    let columns: [[Card]] = [
        [Card(value: "A♠", faceUp: true)],

        [Card(value: "2♠", faceUp: false),
         Card(value: "3♠", faceUp: true)],

        [Card(value: "4♣", faceUp: false),
         Card(value: "5♣", faceUp: false),
         Card(value: "6♣", faceUp: true)],

        [Card(value: "7♦", faceUp: false),
         Card(value: "8♦", faceUp: false),
         Card(value: "9♦", faceUp: false),
         Card(value: "10♦", faceUp: true)],

        [Card(value: "J♥", faceUp: false),
         Card(value: "Q♥", faceUp: false),
         Card(value: "K♥", faceUp: false),
         Card(value: "A♥", faceUp: false),
         Card(value: "2♥", faceUp: true)],

        [Card(value: "3♠", faceUp: false),
         Card(value: "4♠", faceUp: false),
         Card(value: "5♠", faceUp: false),
         Card(value: "6♠", faceUp: false),
         Card(value: "7♠", faceUp: false),
         Card(value: "8♠", faceUp: true)],

        [Card(value: "9♣",  faceUp: false),
         Card(value: "10♣", faceUp: false),
         Card(value: "J♣",  faceUp: false),
         Card(value: "Q♣",  faceUp: false),
         Card(value: "K♣",  faceUp: false),
         Card(value: "A♣",  faceUp: false),
         Card(value: "2♣",  faceUp: true)]
    ]

    // MARK: – Body -------------------------------------------------------------
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 4                      // gap between columns
            let availableWidth = geometry.size.width
                               - (spacing * CGFloat(columns.count - 1))
                               - 8                        // horizontal padding
            let cardWidth = availableWidth / CGFloat(columns.count)

            HStack(alignment: .top, spacing: spacing) {
                ForEach(Array(columns.enumerated()), id: \.offset) { _, pile in
                    CardColumnView(cards: pile, width: cardWidth)
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 24)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .background(Color.green.ignoresSafeArea())
        .navigationTitle("Solitaire")
    }
}

#Preview {
    NavigationStack { GameView() }
}

