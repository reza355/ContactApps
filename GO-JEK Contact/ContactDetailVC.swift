//
//  ContactDetailVC.swift
//  GO-JEK Contact
//
//  Created by Fathureza Januarza on 4/17/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
class ContactDetailVC: UIViewController {

    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    var contactDetail: Contact!
    var contact = Contact()
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateUI(){
        contactImage.imageFromServerURL(urlString: "\(IMAGE_URL)\(contactDetail.profilePic)")
        if contactDetail?.favorite == true{
            favoriteBtn.setImage(UIImage(named: "star.png"), for: UIControlState.normal)
        }else{
            favoriteBtn.setImage(UIImage(named: "star-2.png"), for: UIControlState.normal)
            favoriteBtn.backgroundColor = UIColor.white
        }
        phoneLbl.text = contactDetail?.phoneNumber
        emailLbl.text = contactDetail?.email
        nameLbl.text = "\(contactDetail.firstName) \(contactDetail.lastName)"
    }
    @IBAction func editProfileBtn(_ sender: Any) {
        performSegue(withIdentifier: "EditContactVC", sender: contactDetail)
    }
    @IBAction func phoneCallBtn(_ sender: UIButton){
        if let phoneCallURL = URL(string: "tel://\(contactDetail.phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    @IBAction func smsBtn(_ sender: UIButton){
        if let smsURL = URL(string: "sms://\(contactDetail.phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(smsURL)) {
                application.open(smsURL, options: [:], completionHandler: nil)
            }
        }
    }
    @IBAction func emailBtn(_ sender: UIButton){
        if let emailURL = URL(string: "mailto://\(contactDetail.email)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(emailURL)) {
                application.open(emailURL, options: [:], completionHandler: nil)
            }
        }
    }

    @IBAction func favBtn(_ sender: UIButton){
        //contact.contactId = contactDetail.contactId
        if contactDetail.favorite == true{
            let id = contactDetail.contactId
            let fav = false
            let date = currentDate()
            print(date)
            favoriteBtn.setImage(UIImage(named: "star-2.png"), for: UIControlState.normal)
            favoriteBtn.backgroundColor = UIColor.white
            updateRealm(id: id, fav: fav, date: date)
            updateData(favVal: fav, update: date)
        }else if contactDetail.favorite == false{
            let id = contactDetail.contactId
            let fav = true
            let date = currentDate()
            print(date)
            favoriteBtn.setImage(UIImage(named: "star.png"), for: UIControlState.normal)
            favoriteBtn.backgroundColor = UIColor(rgb: 0x66FFCC)
            updateRealm(id: id, fav: fav, date: date)
            updateData(favVal: fav, update: date)
        }
    }
    func updateRealm(id: Int, fav: Bool, date: Date){
        do{
            try realm.write {
                realm.create(Contact.self, value: ["contactId": id, "favorite": fav, "updateAt": date], update: true)
            }
        }catch let error as NSError{
            print(error)
        }
    }
    func currentDate()->Date{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        let stringDate = formatter.string(from: date)
        let updateDate = formatter.date(from: stringDate)
        return updateDate!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditContactVC"{
            let detailVC = segue.destination as? EditContactVC
            if let data = sender as? Contact{
                detailVC?.contact = data
            }
        }
    }
    func updateData(favVal: Bool, update: Date){
        let urlString = URL(string: "http://gojek-contacts-app.herokuapp.com/contacts/\(contactDetail.contactId).json")
        let dateString = "\(update)"
        let header: HTTPHeaders = [

            "Content-Type": "application/json"
        ]
        Alamofire.request(urlString!, method: .put, parameters: ["favorite": favVal, "updated_at": dateString], encoding: JSONEncoding.default, headers: header).responseJSON{ response in
            switch response.result {
            case .success:
                if let value = response.result.value{
                    let json = JSON(value)
                    print(json)
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Time Out", message: "No Response from Server", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
