//
//  Patient.swift
//  App
//
//  Created by JHartl on 5/10/18.
//

typealias ByteData = Array<UInt8>

import Foundation
import Vapor
import FluentSQLite

final class Patient: SQLiteModel {
    var id: Int?
    var patientID: String
    var providerID: String
//    var currentIV: String
//    var updated: String
    var content: Data
    
    init(id: Int? = nil, patientID: String, providerID: String, content: Data) {
        self.id = id
        self.patientID = patientID
        self.providerID = providerID
        //self.currentIV = currentIV
//        self.updated = updated
        self.content = content
    }
}

extension Patient: Migration { }

extension Patient: Content { }

extension Patient: Parameter { }


