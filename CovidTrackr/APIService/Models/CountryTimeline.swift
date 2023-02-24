//
//  CountryTimeline.swift
//  CovidTrackr
//
//  Created by Amron B on 2/13/23.
//

import Foundation

struct CountryTimeline: Decodable {
    public let country: String
    public let timeline: Timeline
}
