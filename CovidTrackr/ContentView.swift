//
//  ContentView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/17/23.
//

import SwiftUI

struct ContentView: View {
    
    var dashboardViewModel: DashboardViewModel = DashboardViewModel()
    
    init(){
        self.dashboardViewModel.fetchCountryData()
        self.dashboardViewModel.fetchGlobalTimeline()
    }
    var body: some View {
        DashboardView(viewModel: dashboardViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
