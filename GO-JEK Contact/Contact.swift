//
//  Contact.swift
//  GO-JEK Contact
//
//  Created by Fathureza Januarza on 4/15/17.
//  Copyright © 2017 tedihouse. All rights reserved.
//

import Foundation
import RealmSwift

class Contact: Object {
    dynamic var contactId: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var profilePic: String = ""
    dynamic var favorite: Bool = false
    dynamic var url: String = ""
    dynamic var email: String = ""
    dynamic var phoneNumber: String = ""
    dynamic var createdAt: Date = Date()
    dynamic var updatedAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "contactId"
    }
}
