//
//  AddContactVC.swift
//  GO-JEK Contact
//
//  Created by Fathureza Januarza on 4/17/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
class AddContactVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var AddImageButton: UIButton!
    @IBOutlet weak var firstNameField : UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var contacts = Contact()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        firstNameField.delegate = self
        lastNameField.delegate = self
        phoneField.delegate = self
        emailField.delegate = self
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        editImage.contentMode = .scaleToFill
        editImage.image = chosenImage
        AddImageButton.isHidden = true
        dismiss(animated:true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func browsePhotoLibrary(_ sender: UIButton){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func doneAdd(_ sender: UIBarButtonItem){
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let phone = phoneField.text
        let email = emailField.text
        let emailVal = isValidEmail(emailStr: email!)
        if emailVal == true{
            //Write
            postData(first: firstName!, last: lastName!, phone: phone!, email: email!)
            let alert = UIAlertController(title: "Success", message: "Contact is Updated", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Error format", message: "Email should contain @domain.com", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func realmWrite(contactid: Int, first: String, last: String, phone: String, email: String, profPic: String, url: String, fav: Bool, createDate: Date, updateDate: Date){
        do{
            let realm = try Realm()
            try realm.write {
                realm.create(Contact.self, value: ["contactId": contactid, "firstName": first, "lastName": last, "phoneNumber": phone, "email": email, "profilePic": profPic, "url": url, "favorite": fav, "createdAt": createDate, "updatedAt": updateDate], update: true)
            }
        }catch let error as NSError{
            print(error)
        }
        
    }
    func isValidEmail(emailStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailStr)
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    func postData(first: String, last: String, phone: String, email: String){
        let urlString = URL(string: CONTACT_URL)!
        let param = ["first_name": first, "last_name": last, "email": email, "phone_number": phone]
        let header: HTTPHeaders = [
            
            "Content-Type": "application/json"
        ]
        Alamofire.request(urlString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON{ response in
            switch response.result {
            case .success:
                if let value = response.result.value{
                    let json = JSON(value)
                    print(json)
                    let id = json["id"].intValue
                    let firstName = json["first_name"].stringValue
                    let lastName = json["last_name"].stringValue
                    let favorite = json["favorite"].boolValue
                    let profilePic = json["profile_pic"].stringValue
                    let url = json["url"].stringValue
                    let email = json["email"].stringValue
                    let phone = json["phone_number"].stringValue
                    let created = json["created_at"].date
                    let updated = json["updated_at"].date
                    self.realmWrite(contactid: id, first: firstName, last: lastName, phone: phone, email: email, profPic: profilePic, url: url, fav: favorite, createDate: created!, updateDate: updated!)
                    let alert = UIAlertController(title: "Success", message: "Your Contact List Already Updated", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Time Out", message: "No Response from Server", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
