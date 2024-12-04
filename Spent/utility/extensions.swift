//
//  extensions.swift
//  spent1
//
//  Created by Jakub Majka on 7/12/24.
//

import Foundation
import SwiftUI
import MapKit

extension Formatter{
    static let formatCurrency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter
    }()
}

extension Double {
    var toCurrency: String{
        let formatter = Formatter.formatCurrency
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formatter.string(from: self as NSNumber) ?? String(self)    }
}

extension CLPlacemark {

    var address: String? {
        if let name = name {
            var result = name

//            if let street = thoroughfare {
//                result += ", \(street)"
//            }
            
            if let areasOfInterest = areasOfInterest{
                result += ", \(areasOfInterest)"
            }
                
            return result
        }

        return nil
    }

}

extension Image {
    func sync(with width: Binding<Double>) -> some View {
         modifier(SymbolWidthModifier(width: width))
    }
}
