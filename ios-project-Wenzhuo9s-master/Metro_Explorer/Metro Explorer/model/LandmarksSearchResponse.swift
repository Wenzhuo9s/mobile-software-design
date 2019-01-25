//
//  BusinessSearchResponse.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/28/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import Foundation

struct LandmarksSearchResponse: Codable {
        
        let businesses: [Businesses]
      //  let total: Int
      //  let region: Region
        
    }
    
struct Businesses: Codable {
        
       // let id: String
       // let alias: String
        let name: String
        let imageUrl: String
        let location: Location
        let rating: Double
        let coordinates: Coordinates
    
     private enum CodingKeys: String, CodingKey {
        case name
        case imageUrl = "image_url"
        case location
        case rating
        case coordinates
    }
    
    /****
        let imageUrl: URL
        let isClosed: Bool
        let url: URL
        let reviewCount: Int
        let categories: [Categories]
        let coordinates: Coordinates
        let transactions: [String]
        let price: String
        let phone: String
        let displayPhone: String
        let distance: Double
        
        private enum CodingKeys: String, CodingKey {
            case id
            case alias
            case name
            case imageUrl = "image_url"
            case isClosed = "is_closed"
            case url
            case reviewCount = "review_count"
            case categories
     
            case coordinates
            case transactions
            case price
     
            case phone
            case displayPhone = "display_phone"
            case distance
        }****/
    }
    /****
    struct Categories: Codable {
        
        let alias: String
        let title: String
        
    }****/
    
    struct Coordinates: Codable {
        
        let latitude: Double
        let longitude: Double
        
    }

    struct Location: Codable {
        
        //let address1: String
        //let address2: String
        //let address3: String
        //let city: String
        //let zipCode: String
        //let country: String
        //let state: String
        let displayAddress: [String]
        
        private enum CodingKeys: String, CodingKey {
            //case address1
            //case address2
           // case address3
           // case city
           // case zipCode = "zip_code"
           // case country
           // case state
            case displayAddress = "display_address"
        }
    }
    /****
    struct Region: Codable {
        
        let center: Center
        
    }
    
    struct Center: Codable {
        
        let longitude: Double
        let latitude: Double
        
}****/


