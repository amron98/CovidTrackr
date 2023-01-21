//
//  CountryData.swift
//  CovidTrackr
//
//  Created by Amron B on 1/17/23.
//

import Foundation

public struct CountryData: Decodable {
    public let country: String?
    public let updatedAt: String?
    public let stats: CovidStats?
    public let coordinates: Coordinates?
    
  
    
    public init(country: String?, updatedAt: String?, stats: CovidStats?, coordinates: Coordinates?) {
        self.country = country
        self.updatedAt = updatedAt
        self.stats = stats
        self.coordinates = coordinates
    }
    
    
}

public struct CovidStats: Codable {
    public let confirmed: Int
    public let deaths: Int
    
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
