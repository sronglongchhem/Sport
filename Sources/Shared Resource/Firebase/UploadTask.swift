//
//  UploadTask.swift
//  Trainer
//
//  Created by Chhem Sronglong on 20/04/2019.
//  Copyright © 2019 100456065. All rights reserved.
//

import Foundation
import Firebase

final class UploadTask{
    
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
    
    func uploadImage(dataArray : [Data], completionHandler: @escaping ([String]) -> Void) {
        
        if (dataArray.count <= 0) {
            completionHandler([])
            return
        }
        
        var uploadedImageUrlsArray = [String](repeating: "", count: dataArray.count)
        var uploadCount = 0
        let imagesCount = dataArray.count
        
        let imageNameOrder = (1...dataArray.count).map{_ in "\(NSUUID().uuidString).jpg"}
        
        for n in 0...dataArray.count - 1{
            
            
            // Use the unique key as the image name and prepare the storage reference
            let imageName = NSUUID().uuidString // Unique string to reference image
            print("prepare to upload \(imageName)")
            
            let imageStorageRef = PHOTO_STORAGE_REF.child("\(imageNameOrder[n])")
            
            // Create the file metadata
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            // Prepare the upload task
            let uploadTask = imageStorageRef.putData(dataArray[n], metadata: metadata)
            
            // Observe the upload status
            uploadTask.observe(.success) { (snapshot) in
                
                //            guard let displayName = Auth.auth().currentUser?.displayName else {
                //                return
                //            }
                
                // Add a reference in the database
                snapshot.reference.downloadURL(completion: { (url, error) in
                    guard let url = url else {
                        return
                    }
                    // Add a reference in the database
                    let imageFileURL = url.absoluteString
                    let filename = snapshot.metadata?.name
                    let indexofName = imageNameOrder.firstIndex(of: filename ?? imageNameOrder.first!)
                    print("found at index \(indexofName) with name : \(filename)")
                    uploadedImageUrlsArray[indexofName!] = imageFileURL
                    
                    uploadCount += 1
                    //  print("Number of images successfully uploaded: \(uploadCount)")
                    // print("the image of metatadata : \(snapshot.metadata?.name ?? "") upload compelete")
                    if uploadCount == imagesCount{
                        //   NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
                        print("image order : \(imageNameOrder)")
                        print("upload oder : \(uploadedImageUrlsArray)")
                        completionHandler(uploadedImageUrlsArray)
                    }
                    
                })
            }
            
            uploadTask.observe(.progress) { (snapshot) in
                
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                print("Uploading... \(percentComplete)% complete")
            }
            
            uploadTask.observe(.failure) { (snapshot) in
                
                if let error = snapshot.error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
