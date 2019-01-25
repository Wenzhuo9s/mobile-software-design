//
//  LandmarksViewController.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/13/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreLocation

//The LandmarkList in a TableView
class LandmarksViewController: UITableViewController{

    let locationDetector = LocationDetector()    //init LocationDetector
    let fetchLandmarksManager = FetchLandmarksManager() //init FetchLandmarksManager
    let fetchMetroStationsManager = FetchMetroStationsManager()//init FetchMetroStationsManager
    
    
    var choose:String = ""//variable to separate the nearest station & favorite landmarks
    var station: Station?
    
    var distance: Double = Double.greatestFiniteMagnitude//init distance as the maximum
    var latitude: Double = 0
    var longitude: Double = 0
    var name: String = ""
    var coordinate₀:CLLocation?//currentlocation
    
    var landmarks1=[Landmark]()//init favorite landmark
    var landmarks = [Landmark]()
    {
        didSet {
                tableView.reloadData()
           }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(choose=="1"){//display the favorite landmarks
         self.title = "Favorite Landmarks"// change title
        }else if(choose == "0"){ // display the closest station
        locationDetector.delegate = self
        fetchLocations()
        }else{// get the staion from metro station list and display a landmark list
        self.title = station?.name
        fetchLandmarks()
        fetchLandmarksManager.fetchLandmarks(lat: station?.lat ?? latitude,lon: station?.lon ?? longitude)
}
}
    
    //fetch locations
    private func fetchLocations() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        locationDetector.findLocation()
    }
    
    //fetch stations
    private func fetchStations() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        fetchMetroStationsManager.fetchStations()
    }
    //fetch landmarks
    private func fetchLandmarks(){
        fetchLandmarksManager.delegate = self
        DispatchQueue.main.async {
        MBProgressHUD.showAdded(to: self.view, animated: true)}
    }
    // check if landmark is in favorite landmark list
    func favoriteCheck(){
        for i in stride(from: 0, to: landmarks.count, by: 1) {
            for j in stride(from: 0, to: self.landmarks1.count ,by: 1) {
                if(landmarks1[j].name == landmarks[i].name){
                    landmarks[i].favorites = 1
                }else{
                    landmarks[i].favorites = 0
                }
            }
        }
    }
    //refresh favorite landmarks and check favorite landmark
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(choose=="1"){
            landmarks = PersistenceManager.sharedInstance.fetchLandmarks()}
        else if(choose=="0"){
            landmarks1 = PersistenceManager.sharedInstance.fetchLandmarks()
            favoriteCheck()
        }else{
            landmarks1 = PersistenceManager.sharedInstance.fetchLandmarks()
            favoriteCheck()
        }
    }

    // Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return landmarks.count
    }
    
    //load landmark list and display in landmark cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "landmarkCell", for: indexPath) as! LandmarkTableViewCell
        
        let landmark = landmarks[indexPath.row]
        
        cell.landmarkNameLabel.text = landmark.name
        cell.landmarkAddressLabel.text = landmark.address
        
        if let imageUrlString = landmark.imageUrl, let url = URL(string: imageUrlString) {
            cell.landmarkLogoImage.load(url: url)
        }
        
        return cell
    }
    //tranfer to landmarkDetailController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "landmarksSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the data to your LandmarkDetailViewController
        let row = sender as! Int
        
        let vc = segue.destination as! LandmarkDetailViewController
        vc.landmark = landmarks[row]
    }

}

//Fetch Station List && caculate the nearest station
extension LandmarksViewController: FetchStationsDelegate {
    func stationsFound(_ stations: [Station]) {
        print("stations found - here they are in the controller!")
        for i in stride(from: 0, to: 95 ,by: 1) {
        let coordinate₁ = CLLocation(latitude: stations[i].lat, longitude: stations[i].lon)//get coordinate of the station
        let distanceInMeters = coordinate₀!.distance(from: coordinate₁)//conculate the distance in meter
        if(distance >= distanceInMeters){ //find the minimum of distance
           distance = distanceInMeters
           name = stations[i].name
           latitude = stations[i].lat
           longitude = stations[i].lon
           }
            }
        print(distance)
        print(latitude,longitude)
        //according to the lat & lon of the nearest station to fetch landmarks
        self.title = station?.name ?? name
        fetchLandmarks()
        fetchLandmarksManager.fetchLandmarks(lat: station?.lat ?? latitude,lon: station?.lon ?? longitude)
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func stationsNotFound(reason: FetchMetroStationsManager.FailureReason) {
        print("no stations found")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    } 
}

// Location Detector
extension LandmarksViewController: LocationDetectorDelegate {
    func locationDetected(latitude: Double, longitude: Double) {
         DispatchQueue.main.async {
            self.coordinate₀ = CLLocation(latitude: latitude, longitude: longitude)
            self.fetchMetroStationsManager.delegate = self
            self.fetchStations()
            MBProgressHUD.hide(for: self.view, animated: true)}
        
    }
    
    func locationNotDetected(reason:LocationDetector.FailureReason) {
        print("no location found :(")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: "Problem detecting location", message: reason.rawValue, preferredStyle: .alert)
            
            switch(reason) {
            case .timeout:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.fetchLocations()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
                
                alertController.addAction(cancelAction)
                alertController.addAction(retryAction)
                
            case .noGPS, .noPermission, .notCompleted:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler:nil)
                
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

//Fetch Landmarks
extension LandmarksViewController: FetchLandmarksDelegate {
    func landmarksFound(_ landmarks: [Landmark]) {
        print("landmarks found - here they are in the controller!")
        print(landmarks.count)
        
        DispatchQueue.main.async {
            self.favoriteCheck()
            self.landmarks = landmarks
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }

    
    func landmarksNotFound(reason:FetchLandmarksManager.FailureReason) {
        print("no landmarks found")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: "Problem fetching landmarks", message: reason.rawValue, preferredStyle: .alert)
            
            switch(reason) {
            case .noResponse:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.fetchStations()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
                
                alertController.addAction(cancelAction)
                alertController.addAction(retryAction)
                
            case .non200Response, .noData, .badData:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler:nil)
                
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


