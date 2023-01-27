//
//  CountryListView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/22/23.
//

import SwiftUI

// Note: This will eventually be part of the CountryListViewModel
class Selection: ObservableObject {
    @Published var selectedCountry: CountryData? = nil
}

struct CountryListView: View {
    
    @ObservedObject var viewModel : DashboardViewModel
    @ObservedObject var selection = Selection()
    
    @State var searchVal: String = ""
    @State var showModal: Bool = false

    // Used to store a filtered list of countries based on the searchVal
    var searchResults: [CountryData] {
        if searchVal.isEmpty {
            return viewModel.countryData
        }
        else {
            return viewModel.countryData.filter({ country in
                country.country?.contains(searchVal) ?? false
            })
        }
    }

    
    var body: some View {
        NavigationView {
            List(searchResults){ country in
                let rowData = RowData(country: country.country ?? "", confirmed: country.stats?.confirmed ?? 0, deaths: country.stats?.deaths ?? 0, flag: "🇺🇸")
                
                
                RowView(data: rowData)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showModal.toggle()
                        selection.selectedCountry = country
                    }
                    .sheet(isPresented: $showModal, content: {
                        ModalView(country: selection.selectedCountry ?? country, timeline: viewModel.globalTimeline)
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.height(500)])
                    })
            }
            .listStyle(.plain)
            .navigationBarTitle("Countries")
        }
        .searchable(text: $searchVal, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct RowView : View {
    let data: RowData
    
    var body: some View {
        HStack(alignment: .center) {
            Text(data.flag).font(.custom("Hi", size: 24))
            Text(data.country).font(.headline).fontWeight(.regular)
            Spacer()
            VStack {
                Text(Utils.formatWithSuffix(data.confirmed))
                    .foregroundColor(.blue)
                    .font(.subheadline)
                
                Text("Cases")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading)
            
            VStack {
                Text(Utils.formatWithSuffix(data.deaths))
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Text("Deaths")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

