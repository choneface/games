//
//  ColumnFrameKey.swift
//  Games
//
//  Created by Gavin Garcia on 6/11/25.
//

import SwiftUI

/// PreferenceKey used so every column can publish its on-screen CGRect
/// to GameView. Key = column index, Value = column frame.
struct ColumnFrameKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] = [:]

    static func reduce(value: inout [Int: Anchor<CGRect>],
                       nextValue: () -> [Int: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

