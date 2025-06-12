//
//  CardColumnView.swift
//  Games
//
//  Created by Gavin Garcia on 4/13/25.
//

import SwiftUI

// CardColumnView.swift
struct CardColumnView: View {
    let cards: [Card]
    let width: CGFloat

    @State private var draggedCards: [Card] = []
    @State private var dragOffset: CGSize = .zero
    @State private var dragStartYOffset: CGFloat = 0          // NEW

    var body: some View {
        let cardHeight   = width * 1.5
        let visibleStrip = cardHeight / 3                     // 1/3-height overlap

        ZStack(alignment: .topLeading) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                let isBeingDragged = draggedCards.contains(card)

                CardPlaceholder(faceUp: card.faceUp,
                                width: width,
                                label: card.value)
                    .offset(y: CGFloat(index) * visibleStrip)
                    .opacity(isBeingDragged ? 0 : 1)
                    .gesture(
                        card.faceUp ? DragGesture()
                            .onChanged { value in
                                if draggedCards.isEmpty {              // first frame
                                    draggedCards      = Array(cards[index...])
                                    dragStartYOffset  = CGFloat(index) * visibleStrip
                                }
                                dragOffset = value.translation
                            }
                            .onEnded { _ in
                                draggedCards.removeAll()
                                dragOffset        = .zero
                                dragStartYOffset  = 0
                            }
                        : nil
                    )
            }
        }
        // --- floating copy that follows the finger ----------------------------
        .overlay(
            ZStack(alignment: .topLeading) {
                ForEach(Array(draggedCards.enumerated()), id: \.element.id) { i, card in
                    CardPlaceholder(faceUp: card.faceUp,
                                    width: width,
                                    label: card.value)
                        .offset(y: CGFloat(i) * visibleStrip)         // local spacing
                }
            }
            // anchor at original Y + live finger translation
            .offset(x: dragOffset.width,
                    y: dragStartYOffset + dragOffset.height)
        )
        .zIndex(draggedCards.isEmpty ? 0 : 1)
    }
}


#Preview {
    CardColumnView(
        cards: [
            Card(value: "5♠", faceUp: false),
            Card(value: "6♣", faceUp: true),
            Card(value: "7♥", faceUp: true),
            Card(value: "8♦", faceUp: true),
        ],
        width: 60
    )
    .padding()
    .background(Color.green)
}
