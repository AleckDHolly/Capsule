//
//  DbController.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-07.
//

import Foundation
import FirebaseDatabaseInternal
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import FirebaseStorage

@Observable
class DbController {
    var capsules: [Capsule] = []
//    let databaseRef = Database.database().reference().child("users")
    private let storageRef = Storage.storage().reference()
    static let shared = DbController()
    private var authController = AuthController.shared
    private var userID: String {
        guard let userID = authController.user?.uid else {
            fatalError("User is not signed in")
        }
        
        return userID
    }
   
    
    func isDatePassed(_ dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM. d yyyy 'at' h:mm a" // Ensure the format matches your input date strings
        
        guard let date = dateFormatter.date(from: dateString) else {
            return false
        }
        
        // Directly compare `date` to the current date and time
        return date <= Date()
    }
    
    func addItem(message: String?, dateOuverture: String, estOuverte: Bool, read: Bool, image: UIImage?){
        let newItemRef = authController.databaseRef.child(userID).child("capsules").childByAutoId()
        
        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            newItemRef.setValue(["message": message ?? "", "dateOuverture": dateOuverture, "estOuverte": estOuverte, "read": read, "creator": self.authController.user?.displayName ?? "User", "creatorID": self.authController.user?.uid ?? "null"])
            return
        }
        
        let imageId = UUID().uuidString
        let imageRef = storageRef.child("images/\(imageId).jpg")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metaData) { metadata, error in
            if let error {
                print(error.localizedDescription)
            }
            
            imageRef.downloadURL { url, error in
                if let error {
                    print(error.localizedDescription)
                } else if let url {
                    newItemRef.setValue(["message": message ?? "", "dateOuverture": dateOuverture, "estOuverte": estOuverte, "read": read, "creator": self.authController.user?.displayName ?? "User", "creatorID": self.authController.user?.uid ?? "null", "uploadedImage": url.absoluteString])
                }
            }
        }
    }
    
    func sendCapsule(userId: String, capsule: Capsule){
        let messageRef = authController.databaseRef.child(userId).child("capsules").child(capsule.id)
        
        let capsuleMessage: [String: Any?] = [
            "id": capsule.id,
            "message": capsule.message ?? "",
            "dateOuverture": capsule.dateOuverture,
            "estOuverte": capsule.estOuverte,
            "read": capsule.read,
            "creator": capsule.creator,
            "uploadedImage": capsule.uploadedImage?.absoluteString
        ]
        
        messageRef.setValue(capsuleMessage)
    }
    
    func deleteItem(capsule: Capsule){
        authController.databaseRef.child(userID).child("capsules").child(capsule.id).removeValue()
    }
    
    func markAsOpened(capsule: Capsule){
        authController.databaseRef.child(userID).child("capsules").child(capsule.id).updateChildValues(["estOuverte": true])
    }
    
    func markAsRead(capsule: Capsule){
        authController.databaseRef.child(userID).child("capsules").child(capsule.id).updateChildValues(["read": !capsule.read]) {_,_ in
            capsule.read.toggle()
        }
    }
    
    func fetchItems() {
        let db = authController.databaseRef.child(userID).child("capsules")
        
        db.observe(.value) { snapshot in
            var newCapsules: [Capsule] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let valueDict = childSnapshot.value as? [String: Any],
                   let message = valueDict["message"] as? String,
                   let dateOuverture = valueDict["dateOuverture"] as? String,
                   let estOuverte = valueDict["estOuverte"] as? Bool,
                   let read = valueDict["read"] as? Bool,
                   let creator = valueDict["creator"] as? String {
                    
                    if let uploadedImageURL = valueDict["uploadedImage"] as? String {
                        let url = URL(string: "\(uploadedImageURL).jpg")
                        
                        let capsule = Capsule(
                            id: childSnapshot.key,
                            message: message,
                            dateOuverture: dateOuverture,
                            estOuverte: estOuverte,
                            read: read,
                            creator: creator,
                            uploadedImage: url
                        )
                        
                        newCapsules.append(capsule)
                    } else {
                        let capsule = Capsule(
                            id: childSnapshot.key,
                            message: message,
                            dateOuverture: dateOuverture,
                            estOuverte: estOuverte,
                            read: read,
                            creator: creator,
                            uploadedImage: nil
                        )
                        
                        newCapsules.append(capsule)
                    }
                }
            }
            self.capsules = newCapsules
        }
    }
}
