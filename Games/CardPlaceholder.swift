//
//  CardPlaceholder.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

struct CardPlaceholder: View {
    var faceUp: Bool
    var width: CGFloat

    var body: some View {
        let height = width * 1.5 // 2:3 aspect ratio

        RoundedRectangle(cornerRadius: 6)
            .fill(faceUp ? Color.white : Color.gray)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.black, lineWidth: 1)
            )
            .shadow(radius: 1)
    }
}

#Preview {
    CardPlaceholder(faceUp: true, width: 60)
}
