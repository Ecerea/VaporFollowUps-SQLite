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
            
            //For some reason, stored data is being returned as a string that I am unable to decode in the app, so need to create separate object to convert content back to ByteData.
            for patient in patients {
                var patientSend = PatientSend()
                patientSend.patientID = patient.patientID
                patientSend.providerID = patient.providerID
                patientSend.content = [UInt8](patient.content)
                patientArray.append(patientSend)
            }
            return patientArray
        })
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
            print("patientID + \(json)")
            return HTTPResponse(status: .badRequest)
        }
        
        guard let providerID = json["providerID"] as? String else  {
            print("providerID + \(json)")
            return HTTPResponse(status: .badRequest)
        }
        
        guard let anyContent = json["content"] as? Array<Int> else {
            print("byteData + \(json)")
            return HTTPResponse(status: .badRequest)
        }
        
        //Can only decode array into Array<Int> on server. Need to turn this into Data to be stored in sqlite data type(unable to store arrays). So iterate through array and convert to UInt8 and then recompose array.
        var conversionArray = ByteData()
        for int in anyContent {
            let int8 = UInt8(int)
            conversionArray.append(int8)
        }
        let content = Data(bytes: conversionArray)

        //Create New Patient
        let newPatient = Patient(id: nil, patientID: patientID, providerID: providerID, content: content)
        newPatient.save(on: request)
        print("Successfully saved patient")
        return HTTPResponse(status: .accepted)
        
    }
    
    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Patient.self).flatMap { patient in
            return patient.delete(on: req)
            }.transform(to: .ok)
    }
}
