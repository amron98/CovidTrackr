//
//  CountryListView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/22/23.
//

import SwiftUI

// Note: This will eventually be part of the CountryListViewModel
class Selection: ObservableObject {
    @Published var selectedCountry: Country? = nil
}

struct CountryListView: View {
    
    @ObservedObject var viewModel : DashboardViewModel
    @ObservedObject var selection = Selection()
    
    @State var searchVal: String = ""
    @State var showModal: Bool = false

    // Filters countries based on the searchVal
    var searchResults: [Country] {
        if searchVal.isEmpty {
            return viewModel.countries
        }
        else {
            return viewModel.countries.filter({ country in
                country.name.contains(searchVal)
            })
        }
    }
    
    // Creates grouping of countries by first letter
    var groupedCountries: [String: [Country]] {
        Dictionary(grouping: searchResults, by: { String($0.name.first!) })
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedCountries.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)){
                        ForEach(self.groupedCountries[key]!) { country in
                            let rowData = RowData(
                                country: country.name,
                                confirmed: country.stats?.confirmed ?? 0,
                                deaths: country.stats?.deaths ?? 0,
                                flag: Utils.getFlag(from: (country.info?.iso2) ?? "🏁")
                            )
                            
                            
                            RowView(data: rowData)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    showModal.toggle()
                                    selection.selectedCountry = country
                                }

                        }
                    }
                }
            }
            .sheet(
                isPresented: $showModal,
                content: {
                    ModalView(
                        country: selection.selectedCountry!,
                        timeline: viewModel.globalTimeline
                    )
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(500)])
            })
            .listStyle(.automatic)
            .navigationBarTitle("Countries")
        }
        .searchable(text: $searchVal, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct RowView : View {
    let data: RowData
    
    var body: some View {
        HStack(alignment: .center) {
            Text(data.flag).font(.custom("Arial", size: 24))
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

