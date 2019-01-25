//
//  FetchLandmarksManager.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/21/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import Foundation

protocol FetchLandmarksDelegate {
    func landmarksFound(_ businesses:[Landmark])
    func landmarksNotFound(reason: FetchLandmarksManager.FailureReason)
}

class FetchLandmarksManager {
    var landmarks=[Landmark]()//init a landmark list
    var favorite = 0 // init favorite
    
    enum FailureReason: String {
        case noResponse = "No response received" //allow the user to try again
        case non200Response = "Bad response" //give up
        case noData = "No data recieved" //give up
        case badData = "Bad data" //give up
    }

    
    var delegate: FetchLandmarksDelegate?
    
    func fetchLandmarks(lat:Double,lon:Double){
        var urlComponents = URLComponents(string: "https://api.yelp.com/v3/businesses/search")!
    
        
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: "landmark"),
            URLQueryItem(name: "latitude", value: "\(lat)"),
            URLQueryItem(name: "longitude", value: "\(lon)"),
        ]
        
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer MhKlKvrPOCLdChKBYKRFrrk9sikJCNttBVKzSEhPi3JueRgTdx80usAt6B37rraWyr2FeI6rJA39tmhp8XYhZ7JL2pDpP6Jv4pDVPdmjPQ6dQvYLUBOreuFzg7r-W3Yx", forHTTPHeaderField: "Authorization")
       
       
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //PUT CODE HERE TO RUN UPON COMPLETION
            guard let response = response as? HTTPURLResponse else {
                
                self.delegate?.landmarksNotFound(reason: .noResponse)
                
                return
            }
            
            guard response.statusCode == 200 else {
                self.delegate?.landmarksNotFound(reason: .non200Response)
                
                return
            }
            
            //response is NOT nil and IS 200
            guard let data = data else {
                print("data is nil")
                
                self.delegate?.landmarksNotFound(reason: .noData)
                
                return
            }
            
            //data is NOT nil
            
            let decoder = JSONDecoder()
            
            do {
                let businessSearchResponse = try decoder.decode(LandmarksSearchResponse.self, from: data)
                
                //decoding was successful
                
                var businesses = [Landmark]()
                self.landmarks = PersistenceManager.sharedInstance.fetchLandmarks()

                
                for Businesses in businessSearchResponse.businesses{
                    let address = Businesses.location.displayAddress.joined(separator: " ")
                    
                    let imageUrl = Businesses.imageUrl
                    //check if it is in favorite list
                    for i in stride(from: 0, to: self.landmarks.count ,by: 1) {// a loop to find if the landmark is listed in favorite landmark list
                        if(self.landmarks[i].name == Businesses.name){// judge　by name of landmark
                            self.favorite = 1
                        }else{
                            self.favorite = 0
                        }
                    }
                    let business = Landmark(name: Businesses.name, imageUrl: imageUrl, address: address, rating:Businesses.rating, favorites:self.favorite)
                    
                    businesses.append(business)
                }
                
                self.delegate?.landmarksFound(businesses)
                

                
            } catch let error {
                //if we get here, need to set a breakpoint and inspect the error to see where there is a mismatch between JSON and our Codable model structs
                print("codable failed - bad data format")
                print(error.localizedDescription)
                
                self.delegate?.landmarksNotFound(reason: .badData)
            }
        }
        
        print("execute request")
        task.resume()
    }
}
