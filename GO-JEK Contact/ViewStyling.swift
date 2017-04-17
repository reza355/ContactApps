//
//  ViewStyling.swift
//  GO-JEK Contact
//
//  Created by Fathureza Januarza on 4/17/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit

class ViewStyling: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 1.0
    }

}
