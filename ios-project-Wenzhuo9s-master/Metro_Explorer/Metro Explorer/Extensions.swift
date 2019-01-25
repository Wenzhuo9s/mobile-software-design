//
//  Extension.swift
//  Metro Explorer
//
//  Created by Wenzhuo on 11/29/18.
//  Copyright © 2018 Wenzhuo. All rights reserved.
//


import Foundation
import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
