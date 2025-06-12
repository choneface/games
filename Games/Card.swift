//
//  Card.swift
//  Games
//
//  Created by Gavin Garcia on 4/13/25.
//

import Foundation

/// Lightweight playing-card model.
/// - `value` keeps the pictogram (“10♦”) for display.
/// - `rank` 1‥13 lets us compare numerically (A=1 … K=13).
/// - `isRed` lets us test alternating-color rules for Klondike.
///
/// All parsing happens lazily so previews stay simple.
struct Card: Identifiable, Equatable {
    let id = UUID()
    let value: String          // e.g. “10♦” or “Q♣”
    var faceUp: Bool           // can flip after moves

    // MARK: – Derived helpers -------------------------------------------------
    var rank: Int {
        // strip suit symbols to leave "A", "2"…"10", "J", "Q", or "K"
        let rankString = value.trimmingCharacters(
            in: CharacterSet(charactersIn: "♠♣♥♦"))
        switch rankString {
        case "A": return 1
        case "J": return 11
        case "Q": return 12
        case "K": return 13
        default:  return Int(rankString) ?? 0   // 2…10
        }
    }

    var isRed: Bool {
        value.contains("♥") || value.contains("♦")
    }
}
