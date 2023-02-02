//
//  HomeViewModel.swift
//  CovidTrackr
//
//  Created by Amron B on 1/19/23.
//

import Foundation

class DashboardViewModel: ObservableObject {
    @Published var globalTimeline : Timeline = Timeline(cases: [String : Int](), deaths: [String : Int]())
    @Published var countryData: [CountryData] = []
    @Published var currentGlobalCases: Int = 3 // For debugging
    @Published var currentGlobalDeaths: Int = 0
    
    enum SortBy {
        case cases, deaths
    }
    
    init(){
        self.fetchCountryData()
        self.fetchGlobalTimeline()
    }
    
    // Filter (multiple) countries with multiple provinces into one country with cumulative data
    func filterMultipleProvinces(data: [CountryData]) -> [CountryData] {
        var result: [CountryData] = []
        var multiProvinceTracker: [String: (provinces: Set<String>, stats: CovidStats)] = [:]
        
        // Build the multi-province tracker dictionary
        for entry in data {
            // Extract properties
            let country = entry.country!
            
            // Only process countries with multiple (non-nil) provinces
            if let province = entry.province {

                // Initialize dictionary entry for a new country
                if multiProvinceTracker[country] == nil {
                    multiProvinceTracker[country] = (provinces: Set<String>(), stats: CovidStats(confirmed: 0, deaths: 0))
                }
                
                // Insert province into tracker
                multiProvinceTracker[country]!.provinces.insert(province)
                
                // Update covid stats into tracker (cumulative)
                multiProvinceTracker[country]!.stats.confirmed = multiProvinceTracker[country]!.stats.confirmed  + entry.stats!.confirmed
                multiProvinceTracker[country]!.stats.deaths = multiProvinceTracker[country]!.stats.deaths + entry.stats!.deaths
            }
        }
        
        // Build the result array
        result = data.map({ country in
            var updatedCountry = country
            
            // Update stats for multi-province countries
            if (multiProvinceTracker[country.country!] != nil) {
                updatedCountry.stats = multiProvinceTracker[country.country!]?.stats
            }
            return updatedCountry
        })
        

        return result
      
    }
    
    // Makes an API fetch to update globalTimeline data
    func fetchGlobalTimeline() {
        DispatchQueue.global().async {
            APIService.fetchData(for: URL(string: "https://disease.sh/v3/covid-19/historical/all?lastdays=all")!) { (result: Result<Timeline, Error>) in
                switch result {
                case .success(let responseData):
                    DispatchQueue.main.async {
                        self.globalTimeline = responseData
                        print("Updated global timeline data in view model")
                    }
                case .failure(let error):
                    print("Error fetching global timeline data")
                    print(error)
                    
                }
            }
        }
            
    }
    
    // Makes an API fetch to get timeline data for a country
    func fetchTimeline(country: String, completion: @escaping (Timeline?) -> Void){
        var request = URLRequest(url: URL(string: "https://disease.sh/v3/covid-19/historical")!)
        request.httpMethod = "GET"
        request.url?.append(path: country)
        
        DispatchQueue.global().async {
            APIService.fetchData(for: request.url!) { (result: Result<Timeline, Error>) in
                switch result {
                case .success(let responseData):
                    print(responseData)
                    completion(responseData)
                case .failure(let error):
                    print("Error fetching timeline for \(country)")
                    print(error)
                    completion(nil)
                }
            }
        }
    }
    
    // Makes an API fetch to update countryData data
    func fetchCountryData() {
        DispatchQueue.global().async {
            APIService.fetchData(for: URL(string: "https://disease.sh/v3/covid-19/jhucsse")!) { (result: Result<[CountryData], Error>) in
                switch result {
                case .success(let responseData):
                    DispatchQueue.main.async {
                        self.countryData = self.filterMultipleProvinces(data: responseData)
                        print("Updated country data in view model")
                    }
                case .failure(let error):
                    print("Error fetching global timeline data")
                    print(error)
                    
                }
            }
        }
    }
    
    // Returns the top five countries sorted by cases or deaths
    func getTopFiveCountries(sortBy: SortBy) -> [CountryData]?{
        // Sort by cases
        if sortBy == SortBy.cases {
            let data = self.countryData.sorted() {
                // Descending order
                $0.stats!.confirmed > $1.stats!.confirmed
                
            }
            
            let topFIve = Array(data.suffix(5))
            self.currentGlobalCases = topFIve.last?.stats?.confirmed ?? currentGlobalCases
            
            return topFIve
            
        } else if sortBy == SortBy.deaths {
            let data = countryData.sorted() {
                // Descending order
                $0.stats!.deaths > $1.stats!.deaths
                
            }
            let topFIve = Array(data[data.endIndex-5..<data.endIndex])
            self.currentGlobalDeaths = topFIve.last?.stats?.deaths ?? currentGlobalDeaths
            
            return topFIve
            
        } else {
            return nil
        }
    }
    
    func getGlobalCases() -> Int {
        return self.currentGlobalCases
    }
    
    func getGlobalDeaths() -> Int {
        return self.currentGlobalDeaths
    }
    
    
    
}
