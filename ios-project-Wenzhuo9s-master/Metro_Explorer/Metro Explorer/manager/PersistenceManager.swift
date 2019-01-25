//
//  PersistenceManager.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/21/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import Foundation

class PersistenceManager {
    static let sharedInstance = PersistenceManager()
    
    let landmarksKey = "landmarks"
    
    //add landmark using userDefault
    func saveLandmark(landmark: Landmark) {
        let userDefaults = UserDefaults.standard
        
        var landmarks = fetchLandmarks()
        landmarks.append(landmark)
        
        let encoder = JSONEncoder()
        let encodedLandmarks = try? encoder.encode(landmarks)
        
        userDefaults.set(encodedLandmarks, forKey: landmarksKey)
    }
    
    //remove landmark using userDefaults
    func removeLandmark(landmark: Landmark) {
        let userDefaults = UserDefaults.standard
        
        var landmarks = fetchLandmarks()
        for i in 0..<landmarks.count  {
            if(landmarks[i].name == landmark.name){
            landmarks.remove(at:i)
            break
            }
        }
        let encoder = JSONEncoder()
        let encodedLandmarks = try? encoder.encode(landmarks)
        
        userDefaults.set(encodedLandmarks, forKey: landmarksKey)
    }
    //return the favorite list
    func fetchLandmarks() -> [Landmark] {
        let userDefaults = UserDefaults.standard
        
        if let landmarkData = userDefaults.data(forKey: landmarksKey), let landmarks = try? JSONDecoder().decode([Landmark].self, from: landmarkData) {
            //workoutData is non-nil and successfully decoded

            return landmarks
        }
        else {
            return [Landmark]()
        }
    }
    
}
