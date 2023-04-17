//
//  Utils.swift
//  CovidTrackr
//
//  Created by Amron B on 1/26/23.
//

import Foundation
import SwiftUI

struct Utils {
    // Round up to x significant digits
    static func roundUp(_ num: Double, to places: Int) -> Double {
            let p = log10(abs(num))
            let f = pow(10, p.rounded(.up) - Double(places) + 1)
            let rnum = (num / f).rounded(.up) * f
            return rnum
    }
    
    // Format integer number as an abbreviated string
    static func formatWithSuffix(_ value: Int) -> String {
        let suffix = ["", "K", "M", "B", "T"]
        var i = 0
        var doubleValue = Double(value)
        while doubleValue >= 1000 {
            doubleValue /= 1000
            i += 1
        }
        return String(format: "%.1f%@", doubleValue, suffix[i]).replacingOccurrences(of: ".0", with: "")
    }
    
    // Get flag emoji for a given country
    static func getFlag(from countryCode: String) -> String {
        countryCode
            .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    // Transform multi-word query parameter to a URL compliant format
    static func transformQueryParam (query: String) -> String {
        return query.replacing(" ", with: "%20")
    }
    
}

extension Color {
    // Interpolate rgb values of the current color to a given 'end' color as per the provided fraction
    func interpolateRGB(_ end: Color, fraction: CGFloat) -> Color? {
        let f = min(max(0, fraction), 1)
        
        guard let c1 = self.cgColor?.components, let c2 = end.cgColor?.components else { return nil }
        
        let r: CGFloat = CGFloat(c1[0] + (c2[0] - c1[0]) * f)
        let g: CGFloat = CGFloat(c1[1] + (c2[1] - c1[1]) * f)
        let b: CGFloat = CGFloat(c1[2] + (c2[2] - c1[2]) * f)
//        let a: CGFloat = CGFloat(c1[3] + (c2[3] - c1[3]) * f)
        
        return Color(red: r, green: g, blue: b)
    }
}

