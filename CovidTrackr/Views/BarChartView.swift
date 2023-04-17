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
    @State var topFive : [Country] = []
    @State var animate = false
    
    @State var max = 1000000000
    @State var min = 10
    
    init(viewModel: DashboardViewModel){
        self.viewModel = viewModel
        self.topFive = viewModel.countries.sorted(){
            $0.stats!.confirmed > $1.stats!.confirmed
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack{
                Text("Top 5 Countries")
                    .font(.headline.bold())
                
                Spacer()
                
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
            topFive = (currentTab == "Cases") ? Array(viewModel.countries.sorted(){
                $0.stats!.confirmed > $1.stats!.confirmed
            }.prefix(5)) : Array(viewModel.countries.sorted(){
                $0.stats!.deaths > $1.stats!.deaths
            }.prefix(5))
            

            // Re-Animating View
//            animateGraph(fromChange: true)
        }
        .onAppear {
            topFive = (currentTab == "Cases") ?
                Array(viewModel.countries.sorted(){
                    $0.stats!.confirmed > $1.stats!.confirmed
                }.prefix(5)) :
                Array(viewModel.countries.sorted(){
                    $0.stats!.deaths > $1.stats!.deaths
                }.prefix(5))
        }
        
    }
    
    @ViewBuilder
    func AnimatedChart()->some View {

        Chart {
            ForEach(topFive, id: \.name) {item in
                
                BarMark(
                    x: .value(
                        "Country",
                        Utils.getFlag(
                            from: (viewModel
                                .getWorldometersData(for: item.name)?
                                .countryInfo?.iso2) ?? "🏁"
                        )
                    ),
                    y: .value("", (currentTab == "Cases") ? item.stats?.confirmed ?? 2 : item.stats?.deaths ?? 2),
                    width: 50
                    
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle((currentTab == "Cases") ? Color.blue.opacity(0.8).gradient : Color.red.opacity(0.8).gradient)

            }
        }
        // MARK: Customizing Y-Axis Length
        //        .chartYScale(range: ymin...ymax)
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
        .chartXAxis {
            AxisMarks(position: .bottom) {
                let value = $0.as(String.self)!
                AxisGridLine().foregroundStyle(.clear)
                AxisTick().foregroundStyle(.clear)
                AxisValueLabel{
                    Text(value).font(SwiftUI.Font.title)
                }
            }
        }
        .frame(maxHeight: 200)
        .animation(.easeInOut)

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


