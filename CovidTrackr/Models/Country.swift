//
//  Country.swift
//  CovidTrackr
//
//  Created by Amron B on 2/15/23.
//

import Foundation

struct Country: Identifiable {
    public let id: UUID = UUID()
    public var name: String
    public var continent: String?
    public var info: CountryInfo?
    public var stats: CovidStats?
    public var timeline: Timeline = Timeline(cases: [:], deaths: [:])
    
}
