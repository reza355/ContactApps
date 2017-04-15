//
//  RoundedImage.swift
//  ContactApps
//
//  Created by Fathureza Januarza on 4/15/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.bounds.height/2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }

}
