//
//  MetroStationsViewController.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/13/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import UIKit
import MBProgressHUD

//The StationList in a TableView
class MetroStationsViewController: UITableViewController {
//init
    
    let fetchMetroStationsManager = FetchMetroStationsManager()
    var stations = [Station]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStations() // fetch station
        self.title = "Select a Station"// set title
    }
    //fetch stations
    private func fetchStations() {
        
        fetchMetroStationsManager.delegate = self
        MBProgressHUD.showAdded(to: self.view, animated: true)
        fetchMetroStationsManager.fetchStations()
    }
    
    // Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the number of rows
        return stations.count
    }
    
    // display name of the station list
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath)

        let station = stations[indexPath.row]
        cell.textLabel?.text = station.name
        
        return cell
    }
    //tranfer to landmarksViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "selectedstationsSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the data to landmarkViewController
        let row = sender as! Int

        let vc = segue.destination as! LandmarksViewController
        vc.station = stations[row]
    }
    
}
//Fetch Station List
extension MetroStationsViewController: FetchStationsDelegate {
    func stationsFound(_ stations: [Station]) {
        print("stations found - here they are in the controller!")
        print(stations.count)
        DispatchQueue.main.async {
            self.stations = stations
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func stationsNotFound(reason: FetchMetroStationsManager.FailureReason) {
        print("no stations found")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
                //alert Controller
                let alertController = UIAlertController(title: "Problem fetching stations", message: reason.rawValue, preferredStyle: .alert)
                
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
