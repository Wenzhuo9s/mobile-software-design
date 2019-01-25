//
//  ViewController.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/13/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import UIKit
import MBProgressHUD

//The MenuView with a image and label, three buttons "Select Stations", "Closest Station", "FavoriteLandmark"
class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//Select Stations Button Action
    @IBAction func selectStationsButtonPressed(_ sender: Any)  {
        print("stations selection pressed")
        performSegue(withIdentifier: "stationsSegue", sender: self)//transfer to MetroStationsViewController to show station list
    }
    
//Closest Stations Button Action
    @IBAction func closestStationButtonPressed(_ sender: Any)  {
        print("closest station pressed")
        performSegue(withIdentifier: "businessesSegue", sender: self)//transfer to LandmarksViewController
    }
    
//Favorite Landmark Button Action
    @IBAction func favoriteLandmarkButtonPressed(_ sender: Any) {
        print("favorite landmark pressed")
        performSegue(withIdentifier: "favoritesSegue", sender: self)//transfer to LandmarksViewController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "businessesSegue" {
           let vc = segue.destination as! LandmarksViewController
           vc.choose = "0" //Pass the variable "choose" to landmarkViewController to show landmarks list of the closest station
        }
        
        if segue.identifier == "favoritesSegue" {
            let vc = segue.destination as! LandmarksViewController
            vc.choose = "1"//Pass the variable "choose" to landmarkViewController to show favorite landmarks list
        }
    }
}
