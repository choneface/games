//
//  CardPlaceholder.swift
//  Games
//
//  Created by Gavin Garcia on 4/12/25.
//

import SwiftUI

struct CardPlaceholder: View {
    let faceUp: Bool
    let width: CGFloat
    let label: String?
    let isRed: Bool          // supply from Card.isRed

    var body: some View {
        let height = width * 1.5
        let cornerInset: CGFloat = 4      // distance from the edges

        ZStack(alignment: .topLeading) {
            // Card face / back
            if faceUp {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
            } else {
                // Light-blue grid card back
                ZStack {
                    // Base light blue
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)      // #CCE5FF

                    // Vertical grid lines
                    GridLines(spacing: width * 0.15)                          // every ~9 pt
                        .stroke(Color(red: 0.70, green: 0.80, blue: 0.95), lineWidth: 1)

                    // Horizontal grid lines (same spacing)
                    GridLines(spacing: width * 0.15, horizontal: true)
                        .stroke(Color(red: 0.70, green: 0.80, blue: 0.95), lineWidth: 1)
                }
            }

            // Rank-and-suit in the corner (only if face-up)
            if faceUp, let label {
                Text(label)
                    .font(.headline.weight(.bold))
                    .foregroundColor(isRed ? .red : .black)
                    .padding(.top, cornerInset)
                    .padding(.leading, cornerInset)
            }

            // Border
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.black, lineWidth: 1)
        }
        .frame(width: width, height: height)
        .shadow(radius: 2)
    }
    
    /// Draws evenly-spaced parallel lines inside its rect.
    /// Set `horizontal` to true for rows, false/default for columns.
    private struct GridLines: Shape {
        var spacing: CGFloat
        var horizontal: Bool = false

        func path(in rect: CGRect) -> Path {
            var path = Path()
            if horizontal {
                var y: CGFloat = 0
                while y <= rect.height {
                    if y > 0 && y < rect.height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: rect.width, y: y))
                    }
                    y += spacing
                }
            } else {
                var x: CGFloat = 0
                while x <= rect.width {
                    if x > 0 && x < rect.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: rect.height))
                    }
                    x += spacing
                }
            }
            return path
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        CardPlaceholder(faceUp: true,  width: 60, label: "7♥", isRed: true)
        CardPlaceholder(faceUp: true,  width: 60, label: "K♣", isRed: false)
        CardPlaceholder(faceUp: false, width: 60, label: nil,   isRed: false)
    }
    .padding()
    .background(Color.green)
}


