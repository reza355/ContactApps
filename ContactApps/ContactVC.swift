//
//  ContactVC.swift
//  ContactApps
//
//  Created by Fathureza Januarza on 4/15/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import UIKit
import CoreData

class ContactVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    var SectionName: [String] = ["a","b","c","d","e","f","g","h","i","j"]
    var controller: NSFetchedResultsController<Contact>?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        generateTestData()
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
        return 2
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
        let alphabetSort = NSSortDescriptor(key: "firstName", ascending: false)
        fetchRequest.sortDescriptors = [alphabetSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
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
    func generateTestData(){
        let contact = Contact(context: context)
        contact.firstName = "alberto"
        contact.lastName = "albuquerque"
        
        let contact2 = Contact(context: context)
        contact2.firstName = "alberto"
        contact2.lastName = "albuquerque"

    }
}
