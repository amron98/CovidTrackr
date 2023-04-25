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
    @Published var worldometers: [Worldometers] = []
    
    @Published var countries: [Country] = []
    
    enum SortBy {
        case cases, deaths
    }
    
    init(){
        self.fetchCountryData()
        self.fetchGlobalTimeline()
        self.fetchWorldometers()
        self.normalizeData()
    }
    
    // Normalize country data
    func normalizeData(){
        var countryDict = [String:Country]()
        
        // Merge WM data
        for wmCountry in worldometers {
            
            let name = wmCountry.country!
            let cases = wmCountry.cases!
            let deaths = wmCountry.deaths!
            let info = wmCountry.countryInfo!
            let continent = wmCountry.continent!
            let population = wmCountry.population!
            let tests = wmCountry.tests!
            
            // Check if country is in dictionary, or create new
            let country = Country(
                name: name,
                continent: continent,
                population: population,
                tests: tests,
                info: info,
                stats: CovidStats(confirmed: cases, deaths: deaths)
            )
            
            countryDict[name] = country

        }
        
        // Update countries as normalized data
        self.countries = Array(countryDict.values)
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
        
        // Remove duplicates from result array and sort by country name
        result = Array(Set(result)).sorted {val1, val2 in
            val1.country! < val2.country!
        }
        
        // Remove non-country data
        result.removeAll { CountryData in
            CountryData.country == "Antarctica"
            || CountryData.country == "Diamond Princess"
            || CountryData.country == "MS Zaandam"
            || CountryData.country == "Summer Olympics 2020"
            || CountryData.country == "Winter Olympics 2022"
        }
        return result
      
    }
    
    // Returns Worldometers data for a given (JHUCSSE) country name
    func getWorldometersData(for country: String) -> Worldometers?{
        // Use an adjusted name if the provided country name has name-mapping issue
        if let correctName = jhuNamesMap[country] {
            // Find the worldometers data for the adjusted country name
            let result = self.worldometers.first { Worldometers in
                Worldometers.country == correctName
            }
                        
            return result
        }
        // Otherwise, return the worldometers data for the actual country
        return self.worldometers.first { Worldometers in
            Worldometers.country == country
        }
    }
    
    // Makes an API fetch to update globalTimeline data
    func fetchGlobalTimeline() {
        let response = APIService.fetchDataSync(for: URL(string: "https://disease.sh/v3/covid-19/historical/all?lastdays=all")!) as Result<Timeline, Error>
        
        switch response{
        case .success(let data):
            self.globalTimeline = data
        case.failure(let error):
            print("Error loading JHUCSSE timeline data (global)")
            print(error)
        }
            
    }
    
    // Fetches country data from the worldometers API
    func fetchWorldometers() {
        let response = APIService.fetchDataSync(for: URL(string: "https://disease.sh/v3/covid-19/countries")!) as Result<[Worldometers], Error>
      
        switch response {
        case .success(let responseData):
            self.worldometers = responseData
        case .failure(let error):
            print("Error fetching worldometers data")
            print(error)
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
        let response = APIService.fetchDataSync(for: URL(string: "https://disease.sh/v3/covid-19/jhucsse")!) as Result<[CountryData], Error>
        
        switch response {
        case .success(let data):
            self.countryData = self.filterMultipleProvinces(data: data)
        case .failure(let error):
            print("Error loading JHUCSSE country (all) data")
            print(error)
            
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
