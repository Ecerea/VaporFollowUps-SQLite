//
//  PatientController.swift
//  App
//
//  Created by JHartl on 5/10/18.
//

import Foundation
import Vapor
import Fluent

struct PatientSend: Codable, Content, ResponseEncodable {
    var patientID: String?
    var providerID: String?
    var content: ByteData?
}

final class PatientController {
    
    func index(_ req: Request) throws -> Future<[PatientSend]> {
        print("GET")
        let  providerID = req.http.headers["providerID"].first ?? ""
        return try Patient.query(on: req).filter(\.providerID == providerID).all().map({ (patients) -> ([PatientSend]) in
            var patientArray = [PatientSend]()
            for patient in patients {
                var patientSend = PatientSend()
                patientSend.patientID = patient.patientID
                patientSend.providerID = patient.providerID
                let content = [UInt8](patient.content)
                patientSend.content = content
                patientArray.append(patientSend)
            }
            return patientArray
        })
        //return Patient.query(on: req).filter(\Patient.providerID == providerID).all()
    }
    
    /// Saves a decoded `Patient` to the database.
    func create(_ request: Request) throws -> HTTPResponse {
        print("POST")
        let data = request.http.body.data
        var json = [String : Any]()
        do {
            json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
            
        } catch {
            print(error)
            print("badRequest")
        }
        guard let patientID = json["patientID"] as? String else {
            print(json)
            return HTTPResponse(status: .badRequest)
        }
        
        guard let byteContent = json["content"] as? ByteData else {
            print(json)
            return HTTPResponse(status: .badRequest)
        }
        let content = Data(bytes: byteContent)
        let array = [UInt8](content)
        print(array.prefix(10))
        //Create New Patient
        let newPatient = Patient(id: nil, patientID: patientID, providerID: "Testing", content: content)
        newPatient.save(on: request)
        return HTTPResponse(status: .accepted)
        
    }
    
    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Patient.self).flatMap { patient in
            return patient.delete(on: req)
            }.transform(to: .ok)
    }
}
