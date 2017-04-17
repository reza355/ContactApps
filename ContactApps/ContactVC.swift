//
//  ContactVC.swift
//  ContactApps
//
//  Created by Fathureza Januarza on 4/15/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class ContactVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    var SectionName: [String] = ["a","b","c","d","e","f","g","h","i","j"]
    var controller: NSFetchedResultsController<Contact>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //generateTestData()
        deleteAllRecords()
        //downloadContactData {}
        attempFetch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /*(func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SectionName[section]
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return SectionName
    }*/
    /*func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        <#code#>
    }*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections{
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListCell", for: indexPath) as? ContactListCell{
            configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            return cell
        }else{
            return ContactListCell()
        }
    }
    func configureCell(cell: ContactListCell, indexPath: NSIndexPath){
        let contact = controller?.object(at: indexPath as IndexPath)
        cell.configurePost(post: contact!)
    }
    func attempFetch(){
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        let alphabetSort = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [alphabetSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        self.controller = controller
        do{
            try controller.performFetch()
        }catch let error as NSError{
            print(error)
        }
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath{
                let cell = tableView.cellForRow(at: indexPath) as! ContactListCell
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
        case .move:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        }
    }
    func downloadContactData(completed: DownloadComplete){
        let downloadContactURL = URL(string: CONTACT_URL)
        Alamofire.request(downloadContactURL!, method: .get).responseJSON{ response in
            switch response.result {
            case .success:
                if let value = response.result.value{
                    let json = JSON(value)
                    for listItemAsJSON in json.arrayValue{
                        let contactId = listItemAsJSON["contact_id"].int16Value
                        let firstName = listItemAsJSON["first_name"].stringValue
                        let lastName = listItemAsJSON["last_name"].stringValue
                        
                        let contact = Contact(context: context)
                        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
                        fetchrequest.
                        //if contact.contactId != contactId{
                            contact.contactId = contactId
                            contact.firstName = firstName
                            contact.lastName = lastName
                            ad.saveContext()
                        //}
                        print(contact.contactId)
                        
                    }
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Time Out", message: "No Response from Server", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        completed()
    }
    func deleteAllRecords() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }

}
