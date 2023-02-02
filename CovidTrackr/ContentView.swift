//
//  ContentView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/17/23.
//

import SwiftUI

struct ContentView: View {
    
    var dashboardViewModel: DashboardViewModel
    
    init(){
        self.dashboardViewModel = DashboardViewModel()
    }
    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem{
                    Image(systemName: "house")
                    Text("Dashboard")
                }
                
            CountryListView(viewModel: dashboardViewModel)
                .tabItem{
                    Image(systemName: "list.dash")
                    Text("Countries")
                }
            
            WorldMapView()
                .tabItem{
                    Image(systemName: "globe")
                    Text("World Map")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
