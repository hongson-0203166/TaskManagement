//
//  ProfileManager.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 14/06/2024.
//

import Foundation
import FirebaseStorage

class ProfileManager{
    static let shared = ProfileManager()
    let storage = Storage.storage()
    
    func uploadFile(fileUrl: URL, completion: @escaping (Result<URL,Error>)-> Void) {
      do {
        // Create file name
        let fileExtension = fileUrl.pathExtension
          let imageName = UserDefaults.standard.string(forKey: "email") ?? ""
          let fileName = "images/\(imageName)"
          let metadata = StorageMetadata()
          metadata.contentType = "image/\(fileExtension)"
        let storageReference = Storage.storage().reference().child(fileName)
        let currentUploadTask = storageReference.putFile(from: fileUrl, metadata: metadata) { (storageMetaData, error) in
          if let error = error {
            print("Upload error: \(error.localizedDescription)")
              completion(.failure(error))
            return
          }
                                                                                    
          // Show UIAlertController here
          print("Image file: \(fileName) is uploaded! View it at Firebase console!")
                                                                                    
          storageReference.downloadURL { (url, error) in
            if let error = error  {
              print("Error on getting download url: \(error.localizedDescription)")
                completion(.failure(error))
              return
            }
            print("Download url of \(fileName) is \(url!.absoluteString)")
              completion(.success(url!))
          }
        }
      } catch {
        print("Error on extracting data from url: \(error.localizedDescription)")
          completion(.failure(error))
      }
    }
    
    func downloadFile(completion: @escaping (Result<URL,Error>)-> Void){
        let imageName = UserDefaults.standard.string(forKey: "email") ?? ""
        let fileName = "images/\(imageName)"
        let storageReference = Storage.storage().reference().child(fileName)
        
        storageReference.downloadURL { (url, error) in
          if let error = error  {
            print("Error on getting download url: \(error.localizedDescription)")
              completion(.failure(error))
            return
          }
          print("Download url of \(fileName) is \(url!.absoluteString)")
            completion(.success(url!))
        }
    }
}
