//
//  GameView.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

// -----------------------------------------------------------------------------
// MARK: – GameView
// -----------------------------------------------------------------------------
struct GameView: View {
    
    // MARK: – Model
    @State private var columns: [[Card]]
    @State private var stock: [Card]
    @State private var waste:   [Card] = []
    @State private var foundations: [FoundationPile] =
        Suit.allCases.map { FoundationPile(suit: $0) }          // ← NEW
    @State private var columnFrames: [Int: CGRect] = [:]
    private var foundationIndex: [Suit:Int] {
        Dictionary(uniqueKeysWithValues:
            foundations.enumerated().map { ($1.suit, $0) })
    }
    @State private var score: Int  = 0
    @State private var moves: Int  = 0
    @State private var seconds: Int = 0          // elapsed seconds
    @State private var deckPasses = 0


    // MARK: – Layout constants
    private let spacing: CGFloat = 8
    private let sidePadding: CGFloat = 8
    private let dealCount: Int = 3
    private let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Main game layout ─────────────────────────────────────────────
            GeometryReader { geo in
                VStack(spacing: 16) {
                    statsRow()
                    topRow(in: geo)                    // foundation + stock
                    tableauRow(cardWidth: calcCardWidth(in: geo), geo: geo)
                }
                .padding(.top, 16)
                .background(Color.green.ignoresSafeArea())
                .coordinateSpace(name: "Board")
                .onReceive(gameTimer) { _ in
                    seconds += 1
                }
            }

            // ── New Game button ──────────────────────────────────────────────
            Button(action: resetGame) {
                Text("New Game")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Solitaire")
    }
    
    /// Top-bar showing  ➝  Score | Time | Moves  ←  spread edge-to-edge.
    @ViewBuilder
    private func statsRow() -> some View {
        HStack {
            // left-aligned
            statBlock(title: "Score", value: "\(score)")
                .frame(maxWidth: .infinity, alignment: .leading)

            // centered
            statBlock(title: "Time", value: timeString(from: seconds))
                .frame(maxWidth: .infinity, alignment: .center)

            // right-aligned
            statBlock(title: "Moves", value: "\(moves)")
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, sidePadding)     // matches the tableau padding
        .padding(.top, 8)
    }

    @ViewBuilder
    private func statBlock(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            // bigger section title
            Text(title)
                .font(.subheadline.weight(.semibold))   // was .caption
            // bigger live value
            Text(value)
                .font(.title3.weight(.bold))            // was .headline
        }
    }


    private func timeString(from secs: Int) -> String {
        let m = secs / 60
        let s = secs % 60
        return String(format: "%02d:%02d", m, s)
    }

    
    /// Top bar that shows the four foundations on the left and the stock/waste
    /// cluster on the right.  Uses the same card width that the tableau does so
    /// everything stays in proportion on any device size.
    @ViewBuilder
    private func topRow(in geo: GeometryProxy) -> some View {
        let cardWidth = calcCardWidth(in: geo)

        HStack {
            // Foundations (left-aligned)
            foundationRow(cardWidth: cardWidth)

            Spacer(minLength: 0)

            // Stock + waste (right-aligned)
            StockView(
                width: cardWidth,
                stockCount: stock.count,
                waste: waste,
                dealAction: dealFromStock,
                dragEnded: handleWasteDrag,
                onDoubleTap: handleWasteDoubleTap
            )
            .padding(.trailing, sidePadding)          // same padding as tableau
        }
        .zIndex(10)
    }

    // -------------------------------------------------------------------------
    // MARK: – Foundation row
    // -------------------------------------------------------------------------
    @ViewBuilder
    private func foundationRow(cardWidth: CGFloat) -> some View {
        HStack(spacing: spacing) {
            ForEach(foundations.indices, id: \.self) { idx in
                FoundationView(pile: foundations[idx], width: cardWidth)
            }
        }
        .padding(.horizontal, sidePadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // -------------------------------------------------------------------------
    // MARK: – Tableau row (was your original body content)
    // -------------------------------------------------------------------------
    @ViewBuilder
    private func tableauRow(cardWidth: CGFloat, geo: GeometryProxy) -> some View {
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
                } onDoubleTap: { card, fromColumn in
                    handleDoubleTap(card: card, from: fromColumn)
                }
            }
        }
        .padding(.horizontal, sidePadding)
        .padding(.top, 8)
        .coordinateSpace(name: "Board")
        .onPreferenceChange(ColumnFrameKey.self) { anchors in
            columnFrames = anchors.mapValues { anch in
                geo[anch]                                    // still single-argument
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // -------------------------------------------------------------------------
    // MARK: – Helpers
    // -------------------------------------------------------------------------
    private func calcCardWidth(in geo: GeometryProxy) -> CGFloat {
        let available = geo.size.width
                      - spacing * CGFloat(columns.count - 1)
                      - sidePadding * 2
        return available / CGFloat(columns.count)
    }

    // -------------------------------------------------------------------------
    // MARK: – Drop handling (unchanged)
    // -------------------------------------------------------------------------
    private func handleDrop(_ dragged: [Card],
                            from origin: Int,
                            at point: CGPoint) {
        guard let target = columnFrames.min(by: { lhs, rhs in
            abs(point.x - lhs.value.midX) < abs(point.x - rhs.value.midX)
        })?.key else { return }

        guard target != origin else { return }
        guard canDrop(dragged, onto: columns[target]) else { return }

        columns[origin].removeLast(dragged.count)
        if let last = columns[origin].indices.last,
           !columns[origin][last].faceUp {
            columns[origin][last].faceUp = true
            mutateScore(.flipCardUpInRow)
        }
        columns[target].append(contentsOf: dragged)
        mutateScore(.tableauToTableau)
    }

    private func canDrop(_ dragged: [Card], onto targetPile: [Card]) -> Bool {
        guard let movingTop = dragged.first else { return false }
        if targetPile.isEmpty { return movingTop.rank == 13 }      // King
        guard let targetTop = targetPile.last else { return false }
        return movingTop.rank == targetTop.rank - 1
            && movingTop.isRed != targetTop.isRed
    }
    
    private func handleDoubleTap(card: Card, from column: Int) {
        guard let suit = card.suit,
              let fIdx = foundationIndex[suit] else { return }

        let pile = foundations[fIdx]
        guard canPlaceOnFoundation(card: card, pile: pile) else { return } // NEW ✔︎

        // Remove the TOP card only (we already know it's valid & on top)
        columns[column].removeLast()

        // Flip newly exposed card if needed
        if let last = columns[column].indices.last,
           !columns[column][last].faceUp {
            columns[column][last].faceUp = true
        }

        // Append to foundation
        foundations[fIdx].cards.append(card)
        mutateScore(.cardToFoundation)
    }
    
    /// Classic Klondike foundation rule.
    private func canPlaceOnFoundation(card: Card, pile: FoundationPile) -> Bool {
        if pile.cards.isEmpty {
            return card.rank == 1        // Ace starts a foundation
        }
        guard let top = pile.topCard else { return false }
        return card.rank == top.rank + 1 // must ascend by exactly one
    }
    
    // MARK: - Dealing helpers -----------------------------------------------------

    private struct Deal {
        let columns: [[Card]]
        let stock:   [Card]
    }

    private static func dealKlondike() -> Deal {
        var deck: [Card] = buildDeck()
        deck.shuffle()

        var cursor:  Int          = 0
        var columns: [[Card]] = Array(repeating: [], count: 7)

        for col in 0..<7 {
            for row in 0...col {
                var card: Card = deck[cursor]
                card.faceUp    = (row == col)
                columns[col].append(card)
                cursor += 1
            }
        }

        let stock: [Card] = Array(deck[cursor...])
        return Deal(columns: columns, stock: stock)
    }

    private static func buildDeck() -> [Card] {
        let suits: [Suit]  = [.spades, .clubs, .hearts, .diamonds]
        let ranks: [String] = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]

        var deck: [Card] = []
        for suit in suits {
            for rank in ranks {
                let face: String = rank + suit.rawValue
                deck.append(Card(value: face, faceUp: false))
            }
        }
        return deck
    }
    
    init() {
        let deal = Self.dealKlondike()
        _columns = State(initialValue: deal.columns)
        _stock   = State(initialValue: deal.stock)
    }
    
    private func dealFromStock() {
        if stock.isEmpty {
            // ── Re-stock: reverse GROUPS, not individual cards ──────────────
            deckPasses += 1
            var newStock: [Card] = []

            // Chunk waste into groups of `dealCount` cards from bottom to top.
            let chunkSize = dealCount
            let chunkStarts = stride(from: 0, to: waste.count, by: chunkSize)

            for start in chunkStarts.reversed() {                // reverse the chunks
                let end   = min(start + chunkSize, waste.count)
                let slice = waste[start..<end]                   // preserve order inside slice
                newStock.append(contentsOf: slice)
            }

            // Turn them face-down and assign to stock
            stock = newStock.map { card in
                var fresh = card
                fresh.faceUp = false
                return fresh
            }
            waste.removeAll()
            mutateScore(.deckPass(passNumber: deckPasses))
            return
        }

        // ── Normal deal (unchanged) ─────────────────────────────────────────
        let count  = min(dealCount, stock.count)
        let dealt  = stock.suffix(count)
        stock.removeLast(count)

        waste.append(contentsOf: dealt.map { card in
            var up = card
            up.faceUp = true
            return up
        })
    }
    
    /// Drop handler for the right-most waste card.
    /// • If the finger isn’t vertically near *any* column, we cancel.
    /// • Otherwise we pick the nearest column by mid-X.
    /// • If that column fails the Klondike rule, we cancel.
    /// • Only when both checks pass do we mutate `waste` and `columns`.
    private func handleWasteDrag(card: Card, dropPoint: CGPoint) {
        let yTolerance: CGFloat = 0         // pts above / below column band

        // 1. Ensure the finger is roughly in the vertical strip of *some* column.
        guard columnFrames.values.contains(where: { frame in
            (frame.minY - yTolerance)...(frame.maxY + yTolerance)
                ~= dropPoint.y
        }) else { return }                   // cancel: drop far above/below tableau

        // 2. Find the single nearest column by mid-X (regardless of legality).
        guard let target = columnFrames.min(by: { lhs, rhs in
            abs(dropPoint.x - lhs.value.midX) < abs(dropPoint.x - rhs.value.midX)
        })?.key else { return }

        // 3. Check Klondike legality for *that* pile.
        guard canDrop([card], onto: columns[target]) else { return }  // cancel

        // 4. Move card: remove from waste, append to tableau.
        guard waste.last?.id == card.id else { return }  // safety: must be top card
        waste.removeLast()
        columns[target].append(card)
        mutateScore(.deckToTableau)
    }
    
    /// Right-most waste card was double-tapped.
    /// If the move is legal for its suit foundation, push it; else do nothing.
    private func handleWasteDoubleTap(card: Card) {
        guard waste.last?.id == card.id else { return }                 // must be top waste
        guard let suit = card.suit,
              let idx  = foundationIndex[suit] else { return }

        var pile = foundations[idx]
        guard canPlaceOnFoundation(card: card, pile: pile) else { return }

        // mutate models
        waste.removeLast()
        pile.cards.append(card)
        foundations[idx] = pile
        mutateScore(.cardToFoundation)
    }
    
    /// Resets columns, stock, waste, and foundations to a fresh shuffled game.
    private func resetGame() {
        let deal = Self.dealKlondike()
        columns     = deal.columns
        stock       = deal.stock
        waste.removeAll()
        foundations = Suit.allCases.map { FoundationPile(suit: $0) }
        score = 0
        moves = 0
        seconds = 0
    }
    
    /// Which scoring event just happened.
    /// Call `mutateScore(_:)` with the appropriate case every time you mutate
    /// the model or on every 10-second tick.
    enum ScoreEvent {
        // Positive points
        case cardToFoundation            // +10
        case deckToTableau               // +5
        case flipCardUpInRow             // +5
        case tableauToTableau            // +3

        // Negative points
        case foundationToTableau         // –15
        case timePenalty10s              // –2
        /// Pass through the deck is penalised depending on draw mode & pass #
        case deckPass(passNumber: Int)
    }

    /// Adjusts `score` and `moves` according to Standard Klondike rules.
    private func mutateScore(_ event: ScoreEvent) {
        var delta = 0
        switch event {

        // -------------- Positive -----------------------------------
        case .cardToFoundation:
            delta += 10; moves += 1

        case .deckToTableau:
            delta +=  5; moves += 1

        case .flipCardUpInRow:
            delta +=  5                          // no move increment

        case .tableauToTableau:
            delta +=  3; moves += 1

        // -------------- Negative -----------------------------------
        case .foundationToTableau:
            delta -= 15; moves += 1

        case .timePenalty10s:
            delta -=  2                          // no move increment

        case .deckPass(let pass):
            if pass > 4 { delta -= 20; }
        }
        
        if score + delta < 0 {
            score = 0
        } else {
            score += delta
        }
        
    }

}

#Preview {
    NavigationStack { GameView() }
}
