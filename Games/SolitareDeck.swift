//
//  SolitareGenerator.swift
//  Games
//
//  Created by Gavin Garcia on 4/14/24.
//

import Foundation
class SolitareDeck {
    static func shuffled() -> [CardDTO] {
        var shuffledDeck = cards
        shuffledDeck.shuffle()
        return shuffledDeck
    }
    
    // chat gpt go brrrr
    static let cards: [CardDTO] = [
        // Hearts
        CardDTO(suit: .hearts, color: .red, number: 1),
        CardDTO(suit: .hearts, color: .red, number: 2),
        CardDTO(suit: .hearts, color: .red, number: 3),
        CardDTO(suit: .hearts, color: .red, number: 4),
        CardDTO(suit: .hearts, color: .red, number: 5),
        CardDTO(suit: .hearts, color: .red, number: 6),
        CardDTO(suit: .hearts, color: .red, number: 7),
        CardDTO(suit: .hearts, color: .red, number: 8),
        CardDTO(suit: .hearts, color: .red, number: 9),
        CardDTO(suit: .hearts, color: .red, number: 10),
        CardDTO(suit: .hearts, color: .red, number: 11),
        CardDTO(suit: .hearts, color: .red, number: 12),
        CardDTO(suit: .hearts, color: .red, number: 13),
        
        // Diamonds
        CardDTO(suit: .diamonds, color: .red, number: 1),
        CardDTO(suit: .diamonds, color: .red, number: 2),
        CardDTO(suit: .diamonds, color: .red, number: 3),
        CardDTO(suit: .diamonds, color: .red, number: 4),
        CardDTO(suit: .diamonds, color: .red, number: 5),
        CardDTO(suit: .diamonds, color: .red, number: 6),
        CardDTO(suit: .diamonds, color: .red, number: 7),
        CardDTO(suit: .diamonds, color: .red, number: 8),
        CardDTO(suit: .diamonds, color: .red, number: 9),
        CardDTO(suit: .diamonds, color: .red, number: 10),
        CardDTO(suit: .diamonds, color: .red, number: 11),
        CardDTO(suit: .diamonds, color: .red, number: 12),
        CardDTO(suit: .diamonds, color: .red, number: 13),
        
        // Clubs
        CardDTO(suit: .clubs, color: .black, number: 1),
        CardDTO(suit: .clubs, color: .black, number: 2),
        CardDTO(suit: .clubs, color: .black, number: 3),
        CardDTO(suit: .clubs, color: .black, number: 4),
        CardDTO(suit: .clubs, color: .black, number: 5),
        CardDTO(suit: .clubs, color: .black, number: 6),
        CardDTO(suit: .clubs, color: .black, number: 7),
        CardDTO(suit: .clubs, color: .black, number: 8),
        CardDTO(suit: .clubs, color: .black, number: 9),
        CardDTO(suit: .clubs, color: .black, number: 10),
        CardDTO(suit: .clubs, color: .black, number: 11),
        CardDTO(suit: .clubs, color: .black, number: 12),
        CardDTO(suit: .clubs, color: .black, number: 13),
        
        // Spades
        CardDTO(suit: .spades, color: .black, number: 1),
        CardDTO(suit: .spades, color: .black, number: 2),
        CardDTO(suit: .spades, color: .black, number: 3),
        CardDTO(suit: .spades, color: .black, number: 4),
        CardDTO(suit: .spades, color: .black, number: 5),
        CardDTO(suit: .spades, color: .black, number: 6),
        CardDTO(suit: .spades, color: .black, number: 7),
        CardDTO(suit: .spades, color: .black, number: 8),
        CardDTO(suit: .spades, color: .black, number: 9),
        CardDTO(suit: .spades, color: .black, number: 10),
        CardDTO(suit: .spades, color: .black, number: 11),
        CardDTO(suit: .spades, color: .black, number: 12),
        CardDTO(suit: .spades, color: .black, number: 13),
    ]
}
