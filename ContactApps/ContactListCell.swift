//
//  ContactListCell.swift
//  ContactApps
//
//  Created by Fathureza Januarza on 4/15/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit

class ContactListCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImage!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var favImg: UIImage!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configurePost(post: Contact){
        nameLbl.text = "\(post.firstName!) \(post.lastName!)"
    }
    

}
