//
//  CountryListView.swift
//  CovidTrackr
//
//  Created by Amron B on 1/22/23.
//

import SwiftUI

struct CountryListView: View {
    @State var searchVal: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                RowView(data: self.ethiopiaRowData())
                RowView(data: self.canadaRowData())
                RowView(data: self.brazilRowData())
                RowView(data: self.franceRowData())
                RowView(data: self.kenyaRowData())
                RowView(data: self.usaRowData())
                RowView(data: self.ethiopiaRowData())
                RowView(data: self.canadaRowData())
                RowView(data: self.brazilRowData())
                RowView(data: self.franceRowData())
            }
            .listStyle(.plain)
            .navigationTitle("Countries")
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .searchable(text: $searchVal, placement: .navigationBarDrawer(displayMode: .always))
    }
    
    // Sample Data
    func ethiopiaRowData() -> RowData{
        .init(country: "Ethiopia", confirmed: "3.2M", deaths: "35K", flag: "🇪🇹")
    }
    func canadaRowData() -> RowData{
        .init(country: "Canada", confirmed: "50.5M", deaths: "10K", flag: "🇨🇦")
    }
    func brazilRowData() -> RowData{
        .init(country: "Brazil", confirmed: "100.9M", deaths: "421.8K", flag: "🇧🇷")
    }
    func franceRowData() -> RowData{
        .init(country: "France", confirmed: "200M", deaths: "40.6K", flag: "🇫🇷")
    }
    func kenyaRowData() -> RowData{
        .init(country: "Kenya", confirmed: "800.8K", deaths: "11.9K", flag: "🇰🇪")
    }
    func usaRowData() -> RowData{
        .init(country: "United States of America", confirmed: "600.6M", deaths: "6.4M", flag: "🇺🇸")
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
struct CountryListView_Previews: PreviewProvider {
    static var previews: some  View {
        CountryListView()
    }
}

