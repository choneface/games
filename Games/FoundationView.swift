//
//  FoundationView.swift
//  Games
//
//  Created by Gavin Garcia on 6/11/25.
//

import SwiftUI

/// A single foundation pile. Its top card is draggable onto the tableau.
struct FoundationView: View {
    // Inputs --------------------------------------------------------------
    var pile: FoundationPile
    let width: CGFloat
    let index: Int
    let dragEnded: (_ card: Card,
                    _ fromFoundation: Int,
                    _ drop: CGPoint) -> Void

    // Drag state ----------------------------------------------------------
    @State private var dragged: Card? = nil
    @State private var offset:   CGSize = .zero

    // Layout --------------------------------------------------------------
    private var height: CGFloat { width * 1.5 }

    /// Card that is *immediately* under the top card (if any)
    private var belowTopCard: Card? {
        guard pile.cards.count > 1 else { return nil }
        return pile.cards[pile.cards.count - 2]
    }

    // --------------------------------------------------------------------
    // MARK: – Body
    // --------------------------------------------------------------------
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // ── (1) Second-from-top card – shows while top is dragging ──
                if let under = belowTopCard {
                    CardPlaceholder(faceUp: true,
                                    width: width,
                                    label: under.value,
                                    isRed: under.isRed)
                        .zIndex(0)                       // always at the back
                }

                // ── (2) Top card – the one the user can drag ──────────────
                if let card = pile.topCard {
                    CardPlaceholder(faceUp: true,
                                    width: width,
                                    label: card.value,
                                    isRed: card.isRed)
                        .opacity(dragged?.id == card.id ? 0 : 1) // hide while moving
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if dragged == nil { dragged = card }
                                    offset = value.translation
                                }
                                .onEnded { value in
                                    let origin = proxy
                                        .frame(in: .named("Board")).origin
                                    let dropPt = CGPoint(x: origin.x + value.location.x,
                                                         y: origin.y + value.location.y)
                                    dragEnded(card, index, dropPt)

                                    // Reset local drag state
                                    dragged = nil
                                    offset  = .zero
                                }
                        )
                        .zIndex(1)                       // sits above “under” card
                } else {
                    // ── (2b) Empty placeholder when pile is empty ─────────
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.2))
                        .overlay(
                            Text(pile.suit.rawValue)
                                .font(.title2.bold())
                                .foregroundColor(
                                    pile.suit.isRed
                                        ? .red.opacity(0.5)
                                        : .black.opacity(0.5))
                        )
                        .zIndex(1)
                }

                // ── (3) Floating copy that follows the finger ─────────────
                if let card = dragged {
                    CardPlaceholder(faceUp: true,
                                    width: width,
                                    label: card.value,
                                    isRed: card.isRed)
                        .offset(offset)
                        .zIndex(20)                       // always on top
                }
            }
        }
        .frame(width: width, height: height)
    }
}
