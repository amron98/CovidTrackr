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
    
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var chartData: [ChartData] = []
    @State var currentTab: String = "Cases"
    @State var currentTotal: Int = 0
    @State var animate = false
    @State var title: String
    
    @Binding var timeline: Timeline {
        didSet {
            
            if (currentTab == "Cases") {
                let cases = timeline.getCasesFormatted()
                
                chartData = cases
                currentTotal = cases.first?.value ?? 6
            }else {
                let deaths = timeline.getDeathsFormatted()
                
                chartData = deaths
                currentTotal = deaths.first?.value ?? 6
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack{
                Text("\(title)")
                    .font(.headline.bold())
 
                
                Picker("", selection: $currentTab) {
                    Text("Cases")
                        .tag("Cases")
                    Text("Deaths")
                        .tag("Deaths")
                    
                }
                .pickerStyle(.segmented)
                .padding(.leading)
                .frame(width: 150)
                .colorMultiply((currentTab == "Cases") ? Color.blue : Color.red)

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
            chartData = (currentTab == "Cases") ? timeline.getCasesFormatted() : timeline.getDeathsFormatted()
            
            currentTotal = (currentTab == "Cases") ? timeline.getCasesFormatted().first?.value ?? 1 : timeline.getDeathsFormatted().first?.value ?? 1
            

            // Re-Animating View
//            animateGraph(fromChange: true)
        }.onAppear {
            self.currentTotal = timeline.getCasesFormatted().first?.value ?? 4
            self.chartData = timeline.getCasesFormatted()
        }
    }
    
    @ViewBuilder
    func AnimatedChart()->some View {

        Chart {
            ForEach(chartData, id: \.date) {item in
                
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("", item.value)
                    
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle((currentTab == "Cases") ? Color.blue.gradient : Color.red.gradient)
                
                
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("", item.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle((currentTab == "Cases") ? Color.blue.opacity(0.2).gradient : Color.red.opacity(0.2).gradient)
    
            }
        }
        .chartYAxis {
            AxisMarks() {
                let value = $0.as(Int.self)!
                AxisGridLine().foregroundStyle(.clear)
                AxisTick().foregroundStyle(.clear)
                AxisValueLabel {
                    Text("\(Utils.formatWithSuffix(value))")
                }
            }
            
        }
        .frame(maxHeight: 200)
//        .onAppear{
//            animateGraph()
//        }
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

