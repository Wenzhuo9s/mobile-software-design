//
//  FetchMetroStationsManager.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/21/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import Foundation

protocol FetchStationsDelegate {
    func stationsFound(_ stations:[Station])
    func stationsNotFound(reason: FetchMetroStationsManager.FailureReason)
}

class FetchMetroStationsManager {
    
    enum FailureReason: String {
        case noResponse = "No response received" //allow the user to try again
        case non200Response = "Bad response" //give up
        case noData = "No data recieved" //give up
        case badData = "Bad data" //give up
    }
    
    var delegate: FetchStationsDelegate?
    
    func fetchStations(){
        var urlComponents = URLComponents(string: "https://api.wmata.com/Rail.svc/json/jStations")!
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "e13626d03d8e4c03ac07f95541b3091b")
        ]
        
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //PUT CODE HERE TO RUN UPON COMPLETION
            print("request complete")
            
            guard let response = response as? HTTPURLResponse else {
                
                self.delegate?.stationsNotFound(reason: .noResponse)
                
                return
            }
            
            guard response.statusCode == 200 else {
                self.delegate?.stationsNotFound(reason: .non200Response)
                
                return
            }
            
            //HERE - response is NOT nil and IS 200
            guard let data = data else {
                print("data is nil")
                
                self.delegate?.stationsNotFound(reason: .noData)
                
                return
            }

            //HERE - data is NOT nil
            
            let decoder = JSONDecoder()
            
            do {
                let stationsListResponse = try decoder.decode(StationsListResponse.self, from: data)
                
                //HERE - decoding was successful
                
                var stations = [Station]()
                
                for Stations in stationsListResponse.Stations{
                    let station = Station(name: Stations.Name, lat:Stations.Lat, lon:Stations.Lon)
                    
                    stations.append(station)
                }
                
                //print(stations)
                
                self.delegate?.stationsFound(stations)
                
                
            } catch let error {
                //if we get here, need to set a breakpoint and inspect the error to see where there is a mismatch between JSON and our Codable model structs
                print("codable failed - bad data format")
                print(error.localizedDescription)
                
                self.delegate?.stationsNotFound(reason: .badData)
            }
        }
        
        print("execute request")
        task.resume()
    }
}


