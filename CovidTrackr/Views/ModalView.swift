//
//  ModalView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/24/23.
//

import SwiftUI

struct ModalView: View {

    var country: Country
    var timeline: Timeline
    
    var body: some View {
        Text("\(country.name) clicked")
    }
        
}


