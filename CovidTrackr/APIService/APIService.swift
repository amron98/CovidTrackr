//
//  APIService.swift
//  CovidTrackr
//
//  Created by Amron B on 1/17/23.
//

import Foundation

struct APIService {

    // Performs a GET request to the provided URL and decodes response into a decodable object T
    static func fetchData<T: Decodable>(for url: URL, completion: @escaping (Result<T, Error>) -> Void) {
         
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Request failed
             if let error = error {
                 completion(.failure(error))
                 return
             }
             
            // Request successfully returns data
             if let data = data {
               do {
                   let decoder = JSONDecoder()
                   
                   // Setup date formatter for decoding dates
                   let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "MM/dd/yy"
                   decoder.dateDecodingStrategy = .formatted(dateFormatter)
                   
                   // Decode data into provided object
                   let object = try decoder.decode(T.self, from: data)
                   
                   // Successfully decoded API response
                   completion(.success(object))
                   return
               } catch let decoderError {
                   // Failed to decode API response
                   completion(.failure(decoderError))
               }
             }
        }
         task.resume()
     }

    // Fetches data synchronously
    static func fetchDataSync<T: Decodable>(for url: URL) -> Result<T, Error> {
        var result: Result<T, Error>!
        let semaphore = DispatchSemaphore(value: 0)
        APIService.fetchData(for: url) { completionResult in
            result = completionResult
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
}
