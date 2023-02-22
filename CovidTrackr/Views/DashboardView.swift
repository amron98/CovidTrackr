//
//  Home.swift
//  CovidTrackr
//
//  Created by Amron B on 1/18/23.
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct DashboardView: View {
    
    // ViewModel
    @ObservedObject var viewModel : DashboardViewModel
    
    // View Properties
    @State var currentTab: String = "Cases"
    @State var animate = false
    
    // Gesture Properties
    @State var currentActiveItem : (key: Date, value: Int)?
    @State var plotWidth: CGFloat = 0
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                LineChartView(title: "Global Totals", timeline: $viewModel.globalTimeline)
                Spacer()
                BarChartView(viewModel: viewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle("Dashboard")
            
        }.onAppear{
//            self.viewModel.fetchGlobalTimeline()
//            self.viewModel.fetchCountryData()
//            self.currentTotal = self.viewModel.getGlobalCases()
//            self.chartData = self.viewModel.globalTimeline.getCasesFormatted()
            
        }
    }
}
