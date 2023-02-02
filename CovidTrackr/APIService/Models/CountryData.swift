//
//  CountryData.swift
//  CovidTrackr
//
//  Created by Amron B on 1/17/23.
//

import Foundation

public struct CountryData: Decodable, Hashable, Identifiable {
    public static func == (lhs: CountryData, rhs: CountryData) -> Bool {
        lhs.country == rhs.country
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(country)
    }
    public let id: UUID = UUID()
    public let country: String?
    public let updatedAt: String?
    public var stats: CovidStats?
    public let coordinates: Coordinates?
    public let province: String?
    
  
    
    public init(country: String?, updatedAt: String?, stats: CovidStats?, coordinates: Coordinates?, province: String?) {
        self.country = country
        self.updatedAt = updatedAt
        self.stats = stats
        self.coordinates = coordinates
        self.province = province
    }
    
    
}

public struct CovidStats: Codable {
    public var confirmed: Int
    public var deaths: Int
    
    public init(confirmed: Int, deaths: Int) {
        self.confirmed = confirmed
        self.deaths = deaths
    }
}

public struct Coordinates: Codable {
    public let latitude: String
    public let longitude: String
    
    public init(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
