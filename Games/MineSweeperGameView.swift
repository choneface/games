//
//  MineSweeperGameView.swift
//  Games
//
//  Created by Gavin Garcia on 7/3/25.
//

import SwiftUI

// ════════════════════════════════════════════════════════════════════════════
// MARK: – Model
// ════════════════════════════════════════════════════════════════════════════
private struct Tile: Identifiable {
    let id = UUID()
    var isMine     = false
    var isRevealed = false
    var isFlagged  = false
    var adjacent   = 0
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// ════════════════════════════════════════════════════════════════════════════
// MARK: – Game View
// ════════════════════════════════════════════════════════════════════════════
struct MineSweeperGameView: View {

    // MARK: - Config
    private let rows = 16, cols = 16, mineCount = 10
    private let tile: CGFloat = 44

    // MARK: - State
    @State private var board: [[Tile]] = []
    @State private var gameOver = false
    @State private var win      = false
    
    // Zoom
    @State private var zoom: CGFloat = 1         // current scale
    @State private var lastMagnification: CGFloat = 1
    let zoomRange: ClosedRange<CGFloat> = 1...4  // 1×–4×

    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {

            // Score-bug style header (flags left, status centre, mines right)
            HStack {
                Text("Flags: \(flagsRemaining)")
                Spacer()
                Text(win ? "🎉 You win!" : gameOver ? "💥 Boom!" : " ")
                    .fontWeight(.semibold)
                Spacer()
                Text("Mines: \(mineCount)")
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.2))
            )
            .padding(.horizontal)

            // Game grid
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(tile), spacing: 0), count: cols),
                    spacing: 0
                ) {
                    ForEach(board.indices, id: \.self) { r in
                        ForEach(board[r].indices, id: \.self) { c in
                            // r * cols + c is unique for every (row, col) pair
                            tileView(board[r][c])
                                .id(r * cols + c)
                                .frame(width: tile, height: tile)
                                .onTapGesture       { reveal(r, c) }
                                .onLongPressGesture { flag(r, c) }
                        }
                    }
                }
                .frame(
                    width:  tile * CGFloat(cols),
                    height: tile * CGFloat(rows),
                    alignment: .topLeading
                )
            }
            .background(Color.red)
            
            Button(action: newGame) {
                Text("New Game")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
        }
        .padding(.top, 16)
        .navigationTitle("Minesweeper")
        .onAppear(perform: newGame)
    }

    // MARK: - Tile View
    @ViewBuilder
    private func tileView(_ t: Tile) -> some View {
        ZStack {
            Rectangle()
                .stroke(Color.black.opacity(0.2), lineWidth: 1)

            if t.isRevealed {
                Rectangle()
                    .fill(Color.white.opacity(0.9))
                if t.isMine {
                    Text("💣")
                } else if t.adjacent > 0 {
                    Text("\(t.adjacent)")
                        .fontWeight(.bold)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                if t.isFlagged { Text("🚩") }
            }
        }
    }

    // MARK: - Game logic
    private func newGame() {
        gameOver = false; win = false
        board = Array(repeating: Array(repeating: Tile(), count: cols), count: rows)

        // Place mines
        var placed = 0
        while placed < mineCount {
            let r = Int.random(in: 0..<rows)
            let c = Int.random(in: 0..<cols)
            guard !board[r][c].isMine else { continue }
            board[r][c].isMine = true; placed += 1
        }

        // Calculate adjacency counts
        for r in 0..<rows {
            for c in 0..<cols {
                guard !board[r][c].isMine else { continue }
                board[r][c].adjacent = neighbours(of: r, c)
                    .filter { board[$0.r][$0.c].isMine }.count
            }
        }
    }

    private func reveal(_ r: Int, _ c: Int) {
        guard inBounds(r, c),
              !board[r][c].isRevealed,
              !board[r][c].isFlagged,
              !gameOver else { return }

        board[r][c].isRevealed = true
        if board[r][c].isMine { gameOver = true; return }

        // Auto-reveal empty neighbours
        if board[r][c].adjacent == 0 {
            neighbours(of: r, c).forEach { reveal($0.r, $0.c) }
        }

        checkWin()
    }

    private func flag(_ r: Int, _ c: Int) {
        guard inBounds(r, c),
              !board[r][c].isRevealed,
              !gameOver else { return }
        board[r][c].isFlagged.toggle()
    }

    private func checkWin() {
        let unrevealed = board.flatMap { $0 }.filter { !$0.isRevealed }
        if unrevealed.allSatisfy(\.isMine) { win = true }
    }

    // MARK: - Helpers
    private func inBounds(_ r: Int, _ c: Int) -> Bool {
        r >= 0 && r < rows && c >= 0 && c < cols
    }

    private func neighbours(of r: Int, _ c: Int) -> [(r: Int, c: Int)] {
        (-1...1).flatMap { dr in
            (-1...1).map { dc in (r+dr, c+dc) }
        }
        .filter { !( $0.r == r && $0.c == c ) && inBounds($0.r, $0.c) }
    }

    private var flagsRemaining: Int {
        mineCount - board.flatMap { $0 }.filter(\.isFlagged).count
    }
}


#Preview {
    NavigationStack { MineSweeperGameView() }
}
