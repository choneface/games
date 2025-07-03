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
    
    @State private var showWin = false


    // MARK: – Layout constants
    private let spacing: CGFloat = 8
    private let sidePadding: CGFloat = 8
    private let dealCount: Int = 3
    private let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            // ── Main game layout ─────────────────────────────────────────────
            Rectangle()
                    .fill(Color("solitaireTopScreenColor"))
                Rectangle()
                    .fill(
                        LinearGradient(gradient: Gradient(stops: [.init(color: Color("TableGreen").opacity(0.0), location: 0.0), .init(color: Color("TableGreen").opacity(1.0), location: 0.2)]), startPoint: .top, endPoint: .bottom)
                    ).ignoresSafeArea()
            GeometryReader { geo in
                VStack(spacing: 16) {
                    statsRow()
                    topRow(in: geo)                    // foundation + stock
                    tableauRow(cardWidth: calcCardWidth(in: geo), geo: geo)
                }
                .padding(.top, 16)
                .coordinateSpace(name: "Board")
                .onReceive(gameTimer) { _ in
                    if !showWin {
                        seconds += 1
                        if seconds % 10  == 0 {
                            mutateScore(.timePenalty10s)
                        }
                    }
                }
            }

            HStack(spacing: 16) {
                Button(action: resetGame) {
                    Text("New Game")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                Button(action: undo) {
                    Text("Undo")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Solitaire")
        .fullScreenCover(isPresented: $showWin) {
            WinScreenView(
                score: score,
                moves: moves,
                seconds: seconds
            ) {
                // Play Again
                resetGame()
                seconds = 0
                showWin = false
            } share: {
                // TODO: share sheet
            }
        }
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
                .font(.headline)   // was .caption
            // bigger live value
            Text(value)
                .font(.title3.weight(.semibold))            // was .headline
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
                FoundationView(
                    pile: foundations[idx],
                    width: cardWidth,
                    index: idx,
                    dragEnded: handleFoundationDrag      // NEW
                )
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
    // MARK: – Drop handling
    // -------------------------------------------------------------------------
    private func handleDrop(_ dragged: [Card],
                            from origin: Int,
                            at point: CGPoint) {
        guard let target = columnFrames.min(by: { lhs, rhs in
            abs(point.x - lhs.value.midX) < abs(point.x - rhs.value.midX)
        })?.key else { return }

        guard target != origin else { return }
        guard canDrop(dragged, onto: columns[target]) else { return }

        pushSnapshot()
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
    
    private func checkForWin() {
        if foundations.allSatisfy({ $0.cards.count == 13 }) {
            showWin = true
            // (Optional) stop the timer so score doesn’t keep dropping
            gameTimer.upstream.connect().cancel()
        }
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
        pushSnapshot()
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
    
    // -----------------------------------------------------------------------------
    // MARK: – Move model
    // -----------------------------------------------------------------------------
    enum Pile {
        case column(Int)          // tableau
        case foundation(Int)
        case waste
    }

    struct Move {
        var cards: [Card]         // one or many cards (tableau drag)
        var from:  Pile
        var to:    Pile
        var scoreEvent: ScoreEvent
    }

    /// Double-tap in a tableau column → foundation
    private func handleDoubleTap(card: Card, from column: Int) {
        guard let suit = card.suit,
              let fIdx = foundationIndex[suit] else { return }

        apply(move: Move(cards: [card],
                         from: .column(column),
                         to:   .foundation(fIdx),
                         scoreEvent: .cardToFoundation))
    }

    /// Waste drag → tableau
    private func handleWasteDrag(card: Card, dropPoint: CGPoint) {
        guard let target = nearestColumn(to: dropPoint) else { return }

        apply(move: Move(cards: [card],
                         from: .waste,
                         to:   .column(target),
                         scoreEvent: .deckToTableau))
    }

    /// Waste double-tap → foundation
    private func handleWasteDoubleTap(card: Card) {
        guard let suit = card.suit,
              let fIdx = foundationIndex[suit] else { return }

        apply(move: Move(cards: [card],
                         from: .waste,
                         to:   .foundation(fIdx),
                         scoreEvent: .cardToFoundation))
    }

    /// Foundation drag → tableau
    private func handleFoundationDrag(card: Card,
                                      fromFoundation idx: Int,
                                      drop dropPoint: CGPoint)
    {
        guard let target = nearestColumn(to: dropPoint) else { return }

        apply(move: Move(cards: [card],
                         from: .foundation(idx),
                         to:   .column(target),
                         scoreEvent: .foundationToTableau))
    }

    // -----------------------------------------------------------------------------
    // MARK: – Shared rules + state mutation
    // -----------------------------------------------------------------------------
    private func apply(move: Move) {
        print("in apply!")
        // 1. Validate legality ----------------------------------------------------
        guard canMove(move.cards,
                      from: move.from,
                      to:   move.to) else { return }

        print("history length before: \(history.count)")
        pushSnapshot()
        print("history length after: \(history.count)")
        
        // 2. Mutate source pile ---------------------------------------------------
        switch move.from {
        case .column(let idx):
            columns[idx].removeLast(move.cards.count)
            // flip newly exposed card
            if let last = columns[idx].indices.last,
               !columns[idx][last].faceUp {
                columns[idx][last].faceUp = true
                mutateScore(.flipCardUpInRow)
            }
        case .foundation(let idx):
            foundations[idx].cards.removeLast()
        case .waste:
            waste.removeLast()
        }

        // 3. Mutate destination pile ---------------------------------------------
        switch move.to {
        case .column(let idx):
            columns[idx].append(contentsOf: move.cards)
        case .foundation(let idx):
            foundations[idx].cards.append(contentsOf: move.cards)
        case .waste: break                                    // never used
        }

        // 4. Scoring / win check --------------------------------------------------
        mutateScore(move.scoreEvent)
        if case .foundation = move.to { checkForWin() }
    }

    /// Core Klondike legality checks
    private func canMove(_ dragged: [Card],
                         from: Pile,
                         to:   Pile) -> Bool
    {
        guard let top = dragged.first else { return false }

        switch to {
        case .column(let idx):
            let target = columns[idx]
            if target.isEmpty { return top.rank == 13 }               // King on empty
            guard let dstTop = target.last else { return false }
            return top.rank == dstTop.rank - 1 && top.isRed != dstTop.isRed

        case .foundation(let idx):
            let pile = foundations[idx]
            if pile.cards.isEmpty { return top.rank == 1 }            // Ace starts
            guard let dstTop = pile.topCard else { return false }
            return top.rank == dstTop.rank + 1

        case .waste:
            return false                                             // never legal
        }
    }

    /// Translate a touch/drop point to the closest tableau column index
    private func nearestColumn(to point: CGPoint) -> Int? {
        columnFrames.min { abs(point.x - $0.value.midX) <
                           abs(point.x - $1.value.midX) }?.key
    }
    
    // ─────────────────────────────────────────────────────────────────────────────
    // 1. Add snapshot model + stack
    // ─────────────────────────────────────────────────────────────────────────────
    private struct Snapshot {
        let columns: [[Card]]
        let stock:   [Card]
        let waste:   [Card]
        let foundations: [FoundationPile]
        let score:   Int
        let moves:   Int
        let deckPasses: Int
    }

    @State private var history: [Snapshot] = []

    private func pushSnapshot() {
        history.append(
            Snapshot(columns: columns,
                     stock: stock,
                     waste: waste,
                     foundations: foundations,
                     score: score,
                     moves: moves,
                     deckPasses: deckPasses))
    }

    private func undo() {
        print("history length: \(history.count)")
        guard let snap = history.popLast() else { return }
        columns      = snap.columns
        stock        = snap.stock
        waste        = snap.waste
        foundations  = snap.foundations
        score        = snap.score
        moves        = snap.moves
        deckPasses   = snap.deckPasses
        showWin      = false                // in case we just undid the winning move
    }

}

#Preview {
    NavigationStack { GameView() }
}
