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

// Dictionary that maps JHUCSSE country name to Worldometers country name for inconsistently named countries
var jhuNamesMap: [String:String] = [
    "Bosnia and Herzegovina"        : "Bosnia",
    "Burma"                         : "Myanmar",
    "Congo (Brazzaville)"           : "Congo",
    "Republic of the Congo"         : "Congo",
    "Congo (Kinshasa)"              : "DRC",
    "Democratic Republic of the Congo"   : "DRC",
    "Cote d'Ivoire"                 : "Côte d'Ivoire",
    "Eswatini"                      : "Swaziland",
    "Holy See"                      : "Holy See (Vatican City State)",
    "Korea, North"                  : "N. Korea",
    "Korea, South"                  : "S. Korea",
    "Laos"                          : "Lao People's Democratic Republic",
    "Libya"                         : "Libyan Arab Jamahiriya",
    "North Macedonia"               : "Macedonia",
    "Syria"                         : "Syrian Arab Republic",
    "Taiwan*"                       : "Taiwan",
    "United Arab Emirates"          : "UAE",
    "United Kingdom"                : "UK",
    "US"                            : "USA",
    "United States"                 : "USA",
    "West Bank and Gaza"            : "Palestine"
]

var wmNamesMap: [String:String] = [
    "Bosnia"                        : "Bosnia and Herzegovina",
    "Myanmar"                       : "Burma",
    "Congo"                         : "Congo (Brazzaville)",
    "DRC"                           : "Congo (Kinshasa)",
    "Côte d'Ivoire"                 : "Cote d'Ivoire",
    "Swaziland"                     : "Eswatini",
    "Holy See (Vatican City State)" : "Holy See",
    "N. Korea"                      : "Korea, North",
    "S. Korea"                      : "Korea, South",
    "Lao People's Democratic Republic" : "Laos",
    "Libyan Arab Jamahiriya"        : "Libya",
    "Macedonia"                     : "North Macedonia",
    "Syrian Arab Republic"          : "Syria",
    "Taiwan"                        : "Taiwan*",
    "UAE"                           : "United Arab Emirates",
    "UK"                            : "United Kingdom",
    "USA"                           : "US",
    "West Bank and Gaza"            : "Palestine"
]
