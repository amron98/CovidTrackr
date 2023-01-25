//
//  CountryListView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/22/23.
//

import SwiftUI

struct CountryListView: View {
    @State var searchVal: String = ""
    @State var selection: String = ""
    
    @ObservedObject var viewModel : DashboardViewModel
    @State var showModal: Bool = false
    @State var countryTimeline: Timeline = Timeline(cases: [:], deaths: [:])
    
    var body: some View {
        NavigationStack {
            List(viewModel.countryData){ country in
                
                var rowData = RowData(country: country.country ?? "", confirmed: country.stats?.confirmed ?? 0, deaths: country.stats?.deaths ?? 0, flag: "🇺🇸")
                
                
                RowView(data: rowData)
                
                    .onTapGesture {
                        self.selection = country.country!
                    
                        showModal.toggle()
                        
                    }
                    .sheet(isPresented: $showModal, content: {
                        ModalView(country: self.selection)
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.height(500)])
                    })
            }
            .listStyle(.plain)
            .navigationBarTitle("Countries")
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .searchable(text: $searchVal, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct RowView : View {
    let data: RowData
    
    var body: some View {
        HStack(alignment: .center) {
            Text(data.flag).font(.custom("Hi", size: 24))
            Text(data.country).font(.headline).fontWeight(.regular)
            Spacer(minLength: 10)
            VStack {
                Text(String(data.confirmed))
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text("Cases")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading)
            
            VStack {
                Text(String(data.deaths))
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Text("Deaths")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

