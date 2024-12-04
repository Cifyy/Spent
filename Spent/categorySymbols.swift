//
//  categorySymbols.swift
//  spent1
//
//  Created by Jakub Majka on 4/12/24.
//
import SwiftUI

struct categorySymbols{
    static let symbols: [String: String] = [
        "food": "carrot",
        "entertainment": "basketball",
        "tech": "macmini",
        "travel": "globe",
        "shopping": "basket",
        "other": "circle.dashed"
    ]
    
    static func image(name: String) -> Image{
        if let symbolName = symbols[name] {
                   return Image(systemName: symbolName)
               } else {
                   return Image(systemName: "questionmark.circle")
               }
    }
}

struct SymbolWidthPreferenceKey: PreferenceKey {

    static var defaultValue: Double = 0

    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = max(value, nextValue())
    }
}

struct SymbolWidthModifier: ViewModifier {

    @Binding var width: Double

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geo in
                Color
                    .clear
                    .preference(key: SymbolWidthPreferenceKey.self, value: geo.size.width)
            })
    }
}

