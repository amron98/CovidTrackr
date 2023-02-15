//
//  ModalView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/24/23.
//

import SwiftUI

struct ModalView: View {

    @ObservedObject var viewModel: ModalViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // Close Button
            HStack {
                Spacer()
                Button(
                    action: dismiss.callAsFunction,
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title)
                    }
                )
            }
            
            // Country Info
            VStack{
                Text(
                    Utils
                        .getFlag(from: "\(viewModel.country.info?.iso2 ?? "🏁")")
                )
                    .font(.custom("Arial", size: 48))
                
                
                Text(viewModel.country.name)
                    .font(.title)
                
                
                Text(viewModel.country.continent ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Country Timeline
            VStack {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if (!viewModel.country.timeline.cases!.isEmpty) {
                    // display chart view
                    LineChartView(title: viewModel.country.name, timeline: $viewModel.country.timeline)
                } else {
                    Text("No data available.")
                }
            }
        }
        .padding()
    }
        
}


