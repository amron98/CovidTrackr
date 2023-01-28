//
//  ModalView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/24/23.
//

import SwiftUI

struct ModalView: View {

    var country: CountryData
    var timeline: Timeline
    
    init(country: CountryData, timeline: Timeline) {
        self.country = country
        self.timeline = timeline
    }
    
    var body: some View {
        Text("\(country.country!) clicked")
//        LineChartView(title: country.country!, timeline: timeline)
//            .padding()
    }
        
}


