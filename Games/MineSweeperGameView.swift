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
    
    @State private var seconds = 0                     // elapsed game time
    private let gameTimer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    // Zoom
    @State private var zoom: CGFloat = 1.0          // persists after gesture ends
    @GestureState private var pinch: CGFloat = 1.0  // live during the gesture

    // MARK: - Body
    // ── Main View ──────────────────────────────────────────────────────────────
    var body: some View {
        ZStack {                                // base layer = board
            boardView
        }
        .overlay(scoreBug.padding(.horizontal), alignment: .top)      // header
        .overlay(newGameButton.padding(.bottom, 20), alignment: .bottom)

        // navigation + life-cycle
        .navigationTitle("Minesweeper")
        .padding(.top, 16)                      // breathing-room for nav-bar
        .onAppear(perform: newGame)
        .onReceive(gameTimer) { _ in
            if !gameOver && !win { seconds += 1 }
        }

        // win / lose overlays
        .fullScreenCover(isPresented: $win,      content: winScreen)
        .fullScreenCover(isPresented: $gameOver, content: loseScreen)
    }

    // ── Sub-views ───────────────────────────────────────────────────────────────
    private var boardView: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white)    // top border

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                gridView
                    .frame(width:  tile * CGFloat(cols),
                           height: tile * CGFloat(rows),
                           alignment: .topLeading)
                    .scaleEffect(zoom * pinch)
                    .animation(.easeInOut(duration: 0.2), value: zoom)
            }
            .simultaneousGesture(magnifyGesture)
        }
    }

    private var gridView: some View {
        LazyVGrid(columns: gridColumns, spacing: 0) {
            ForEach(board.indices, id: \.self) { r in
                ForEach(board[r].indices, id: \.self) { c in
                    tileView(board[r][c])
                        .id(r * cols + c)
                        .frame(width: tile, height: tile)
                        .onTapGesture       { reveal(r, c) }
                        .onLongPressGesture { flag(r, c) }
                }
            }
        }
    }

    // ── Helpers ────────────────────────────────────────────────────────────────
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.fixed(tile), spacing: 0), count: cols)
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .updating($pinch) { value, state, _ in state = value }
            .onEnded { value in zoom = (zoom * value).clamped(to: 0.5...4) }
    }

    // Win / lose screen builders
    private func winScreen()  -> some View {
        MineSweeperWinScreenView(
            bombs: mineCount, cols: cols, rows: rows, seconds: seconds,
            playAgain: { newGame() }, share: { /* TODO */ }
        )
    }

    private func loseScreen() -> some View {
        MineSweeperLoseScreenView(
            bombs: mineCount, cols: cols, rows: rows, seconds: seconds,
            playAgain: { newGame() }, revealBoard: {
                revealAll()
                gameOver = false
            }
        )
    }

    // ── Extracted sub-views ───────────────────────────────────────────────
    private var scoreBug: some View {
        HStack {
            statBlock(title: "Flags", value: "\(flagsRemaining)")
            Spacer()
            Text(timeString)
                .monospacedDigit()
            Spacer()
            statBlock(title: "Mines", value: "\(mineCount)")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 32)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.3))
        )
    }
    
    @ViewBuilder
    private func statBlock(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            // bigger section title
            Text(title)
                .font(.headline)   // was .caption
            // bigger live value
            Text(value)
                .font(.title3)            // was .headline
        }
    }
    
    private var timeString: String {
        let m = seconds / 60
        let s = seconds % 60
        if m > 0 {
            return String(format: "%02d:%02d", seconds / 60, seconds % 60)
        }
        return String(format: "%01d:%02d", seconds / 60, seconds % 60)
    }

        private var newGameButton: some View {
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
        gameOver = false; win = false; seconds = 0
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

    /// Reveals every tile on the board—used for the “lose” screen.
    /// Unlike `reveal(_:_: )` it ignores flags, mines, and win/lose state.
    private func revealAll() {
        for r in 0..<rows {
            for c in 0..<cols {
                board[r][c].isRevealed = true
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
