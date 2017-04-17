//
//  ContactListCell.swift
//  GO-JEK Contact
//
//  Created by Fathureza Januarza on 4/16/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit

class ContactListCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var photoImg: UIImageView!
    @IBOutlet weak var favoriteImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configurePost(post: Contact){
        
        nameLbl.text = "\(post.firstName) \(post.lastName)"
        photoImg.imageFromServerURL(urlString: "\(IMAGE_URL)\(post.profilePic)")
        if post.favorite == true{
            favoriteImg.image = UIImage(named: "star.png")
        }else if post.favorite == false{
            favoriteImg.image = UIImage(named: "")
        }
    }
    

}
extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
}}
