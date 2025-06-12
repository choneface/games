//
//  Suit.swift
//  Games
//
//  Created by Gavin Garcia on 6/11/25.
//

import SwiftUI

/// Standard suits plus a tiny helper.
enum Suit: String, CaseIterable {
    case spades   = "♠"
    case clubs    = "♣"
    case hearts   = "♥"
    case diamonds = "♦"

    var isRed: Bool { self == .hearts || self == .diamonds }
}

/// One “foundation” pile for a single suit.
struct FoundationPile {
    var suit: Suit
    var cards: [Card] = []          // will grow A → K
    var topCard: Card? { cards.last }
}
