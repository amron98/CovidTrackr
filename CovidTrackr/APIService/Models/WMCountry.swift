//
//  WMCountry.swift
//  CovidTrackr
//
//  Created by Amron B on 4/6/23.
//

import Foundation

public struct WMCountry: Decodable, Hashable, Identifiable {
    public static func == (lhs: WMCountry, rhs: WMCountry) -> Bool {
        lhs.country == rhs.country
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(country)
    }
    public let id: UUID = UUID()
    public let updated: String?
    public let country: String?
    public let cases: Int?
    public let deaths: Int?
    public let countryInfo: CountryInfo?
}
