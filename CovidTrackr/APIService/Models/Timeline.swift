//
//  Timeline.swift
//  CovidTrackr
//
//  Created by Amron B on 1/18/23.
//

import Foundation

public struct Timeline : Decodable {
    public let cases: [String:Int]? 
    public let deaths: [String:Int]?
    
    
    
    init(cases: [String:Int], deaths: [String:Int]) {
        self.cases = cases
        self.deaths = deaths
    }
    
    func getCasesFormatted () -> [ChartData] {
        var result = Array<ChartData>()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        // Transform data to the ChartData type
        result = self.cases?.map({ item in
            ChartData(date: dateFormatter.date(from: item.key)!, value: item.value)
        }).sorted() {
            $0.date > $1.date
        } ?? result

        
        return result
    }
    
    func getDeathsFormatted () -> [ChartData] {
        var result = Array<ChartData>()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        result = self.deaths?.map({ item in
            ChartData(date: dateFormatter.date(from: item.key) ?? Date(), value: item.value)
        }).sorted() {
            $0.date > $1.date
        } ?? result
        
        return result
    }
}

public struct ChartData: Identifiable {
    public var date: Date
    public var value: Int
    
    public var id: Date { date }
}
