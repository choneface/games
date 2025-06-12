//
//  StockView.swift
//  Games
//
//  Created by Gavin Garcia on 6/12/25.
//

import SwiftUI

struct StockView: View {
    let width: CGFloat
    let stockCount: Int
    let waste: [Card]
    let dealAction: () -> Void

    private var height: CGFloat { width * 1.5 }
    private let gap: CGFloat = 8
    private let overlap: CGFloat = 0.60   // 60 % overlap
    private var visibleWaste: [Card] { waste.suffix(3) }

    var body: some View {
        ZStack(alignment: .trailing) {
            // ── Stock card ────────────────────────────────────────────────
            Group {
                if stockCount > 0 {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray)
                        .shadow(radius: 2)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                }
            }
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .onTapGesture(perform: dealAction)

            // ── Waste fan (right-most card drawn last) ────────────────────
            ForEach(Array(visibleWaste.enumerated().reversed()), id: \.element.id) { idx, card in
                // idx = 0 for right-most card
                let dx = width + gap + CGFloat(idx) * width * overlap
                CardPlaceholder(
                    faceUp: true,
                    width: width,
                    label: card.value,
                    isRed: card.isRed
                )
                .offset(x: -dx)
            }
        }
        // One-card layout width keeps cluster inside the screen
        .frame(width: width, height: height, alignment: .trailing)
    }
}

