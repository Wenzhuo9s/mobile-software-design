//
//  LandmarkTableViewCell.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/29/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//


import UIKit
//set a landmark tableview cell with two labels and one image
class LandmarkTableViewCell: UITableViewCell {

    @IBOutlet weak var landmarkNameLabel: UILabel!
    @IBOutlet weak var landmarkLogoImage: UIImageView!
    @IBOutlet weak var landmarkAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
