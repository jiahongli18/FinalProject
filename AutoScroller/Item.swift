//
//  Item.swift
//  AutoScroller
//
//  Created by Jia H Li on 4/25/20.
//  Copyright © 2020 Jiahong Li. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Item {
    var name: String
    var price: Double
    var description: String
    var appImage: UIImage
    var imageURL: String
    var postingUserID: String
    var documentID: String
    var dictionary: [String: Any] {
        return ["name": name, "price": price, "description": description, "imageURL": imageURL, "postingUserID": postingUserID, "documentID": documentID]
    }
    
    init(name: String, price: Double, description: String, appImage: UIImage, imageURL: String, postingUserID: String, documentID: String) {
        self.name = name
        self.price = price
        self.description = description
        self.appImage = appImage
        self.imageURL = imageURL
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let price = dictionary["price"] as! Double? ?? 0.0
        let description = dictionary["description"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let imageURL = dictionary["imageURL"] as! String? ?? ""
        self.init(name: name, price: price, description: description, appImage: UIImage(), imageURL: imageURL, postingUserID: postingUserID, documentID: "")
    }
    
    convenience init() {
        self.init(name: "", price: 0.0, description: "", appImage: UIImage(), imageURL: "", postingUserID: "", documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
            let ref = db.collection("items").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: updating document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked!
                    completion(true)
                }
            }
        } else { // Otherwise create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will creat a new ID for us
            ref = db.collection("items").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("ERROR: adding document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked! Save the documentID in Spot’s documentID property
                    self.documentID = ref!.documentID
                    completion(true)
                }
            }
        }
    }
    
    func saveImage(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        guard let imageToSave = self.appImage.jpegData(compressionQuality: 0.5) else {
            print("ERROR: Could not convert image to data format")
            completed(false)
            return
        }
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        if imageURL == "" {
            imageURL = UUID().uuidString
        }
        let storageRef = storage.reference().child(self.documentID).child(self.imageURL)
        let uploadTask = storageRef.putData(imageToSave, metadata: uploadMetaData) { (metadata, error) in
            guard error == nil else {
                print("ERROR: during .putData storage upload for reference")
                return completed(false)
            }
            print("Upload worked! Metadata is \(metadata)")
        }
        
        uploadTask.observe(.success) { (snapshot) in
            let dataToSave = self.dictionary
            let ref = db.collection("items").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: saving document \(self.documentID) in success observer. Error = \(error.localizedDescription) ")
                    completed(false)
                } else {
                    print("Document updated")
                    completed(true)
                }
            }
        }
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: \(error.localizedDescription) upload task for file \(self.imageURL)")
                return completed(false)
            }
        }
    }
    
    func loadImage(completed: @escaping () -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child(self.documentID).child(self.imageURL)
        storageRef.getData(maxSize: 5 * 1024 * 1024) { (data, error) in
            guard error == nil else {
                print("ERROR: Could not load image from bucket \(self.documentID) for file \(self.imageURL).")
                return completed()
            }
            guard let downloadedImage = UIImage(data: data!) else {
                print("ERROR could not convert data to image from bucket \(self.documentID) for file \(self.imageURL)")
                return completed()
            }
            self.appImage = downloadedImage
            completed()
        }
        
    }
    
}
