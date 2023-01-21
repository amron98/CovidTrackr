//
//  LineChartView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/20/23.
//
//  Credit: https://www.youtube.com/watch?v=xS-fGYDD0qk
//

import SwiftUI
import Charts

struct LineChartView: View {
    @State var chartData = [(key: Date, value: Int)]()
    
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var currentTab: String = "Cases"
    @State var currentTotal: Int = 0
    @State var animate = false
    
    // MARK: Gesture Properties
    @State var currentActiveItem : (key: Date, value: Int)?
    @State var plotWidth: CGFloat = 0
    
    
    
    init(viewModel: DashboardViewModel){
        self.viewModel = viewModel
        self.currentTotal = viewModel.globalTimeline.getCasesFormatted().last?.value ?? 3
        self.chartData = viewModel.globalTimeline.getCasesFormatted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack{
                Text("Global Totals")
                    .font(.headline.bold())
 
                
                Picker("", selection: $currentTab) {
                    Text("Cases").tag("Cases")
                    Text("Deaths").tag("Deaths")
                    
                }
                .pickerStyle(.segmented)
                .padding(.leading,80)
            }
            
            
            Text("\(currentTotal)")
                .font(.title.bold())
                .foregroundStyle((currentTab == "Cases") ? Color.blue.gradient : Color.red.gradient)
            
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
            chartData = (currentTab == "Cases") ? viewModel.globalTimeline.getCasesFormatted() : viewModel.globalTimeline.getDeathsFormatted()
            
            currentTotal = (currentTab == "Cases") ? viewModel.globalTimeline.getCasesFormatted().first?.value ?? 1 : viewModel.globalTimeline.getDeathsFormatted().first?.value ?? 1
            

            // Re-Animating View
            animateGraph(fromChange: true)
        }
    }
    
    @ViewBuilder
    func AnimatedChart()->some View {

        Chart {
            ForEach(chartData, id: \.0) {item in
                
                LineMark(
                    x: .value("Date", item.key),
                    y: .value("", item.value)
                    
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle((currentTab == "Cases") ? Color.blue.gradient : Color.red.gradient)
                
                
                AreaMark(
                    x: .value("Date", item.key),
                    y: .value("", item.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle((currentTab == "Cases") ? Color.blue.opacity(0.2).gradient : Color.red.opacity(0.2).gradient)
    
            }
        }
        .chartYAxis (.hidden)
        .chartOverlay(content: {proxy in
            GeometryReader{innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged{value in
                                // MARK: Getting Current Location
                                // Extract the date in x-axis
                                let location = value.location
                                // Extracting Value From The Location
                                if let x: Date = proxy.value(atX: location.x){
                                    
                                    if let currentItem = chartData.first(where: {item in
                                        item.key == x
                                    }){
                                        print("Current Item: \(currentItem)")
                                        self.currentActiveItem = currentItem
                                        self.plotWidth = proxy.plotAreaSize.width
                                    }
                                }
                            }.onEnded{value in
                                self.currentActiveItem = nil
                            }
                    )
            }
        })
        .frame(height: 200)
        .onAppear{
            animateGraph()
        }
    }
    
    func animateGraph(fromChange: Bool = false){
        
        for(index,_) in chartData.enumerated(){
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ? .easeInOut(duration: 0.8) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
                    animate = true
                }
            }
        }
    }
}

