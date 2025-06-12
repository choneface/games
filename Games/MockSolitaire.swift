//
//  MockSolitaire.swift
//  Games
//
//  Created by Gavin Garcia on 6/11/25.
//

import Foundation

/// Starter tableau: column 0 has 1 card, column 1 has 2, … column 6 has 7.
/// Only the bottom card in each pile is face-up.
enum MockSolitaire {
    static let columns: [[Card]] = [
        [Card(value: "A♠", faceUp: true)],

        [Card(value: "2♠", faceUp: false),
         Card(value: "3♠", faceUp: true)],

        [Card(value: "4♣", faceUp: false),
         Card(value: "5♣", faceUp: false),
         Card(value: "6♣", faceUp: true)],

        [Card(value: "7♦", faceUp: false),
         Card(value: "8♦", faceUp: false),
         Card(value: "9♦", faceUp: false),
         Card(value: "10♦", faceUp: true)],

        [Card(value: "J♥", faceUp: false),
         Card(value: "Q♥", faceUp: false),
         Card(value: "K♥", faceUp: false),
         Card(value: "A♥", faceUp: false),
         Card(value: "2♥", faceUp: true)],

        [Card(value: "3♠", faceUp: false),
         Card(value: "4♠", faceUp: false),
         Card(value: "5♠", faceUp: false),
         Card(value: "6♠", faceUp: false),
         Card(value: "7♠", faceUp: false),
         Card(value: "8♠", faceUp: true)],

        [Card(value: "9♣",  faceUp: false),
         Card(value: "10♣", faceUp: false),
         Card(value: "J♣",  faceUp: false),
         Card(value: "Q♣",  faceUp: false),
         Card(value: "K♣",  faceUp: false),
         Card(value: "A♣",  faceUp: false),
         Card(value: "2♣",  faceUp: true)]
    ]
}
