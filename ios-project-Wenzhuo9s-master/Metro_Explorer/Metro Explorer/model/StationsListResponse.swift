//
//  MetroStationsResponse.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/21/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import Foundation

struct StationsListResponse: Codable {
    
    let Stations: [Stations]
    
}

struct Stations: Codable {
    
    let Code: String
    let Name: String
    let StationTogether1: String
    let StationTogether2: String
    let LineCode1: String
    let LineCode2: String?
    let LineCode3: String?
    let LineCode4: String?
    let Lat: Double
    let Lon: Double
    let Address: Address
    
}

struct Address: Codable {
    
    let Street: String
    let City: String
    let State: String
    let Zip: String
    
}



