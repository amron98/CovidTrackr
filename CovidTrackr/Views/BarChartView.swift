//
//  BarChartView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/20/23.
//
//  Credit: https://www.youtube.com/watch?v=xS-fGYDD0qk
//

import SwiftUI
import Charts

struct BarChartView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var currentTab: String = "Cases"
    @State var topFive : [CountryData] = []
    @State var animate = false
    
    init(viewModel: DashboardViewModel){
        self.viewModel = viewModel
        self.topFive = viewModel.countryData.sorted(){
            $0.stats!.confirmed > $1.stats!.confirmed
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack{
                Text("Top 5 Countries")
                    .font(.headline.bold())
                
                Picker("", selection: $currentTab) {
                    Text("Cases").tag("Cases")
                    Text("Deaths").tag("Deaths")
                    
                }
                .pickerStyle(.segmented)
                .padding(.leading,80)
                .foregroundColor((currentTab == "Cases") ? Color.blue : Color.red)
            }
            
            
            AnimatedChart()
        }
        .padding()
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    Color(UIColor.systemBackground)
                        .shadow(
                            .drop(
                                color: (colorScheme == .dark) ? Color.white : Color.secondary ,
                                radius: 2
                            )
                        )
                )
        }
        .onChange(of: currentTab){newValue in
            topFive = (currentTab == "Cases") ? Array(viewModel.countryData.sorted(){
                $0.stats!.confirmed > $1.stats!.confirmed
            }.prefix(5)) : Array(viewModel.countryData.sorted(){
                $0.stats!.deaths > $1.stats!.deaths
            }.prefix(5))
            

            // Re-Animating View
            animateGraph(fromChange: true)
        }
        
    }
    
    @ViewBuilder
    func AnimatedChart()->some View {

        Chart {
            ForEach(topFive, id: \.country) {item in
                
                BarMark(
                    x: .value("Country", item.country!),
                    y: .value("", (currentTab == "Cases") ? item.stats?.confirmed ?? 2: item.stats?.deaths ?? 2)
                    
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle((currentTab == "Cases") ? Color.blue.opacity(0.8).gradient : Color.red.opacity(0.8).gradient)

            }
        }
        // MARK: Customizing Y-Axis Length
        //        .chartYScale(range: ymin...ymax)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                 AxisGridLine().foregroundStyle(.clear)
                 AxisTick().foregroundStyle(.clear)
                AxisValueLabel()
            }
        }
        .frame(height: 200)
        .onAppear{
            animateGraph()
        }
    }
    
    func animateGraph(fromChange: Bool = false){
        for(index,_) in topFive.enumerated(){
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ? .easeInOut(duration: 0.8) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
                    animate = true
                }
            }
        }
    }
}


