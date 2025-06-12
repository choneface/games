//
//  Card.swift
//  Games
//
//  Created by Gavin Garcia on 4/13/25.
//

import Foundation

struct Card: Identifiable, Equatable {
    let id = UUID()
    let value: String // could later be suit/rank
    var faceUp: Bool
}
