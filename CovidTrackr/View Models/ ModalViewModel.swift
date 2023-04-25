//
//  ModalViewModel.swift
//  CovidTrackr
//
//  Created by Amron B on 2/14/23.
//

import Foundation

class ModalViewModel: ObservableObject {
    @Published var country: Country
    @Published var isLoading: Bool = false
    
    init(country: Country) {
        self.country = country
        fetchTimeline()
    }

    // Fetch timeline data for a given country
    func fetchTimeline() {
        isLoading = true
        
        // Build url for API request
        let formattedName = Utils.transformQueryParam(query: self.country.info!.iso3!)
        let url = URL(string: "https://disease.sh/v3/covid-19/historical/\(formattedName)?lastdays=all")!
        
        // Send request and wait for response
        APIService.fetchData(for: url) { (result: Result<CountryTimeline, Error>) in
            // Handle response outcome
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.country.timeline = data.timeline
                    self.isLoading = false
                }
            case .failure(let error):
                print("Error loading JHUCSSE timeline for \(self.country.name)")
                print(error.localizedDescription)
            }
        }
        
    }
    
}
