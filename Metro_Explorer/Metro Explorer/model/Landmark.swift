//
//  Landmark.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/29/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import Foundation

struct Landmark: Codable{
    let name: String
    let imageUrl: String?
    let address: String
    let rating: Double
    var favorites: Int
}
