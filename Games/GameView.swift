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

    // Frames of every column, published via preference key
    @State private var columnFrames: [Int: CGRect] = [:]

    // MARK: – Layout constants
    private let spacing: CGFloat = 8  // gap between piles
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
            .coordinateSpace(name: "GameSpace")      // common coord-space
            .onPreferenceChange(ColumnFrameKey.self) { anchors in
                // Convert every Anchor<CGRect> into an actual CGRect in the same space
                columnFrames = anchors.mapValues { geo[$0] }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .background(Color.green.ignoresSafeArea())
        .navigationTitle("Solitaire")
    }

    // MARK: – Drop handling
    private func handleDrop(_ dragged: [Card],
                            from origin: Int,
                            at point: CGPoint) {

        // 1.  Find the column whose horizontal *mid-point* is nearest the finger’s x
        guard let target = columnFrames.min(by: { lhs, rhs in
            abs(point.x - lhs.value.midX) < abs(point.x - rhs.value.midX)
        })?.key else {
            print("no columns recorded – should never happen")
            return
        }
        
        print("target found \(target)")
        print("point: \(point)")

        guard target != origin else { return }

        // 3.  Mutate the model
        columns[origin].removeLast(dragged.count)
        columns[target].append(contentsOf: dragged)
    }
}

#Preview {
    NavigationStack { GameView() }
}
