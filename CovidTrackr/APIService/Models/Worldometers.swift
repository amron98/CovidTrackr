//
//  Worldometers.swift
//  CovidTrackr
//
//  Created by Amron B on 1/31/23.
//

import Foundation

public struct Worldometers: Decodable {
    public let country: String?
    public let countryInfo: CountryInfo?
    public let continent: String?
    
    public init(country: String?, countryInfo: CountryInfo?, continent: String?){
        self.country = country
        self.countryInfo = countryInfo
        self.continent = continent
    }

}

public struct CountryInfo: Decodable {
    public let iso2: String?
    public let iso3: String?
    public let flag: URL
    
    public init(iso2: String?, iso3: String?, flag: String?){
        self.iso2 = iso2
        self.iso3 = iso3
        self.flag = URL(string: flag!)!
    }
}
