//
//  FoundationView.swift
//  Games
//
//  Created by Gavin Garcia on 6/11/25.
//

import SwiftUI

struct FoundationView: View {
    let pile: FoundationPile
    let width: CGFloat

    private var height: CGFloat { width * 1.5 }

    var body: some View {
        ZStack {
            if let card = pile.topCard {
                CardPlaceholder(
                    faceUp: true,
                    width: width,
                    label: card.value,
                    isRed: card.isRed
                )
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                    .frame(width: width, height: height)
                    .overlay(
                        Text(pile.suit.rawValue)
                            .font(.title2.bold())
                            .foregroundColor(pile.suit.isRed ? .red.opacity(0.5)
                                                             : .black.opacity(0.5))
                    )
            }
        }
        .frame(width: width, height: height)
    }
}
