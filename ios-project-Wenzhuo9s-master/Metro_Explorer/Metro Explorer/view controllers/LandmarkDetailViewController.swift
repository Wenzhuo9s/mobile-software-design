//
//  LandmarkDetailViewController.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/13/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//

import UIKit
import MapKit

class LandmarkDetailViewController: UIViewController {
    
    var landmark: Landmark?//init a landmark struct from landmarkviewController

    @IBOutlet weak var ImageDetail: UIImageView! // imageView to show landmark image
    
    @IBOutlet weak var NameDetailLabel: UILabel! // Label to show name
    
    @IBOutlet weak var AddressDetailLabel: UILabel! // Address to show address
    
    @IBOutlet weak var RatingDetailLabel: UILabel!  // Rating to show rate
    
    var landmarks=[Landmark]()//init a landmark list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NameDetailLabel.text = landmark?.name // get value and display name
        
        AddressDetailLabel.text = landmark?.address // get value and display address
        
        let rate = "\(landmark?.rating ?? 0.0)" // get rate value
        
        RatingDetailLabel.text = rate // display rate
    
        if let imageUrlString = landmark?.imageUrl, let url = URL(string: imageUrlString) {
            ImageDetail.load(url: url)   //UIImageView to download and display a landmark image
        }
        if(landmark?.favorites == 0){unfavoriteshow()}//show unfavorite button
        if(landmark?.favorites == 1){favoriteshow()}//show favorite button
}
    
    //it is a circle to change status from favorite to unfavorite /from unfavorite to favorite
    @objc func unfavorite(_ sender:UIBarButtonItem!)// remove favorite landmark
    {
        unfavoriteshow()
        PersistenceManager.sharedInstance.removeLandmark(landmark: landmark!)// remove landmark
    }
    
    @objc func favorite(_ sender:UIBarButtonItem!)//add favorite landmark
    {
        favoriteshow()
        let landmark = Landmark(name: self.landmark?.name ?? "", imageUrl: self.landmark?.imageUrl!, address: self.landmark?.address ?? "", rating: self.landmark?.rating ?? 0.0, favorites: 1)//set landmark
        PersistenceManager.sharedInstance.saveLandmark(landmark: landmark)//add landmark
}
    //
    @IBAction func favoriteButtonPressed(_ sender: Any) {//press favorite button
        print("favoriteButtonPressed")
        //judge if landmark is in favorite list and show right button image
        if(landmark?.favorites == 0){//unfavorite
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "baseline_favorite_white_36"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(LandmarkDetailViewController.unfavorite(_:)))//press to remove favorite
        self.navigationItem.rightBarButtonItem = rightBarButton
            
        let landmark = Landmark(name: self.landmark?.name ?? "", imageUrl: self.landmark?.imageUrl!, address: self.landmark?.address ?? "", rating: self.landmark?.rating ?? 0.0, favorites: 1)//set landmark
            PersistenceManager.sharedInstance.saveLandmark(landmark: landmark)}//add favorite
        
        if(landmark?.favorites == 1){//favorite
            let rightBarButton = UIBarButtonItem(image: UIImage(named: "baseline_favorite_border_white_36"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(LandmarkDetailViewController.favorite(_:)))//press to add favorite
            self.navigationItem.rightBarButtonItem = rightBarButton
            
      let landmark = Landmark(name: self.landmark?.name ?? "", imageUrl: self.landmark?.imageUrl!, address: self.landmark?.address ?? "", rating: self.landmark?.rating ?? 0.0, favorites: 0)//set landmark
            PersistenceManager.sharedInstance.removeLandmark(landmark: landmark)//remove favorite
        }
    }
    
    //display unfavorite button image
    func unfavoriteshow(){
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "baseline_favorite_border_white_36"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(LandmarkDetailViewController.favoriteButtonPressed(_:)))//press to change status
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    //display favorite button image
    func favoriteshow(){
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "baseline_favorite_white_36"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(LandmarkDetailViewController.favoriteButtonPressed(_:)))//press to change status
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    //Share Button Action
    @IBAction func shareButtonPressed(_ sender: Any) {
        
        let shareText = "\(String(describing: landmark!.name))"
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    //Get Direction Button Action
    @IBAction func getDirectionButtonPressed(_ sender: Any)  {
        print("get direction button pressed")
        let address = landmark!.address.replacingOccurrences(of: " ", with: "+")//replace "" to "+"
        let url = "http://maps.apple.com/?dirflag=r&daddr=\(address)"//using address as a destination
        
        let appleMapAppDeepLink = URL(string:url)//deep link to apple map
      
       if UIApplication.shared.canOpenURL(appleMapAppDeepLink!) {
          UIApplication.shared.open(appleMapAppDeepLink!, options: [:], completionHandler: nil)
       }
     }
}
