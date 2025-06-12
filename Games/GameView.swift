//
//  GameView.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

struct GameView: View {
    let column1: [Card] = [
        Card(value: "5♠", faceUp: false),
        Card(value: "6♣", faceUp: true),
        Card(value: "7♥", faceUp: true),
        Card(value: "8♦", faceUp: true)
    ]

    let column2: [Card] = [
        Card(value: "5♠", faceUp: false),
        Card(value: "J♠", faceUp: false),
        Card(value: "Q♣", faceUp: true)
    ]

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 24
            let availableWidth = geometry.size.width - spacing - 32
            let cardWidth = availableWidth / 2

            HStack(spacing: spacing) {
                CardColumnView(cards: column1, width: cardWidth)
                CardColumnView(cards: column2, width: cardWidth)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
        }
        .background(Color.green.ignoresSafeArea())
        .navigationTitle("Solitaire")
    }
}

#Preview {
    GameView()
}
