//
//  GameView.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        GeometryReader { geometry in
            let totalSpacing: CGFloat = 12 * 6
            let availableWidth = geometry.size.width - totalSpacing - 32
            let cardWidth = availableWidth / 7
            let cardHeight = cardWidth * 1.5
            let overlapOffset: CGFloat = 20

            ScrollView {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(0..<7) { columnIndex in
                        ZStack(alignment: .topLeading) {
                            ForEach(0..<columnIndex + 1, id: \.self) { rowIndex in
                                CardPlaceholder(
                                    faceUp: rowIndex == columnIndex,
                                    width: cardWidth
                                )
                                .position(x: cardWidth / 2, y: CGFloat(rowIndex) * overlapOffset + (cardHeight / 2))
                            }
                        }
                        .frame(width: cardWidth, height: CGFloat(7) * overlapOffset + cardHeight)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Solitaire")
        .background(Color.green.opacity(0.6).ignoresSafeArea())
    }
}

#Preview {
    GameView()
}
