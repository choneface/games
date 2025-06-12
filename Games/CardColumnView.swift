//
//  CardColumnView.swift
//  Games
//
//  Created by Gavin Garcia on 4/13/25.
//

import SwiftUI

/// One tableau pile.  Handles its own dragging and notifies the parent when
/// the user lets go so the model can be updated.
struct CardColumnView: View {
    // MARK: – Inputs
    var cards: [Card]
    var width: CGFloat
    var columnIndex: Int
    var onDrop: (_ dragged: [Card], _ fromColumn: Int, _ dropPoint: CGPoint) -> Void

    // MARK: – Drag state
    @State private var draggedCards: [Card] = []
    @State private var dragOffset: CGSize = .zero
    @State private var dragStartYOffset: CGFloat = 0

    var body: some View {
        let cardHeight   = width * 1.5
        let visibleStrip = cardHeight / 3        // ⅓-height overlap

        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {

                // --- NORMAL STACK ------------------------------------------------------
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
                                    if draggedCards.isEmpty {
                                        // First frame: slice off everything from `index`
                                        draggedCards = Array(cards[index...])
                                        dragStartYOffset = CGFloat(index) * visibleStrip
                                    }
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    // 1️⃣ Column’s frame in the shared coordinate space
                                    let columnFrame = proxy.frame(in: .named("GameSpace"))

                                    // 2️⃣ Finger point translated into that same space
                                    let dropPoint = CGPoint(
                                        x: columnFrame.minX + value.location.x,
                                        y: columnFrame.minY + value.location.y
                                    )

                                    // 3️⃣ Tell GameView where the drop happened
                                    onDrop(draggedCards, columnIndex, dropPoint)

                                    // 4️⃣ Reset drag state
                                    draggedCards.removeAll()
                                    dragOffset = .zero
                                    dragStartYOffset = 0
                                }
                            : nil
                        )
                }
            }
            // --- FLOATING COPY THAT FOLLOWS THE FINGER -------------------------------
            .overlay(
                ZStack(alignment: .topLeading) {
                    ForEach(Array(draggedCards.enumerated()), id: \.element.id) { idx, card in
                        CardPlaceholder(faceUp: card.faceUp,
                                        width: width,
                                        label: card.value)
                            .offset(y: CGFloat(idx) * visibleStrip)
                    }
                }
                .offset(x: dragOffset.width,
                        y: dragStartYOffset + dragOffset.height)
            )
            // Publish this column’s bounds so GameView can hit-test drops
            .anchorPreference(key: ColumnFrameKey.self,
                              value: .bounds) { [columnIndex: $0] }
        }
        .zIndex(draggedCards.isEmpty ? 0 : 1) // drag column always on top
    }
}
