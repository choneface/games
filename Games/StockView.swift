//
//  StockView.swift
//  Games
//
//  Created by Gavin Garcia on 6/12/25.
//

import SwiftUI

/// Shows the stock (face-down draw pile) plus the waste fan.
/// • Tap the stock to deal 1 or 3 cards (provided by `dealAction()`).
/// • Only the **right-most** waste card is draggable; its drop point is reported
///   via `dragEnded(card, globalDropPoint)`.
struct StockView: View {
    // MARK: – Inputs
    let width: CGFloat
    let stockCount: Int
    let waste: [Card]
    let dealAction: () -> Void
    let dragEnded: (_ card: Card, _ dropPoint: CGPoint) -> Void

    // MARK: – Internal drag state
    @State private var draggedCard: Card? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var dragStartLocal: CGPoint = .zero
    @State private var baseOffsetX: CGFloat = 0          // offset in waste fan

    // MARK: – Layout constants
    private var height: CGFloat { width * 1.5 }
    private let gap: CGFloat = 8
    private let overlap: CGFloat = 0.60                  // 60 % card overlap
    private var visibleWaste: [Card] { waste.suffix(3) }
    private var topWaste: Card? { visibleWaste.last }    // right-most card

    // MARK: – View
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .trailing) {

                // ───── Stock pile (tap target) ────────────────────────────
                stockShape
                    .frame(width: width, height: height)
                    .zIndex(draggedCard == nil ? 0 : 2)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: dealAction)

                // ───── Waste fan (left of stock) ──────────────────────────
                // Draw all but the top card first
                ForEach(visibleWaste.dropLast().indices, id: \.self) { idx in
                    let card = visibleWaste[idx]
                    CardPlaceholder(
                        faceUp: true,
                        width: width,
                        label: card.value,
                        isRed: card.isRed
                    )
                    .offset(x: -leftShift(forOriginalIndex: idx))
                }

                // ───── Top waste card (draggable) ─────────────────────────
                if let card = topWaste {
                    CardPlaceholder(
                        faceUp: true,
                        width: width,
                        label: card.value,
                        isRed: card.isRed
                    )
                    .offset(x: -leftShift(forOriginalIndex: visibleWaste.count - 1))
                    .opacity(draggedCard?.id == card.id ? 0 : 1)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if draggedCard == nil {
                                    // First frame of drag
                                    draggedCard = card
                                    dragStartLocal = value.startLocation
                                    baseOffsetX = -leftShift(forOriginalIndex: visibleWaste.count - 1)
                                }
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let boardOrigin = proxy.frame(in: .named("Board")).origin
                                let dropPoint = CGPoint(x: boardOrigin.x + value.location.x,
                                                        y: boardOrigin.y + value.location.y)

                                dragEnded(card, dropPoint)

                                draggedCard = nil
                                dragOffset  = .zero
                            }

                    )
                }

                // ───── Floating copy that follows the finger ──────────────
                if let card = draggedCard {
                    CardPlaceholder(
                        faceUp: true,
                        width: width,
                        label: card.value,
                        isRed: card.isRed
                    )
                    .offset(x: baseOffsetX + dragOffset.width,
                            y: dragOffset.height)
                    .zIndex(3)
                }
            }
        }
        .frame(width: width, height: height)
    }

    // MARK: – Sub-helpers
    @ViewBuilder
    private var stockShape: some View {
        if stockCount > 0 {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray)
                .shadow(radius: 2)
        } else {
            RoundedRectangle(cornerRadius: 6)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
        }
    }

    /// Horizontal shift from the right edge for a waste card at original index.
    private func leftShift(forOriginalIndex idx: Int) -> CGFloat {
        let count = visibleWaste.count                   // 1‥3
        return width + gap + CGFloat(count - 1 - idx) * width * overlap
    }
}
