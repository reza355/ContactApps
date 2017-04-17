//
//  EditProfileVC.swift
//  GO-JEK Contact
//
//  Created by Fathureza Januarza on 4/17/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON

class EditContactVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var AddImageButton: UIButton!
    @IBOutlet weak var firstNameField : UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var contact: Contact!
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
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateUI(){
        firstNameField.text = contact.firstName
        lastNameField.text = contact.lastName
        phoneField.text = contact.phoneNumber
        emailField.text = contact.email
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
    @IBAction func doneEditing(_ sender: UIBarButtonItem){
        let id = contact.contactId
        print(id)
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let phone = phoneField.text
        let email = emailField.text
        let updateDate = currentDate()
        let emailVal = isValidEmail(emailStr: email!)
        if emailVal == true{
            realmWrite(contactid: id, first: firstName!, last: lastName!, phone: phone!, email: email!, updateDate: updateDate)
            updateData(first: firstName!, last: lastName!, phone: phone!, email: email!, updateDate: updateDate)
            let alert = UIAlertController(title: "Success", message: "Contact is Updated", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Error format", message: "Email should contain @domain.com", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func realmWrite(contactid: Int, first: String, last: String, phone: String, email: String, updateDate: Date){
        do{
            let realm = try Realm()
            try realm.write {
                realm.create(Contact.self, value: ["contactId": contactid, "firstName": first, "lastName": last, "phoneNumber": phone, "email": email, "updatedAt": updateDate], update: true)
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
    func currentDate()->Date{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        let stringDate = formatter.string(from: date)
        let updateDate = formatter.date(from: stringDate)
        return updateDate!
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
    func updateData(first: String, last: String, phone: String, email: String, updateDate: Date){
        let urlString = URL(string: contact.url)!
        print(urlString)
        let dateString = "\(updateDate)"
        let param = ["first_name": first, "last_name": last, "email": email, "phone_number": phone, "updated_at": dateString]
        let header: HTTPHeaders = [
            
            "Content-Type": "application/json"
        ]
        Alamofire.request(urlString, method: .put, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON{ response in
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
