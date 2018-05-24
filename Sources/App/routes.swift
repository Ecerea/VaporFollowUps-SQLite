import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    router.get("plaintext") { req in
        return "Hello Verified"
    }
    
//    router.get("patients") { req in
//        return req.withConnection(to: .sqlite) { db -> Future<Patient> in
//            return try db.query(Patient.self).filter(Patient.providerID == "Testing").all()
//        }
//    }


    let patientController = PatientController()
    router.post("patient", use: patientController.create)
    router.get("patients", use: patientController.index)
    

//    router.get("patients", use: patientController.index)

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
