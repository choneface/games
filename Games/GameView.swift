//
//  GameView.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

struct GameView: View {
    // MARK: – Model
    @State private var columns: [[Card]] = MockSolitaire.columns
    @State private var columnFrames: [Int: CGRect] = [:]

    // MARK: – Layout constants
    private let spacing: CGFloat = 8
    private let sidePadding: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width
                               - spacing * CGFloat(columns.count - 1)
                               - sidePadding * 2
            let cardWidth = availableWidth / CGFloat(columns.count)

            HStack(alignment: .top, spacing: spacing) {
                ForEach(columns.indices, id: \.self) { index in
                    CardColumnView(
                        cards: columns[index],
                        width: cardWidth,
                        columnIndex: index
                    ) { dragged, fromColumn, dropPoint in
                        handleDrop(dragged,
                                   from: fromColumn,
                                   at: dropPoint)
                    }
                }
            }
            .padding(.horizontal, sidePadding)
            .padding(.top, 24)
            .coordinateSpace(name: "GameSpace")
            .onPreferenceChange(ColumnFrameKey.self) { anchors in
                columnFrames = anchors.mapValues { geo[$0] }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .background(Color.green.ignoresSafeArea())
        .navigationTitle("Solitaire")
    }

    // -------------------------------------------------------------------------
    // MARK: – Drop handling
    // -------------------------------------------------------------------------
    private func handleDrop(_ dragged: [Card],
                            from origin: Int,
                            at point: CGPoint) {

        // Pick the column whose horizontal midpoint is nearest the finger.
        guard let target = columnFrames.min(by: { lhs, rhs in
            abs(point.x - lhs.value.midX) < abs(point.x - rhs.value.midX)
        })?.key else { return }

        guard target != origin else { return }

        // Abort if move is illegal for classic Klondike tableau.
        guard canDrop(dragged, onto: columns[target]) else { return }

        // --- mutate origin pile ----------------------------------------------
        columns[origin].removeLast(dragged.count)
        // Flip the newly exposed card if needed
        if let last = columns[origin].indices.last,
           columns[origin][last].faceUp == false {
            columns[origin][last].faceUp = true
        }

        // --- mutate destination pile -----------------------------------------
        columns[target].append(contentsOf: dragged)
    }

    /// Classic Klondike tableau rules:
    /// • Empty pile ⇒ only a King may be placed.
    /// • Otherwise first dragged card must be one-rank lower and opposite color.
    private func canDrop(_ dragged: [Card], onto targetPile: [Card]) -> Bool {
        guard let movingTop = dragged.first else { return false }

        if targetPile.isEmpty {
            return movingTop.rank == 13       // King
        } else {
            guard let targetTop = targetPile.last else { return false }
            let rankOK   = movingTop.rank == targetTop.rank - 1
            let colorOK  = movingTop.isRed != targetTop.isRed
            return rankOK && colorOK
        }
    }
}

#Preview {
    NavigationStack { GameView() }
}
