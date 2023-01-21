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
    
    func getCasesFormatted () -> [(key: Date, value: Int)] {
        var result = Array<(key: Date, value: Int)>()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        result = self.cases!.map() {
            (dateFormatter.date(from: $0.key) ?? Date() ,$0.value )
        }.sorted() {
            $0.key > $1.key
        }
        
        return result
    }
    
    func getDeathsFormatted () -> [(key: Date, value: Int)] {
        var result = Array<(key: Date, value: Int)>()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        result = self.deaths!.map() {
            (dateFormatter.date(from: $0.key) ?? Date() ,$0.value )
        }.sorted() {
            $0.key > $1.key
        }
        
        return result
    }
}
