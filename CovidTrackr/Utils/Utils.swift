//
//  Utils.swift
//  CovidTrackr
//
//  Created by Amron B on 1/26/23.
//

import Foundation

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
    
    
}
