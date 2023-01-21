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
    @Published var currentGlobalCases: Int = 0
    @Published var currentGlobalDeaths: Int = 0
    
    enum SortBy {
        case cases, deaths
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
    
    // Makes an API fetch to update countryData data
    func fetchCountryData() {
        DispatchQueue.global().async {
            APIService.fetchData(for: URL(string: "https://disease.sh/v3/covid-19/jhucsse")!) { (result: Result<[CountryData], Error>) in
                switch result {
                case .success(let responseData):
                    DispatchQueue.main.async {
                        self.countryData = responseData
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
