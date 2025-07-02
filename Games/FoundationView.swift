//
//  FoundationView.swift
//  Games
//
//  Created by Gavin Garcia on 6/11/25.
//

import SwiftUI

/// A single foundation pile. Its top card is draggable onto the tableau.
struct FoundationView: View {
    // Inputs
    var pile: FoundationPile
    let width: CGFloat
    let index: Int                          // which foundation in GameView
    let dragEnded: (_ card: Card, _ fromFoundation: Int, _ drop: CGPoint) -> Void

    // Drag state
    @State private var dragged: Card? = nil
    @State private var offset:   CGSize = .zero

    // Layout
    private var height: CGFloat { width * 1.5 }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Top card if any
                if let card = pile.topCard {
                    CardPlaceholder(faceUp: true,
                                    width: width,
                                    label: card.value,
                                    isRed: card.isRed)
                        .opacity(dragged?.id == card.id ? 0 : 1)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if dragged == nil { dragged = card }
                                    offset = value.translation
                                }
                                .onEnded { value in
                                    let origin = proxy.frame(in: .named("Board")).origin
                                    let dropPt = CGPoint(x: origin.x + value.location.x,
                                                         y: origin.y + value.location.y)
                                    dragEnded(card, index, dropPt)

                                    // reset local drag state
                                    dragged = nil
                                    offset  = .zero
                                }
                        )
                } else {
                    // Empty placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.2))
                        .overlay(
                            Text(pile.suit.rawValue)
                                .font(.title2.bold())
                                .foregroundColor(pile.suit.isRed ? .red.opacity(0.5)
                                                                : .black.opacity(0.5))
                        )
                }

                // Floating copy
                if let card = dragged {
                    CardPlaceholder(faceUp: true,
                                    width: width,
                                    label: card.value,
                                    isRed: card.isRed)
                        .offset(offset)
                        .zIndex(3)
                }
            }
        }
        .frame(width: width, height: height)
    }
}
