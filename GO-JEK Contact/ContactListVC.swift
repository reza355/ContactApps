//
//  ViewController.swift
//  GO-JEK Contact
//
//  Created by Fathureza Januarza on 4/15/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON

class ContactListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var contact = List<Contact>()
    let contacts = try! Realm().objects(Contact.self).sorted(byKeyPath: "firstName", ascending: true)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableview.delegate = self
        tableview.dataSource = self
        downloadContent {}
    }
    override func viewDidAppear(_ animated: Bool) {
        //tableview.reloadData()
        //updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = contacts[indexPath.row]
        performSegue(withIdentifier: "ContactDetailVC", sender: data)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListCell", for: indexPath) as? ContactListCell{
            cell.configurePost(post: contacts[indexPath.row])
            return cell
        }else{
            return ContactListCell()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContactDetailVC"{
            let detailVC = segue.destination as? ContactDetailVC
            if let data = sender as? Contact{
                detailVC?.contactDetail = data
            }
        }
    }
    func updateUI(){
        tableview.reloadData()
    }
    @IBAction func addContactBtn(_ sender: UIBarButtonItem){
        performSegue(withIdentifier: "AddContactVC", sender: self)
    }
    
    //REALM CODE
    func downloadContent(completed: @escaping DownloadComplete){
        let loginURL = URL(string: CONTACT_URL)
        Alamofire.request(loginURL!, method: .get).responseJSON{ response in
            switch response.result {
            case .success:
                if let value = response.result.value{
                    let json = JSON(value)
                    for listItemAsJSON in json.arrayValue{
                        let id = listItemAsJSON["id"].intValue
                        let firstName = listItemAsJSON["first_name"].stringValue
                        let lastName = listItemAsJSON["last_name"].stringValue
                        let favorite = listItemAsJSON["favorite"].boolValue
                        let profilePic = listItemAsJSON["profile_pic"].stringValue
                        let url = listItemAsJSON["url"].stringValue
                        let loginURL = URL(string: url)
                        Alamofire.request(loginURL!, method: .get).responseJSON{ response in
                            switch response.result {
                            case .success:
                                if let value = response.result.value{
                                    let jsonDetail = JSON(value)
                                    let email = jsonDetail["email"].stringValue
                                    let phone = jsonDetail["phone_number"].stringValue
                                    let created = jsonDetail["created_at"].date
                                    let updated = jsonDetail["updated_at"].date
                                    let contactData = Contact(value: ["contactId": id, "firstName": firstName, "lastName": lastName, "profilePic": profilePic, "favorite": favorite, "url": url, "email": email, "phoneNumber": phone, "createdAt": created, "updatedAt": updated])
                                    self.contact.append(contactData)
                                    do{
                                        let realm = try! Realm()
                                        try realm.write {
                                            realm.add(contactData, update: true)
                                        }
                                    }catch let error as NSError{
                                        print(error)
                                    }
                                    self.updateUI()
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
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Time Out", message: "No Response from Server", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            completed()
        }
    }
}
extension JSON {
    public var date: Date? {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str)
            }
            return nil
        }
    }
    private static let jsonDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()
}

