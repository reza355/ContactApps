//
//  RoundedButton.swift
//  GO-JEK Contact
//
//  Created by Fathureza Januarza on 4/16/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = self.bounds.height/2
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }

}
